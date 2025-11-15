import Foundation
import CoreNFC

class NFCService: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var lastScannedTag: String?
    @Published var errorMessage: String?
    
    private var readerSession: NFCNDEFReaderSession?
    private var writerSession: NFCNDEFWriterSession?
    private var scanCompletion: ((String?) -> Void)?
    private var writeCompletion: ((Bool, String?) -> Void)?
    private var dataToWrite: String?
    
    // MARK: - Reading NFC Tags
    
    func scanTag() async -> String? {
        return await withCheckedContinuation { continuation in
            guard NFCNDEFReaderSession.readingAvailable else {
                continuation.resume(returning: nil)
                return
            }
            
            scanCompletion = { tagId in
                continuation.resume(returning: tagId)
            }
            
            readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            readerSession?.alertMessage = "Hold your iPhone near the NFC tag"
            readerSession?.begin()
            
            DispatchQueue.main.async {
                self.isScanning = true
            }
        }
    }
    
    // MARK: - Writing NFC Tags
    
    func writeTag(data: String) async -> (Bool, String?) {
        return await withCheckedContinuation { continuation in
            guard NFCNDEFWriterSession.readingAvailable else {
                continuation.resume(returning: (false, "NFC writing not available on this device"))
                return
            }
            
            writeCompletion = { success, error in
                continuation.resume(returning: (success, error))
            }
            
            dataToWrite = data
            
            writerSession = NFCNDEFWriterSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            writerSession?.alertMessage = "Hold your iPhone near the NFC tag to write"
            writerSession?.begin()
            
            DispatchQueue.main.async {
                self.isScanning = true
            }
        }
    }
    
    private func stopScanning() {
        DispatchQueue.main.async {
            self.isScanning = false
        }
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension NFCService: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Handle NDEF messages
        for message in messages {
            for record in message.records {
                if let payload = String(data: record.payload, encoding: .utf8) {
                    // Extract tag identifier from payload
                    let tagId = payload.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    DispatchQueue.main.async {
                        self.lastScannedTag = tagId
                    }
                    scanCompletion?(tagId)
                    return
                }
            }
        }
        
        // If no NDEF data, try to get tag identifier
        scanCompletion?(nil)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than one tag detected. Please try again with only one tag."
            session.invalidate()
            stopScanning()
            scanCompletion?(nil)
            return
        }
        
        let tag = tags.first!
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
                self.stopScanning()
                self.scanCompletion?(nil)
                return
            }
            
            tag.readNDEF { message, error in
                if let error = error {
                    // Try to get tag identifier even if NDEF read fails
                    if let identifier = tag.identifier.isEmpty ? nil : tag.identifier.map { String(format: "%02x", $0) }.joined() {
                        DispatchQueue.main.async {
                            self.lastScannedTag = identifier
                        }
                        self.scanCompletion?(identifier)
                    } else {
                        self.scanCompletion?(nil)
                    }
                    session.invalidate(errorMessage: "Read error: \(error.localizedDescription)")
                    self.stopScanning()
                    return
                }
                
                if let message = message {
                    for record in message.records {
                        if let payload = String(data: record.payload, encoding: .utf8) {
                            let tagId = payload.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                            DispatchQueue.main.async {
                                self.lastScannedTag = tagId
                            }
                            self.scanCompletion?(tagId)
                            session.invalidate()
                            self.stopScanning()
                            return
                        }
                    }
                }
                
                // Fallback to identifier
                let identifier = tag.identifier.map { String(format: "%02x", $0) }.joined()
                DispatchQueue.main.async {
                    self.lastScannedTag = identifier
                }
                self.scanCompletion?(identifier)
                session.invalidate()
                self.stopScanning()
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let nfcError = error as? NFCReaderError {
            if nfcError.code != .readerSessionInvalidationErrorUserCanceled {
                DispatchQueue.main.async {
                    self.errorMessage = nfcError.localizedDescription
                }
            }
        }
        stopScanning()
        scanCompletion?(nil)
    }
}

// MARK: - NFCNDEFWriterSessionDelegate

extension NFCService: NFCNDEFWriterSessionDelegate {
    func writerSession(_ session: NFCNDEFWriterSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than one tag detected. Please try again with only one tag."
            session.invalidate()
            stopScanning()
            writeCompletion?(false, "Multiple tags detected")
            return
        }
        
        guard let tag = tags.first, let dataToWrite = dataToWrite else {
            session.invalidate()
            stopScanning()
            writeCompletion?(false, "No data to write")
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
                self.stopScanning()
                self.writeCompletion?(false, error.localizedDescription)
                return
            }
            
            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    session.invalidate(errorMessage: "Query error: \(error.localizedDescription)")
                    self.stopScanning()
                    self.writeCompletion?(false, error.localizedDescription)
                    return
                }
                
                guard status != .notSupported else {
                    session.invalidate(errorMessage: "Tag does not support NDEF")
                    self.stopScanning()
                    self.writeCompletion?(false, "Tag does not support NDEF")
                    return
                }
                
                // Create NDEF message
                let payload = Data(dataToWrite.utf8)
                let record = NFCNDEFPayload(
                    format: .nfcWellKnown,
                    type: Constants.nfcMessageType.data(using: .utf8)!,
                    identifier: Data(),
                    payload: payload
                )
                let message = NFCNDEFMessage(records: [record])
                
                tag.writeNDEF(message) { error in
                    if let error = error {
                        session.invalidate(errorMessage: "Write error: \(error.localizedDescription)")
                        self.stopScanning()
                        self.writeCompletion?(false, error.localizedDescription)
                    } else {
                        session.alertMessage = "Successfully wrote to NFC tag"
                        session.invalidate()
                        self.stopScanning()
                        self.writeCompletion?(true, nil)
                    }
                }
            }
        }
    }
    
    func writerSession(_ session: NFCNDEFWriterSession, didInvalidateWithError error: Error) {
        if let nfcError = error as? NFCReaderError {
            if nfcError.code != .readerSessionInvalidationErrorUserCanceled {
                DispatchQueue.main.async {
                    self.errorMessage = nfcError.localizedDescription
                }
            }
        }
        stopScanning()
        writeCompletion?(false, error.localizedDescription)
    }
}

