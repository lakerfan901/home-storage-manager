import SwiftUI

struct NFCScanView: View {
    @StateObject private var nfcService = NFCService()
    @StateObject private var apiService = APIService()
    @Binding var scannedBoxId: String?
    @Environment(\.dismiss) private var dismiss
    
    @State private var isScanning = false
    @State private var scannedTag: String?
    @State private var foundBox: BoxLocation?
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if isScanning {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Hold your iPhone near the NFC tag")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else if let box = foundBox {
                    // Found Box View
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.green)
                        
                        Text("Box Found")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(box.boxName ?? "Box \(String(box.nfcTagId.prefix(8)))")
                                .font(.headline)
                            Text("NFC: \(box.nfcTagId)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Location: \(box.floorName) → \(box.roomName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        Button {
                            scannedBoxId = box.boxId
                            dismiss()
                        } label: {
                            Text("View Box")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                } else if let error = errorMessage {
                    // Error View
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.red)
                        
                        Text("Error")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    // Initial State
                    VStack(spacing: 16) {
                        Image(systemName: "waveform")
                            .font(.system(size: 64))
                            .foregroundColor(.blue)
                        
                        Text("Scan NFC Tag")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Tap the button below to start scanning for NFC tags")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                Spacer()
                
                if !isScanning && foundBox == nil {
                    Button {
                        Task {
                            await scanTag()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "waveform")
                            Text("Start Scanning")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("NFC Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onChange(of: nfcService.isScanning) { newValue in
                isScanning = newValue
            }
            .onChange(of: nfcService.lastScannedTag) { newValue in
                if let tag = newValue {
                    scannedTag = tag
                    Task {
                        await lookupBox(tagId: tag)
                    }
                }
            }
        }
    }
    
    private func scanTag() async {
        isScanning = true
        errorMessage = nil
        foundBox = nil
        
        let tagId = await nfcService.scanTag()
        isScanning = false
        
        if let tagId = tagId {
            scannedTag = tagId
            await lookupBox(tagId: tagId)
        } else {
            errorMessage = "Failed to read NFC tag. Please try again."
        }
    }
    
    private func lookupBox(tagId: String) async {
        isLoading = true
        do {
            let box = try await apiService.fetchBoxByNFC(nfcTagId: tagId)
            foundBox = box
            errorMessage = nil
        } catch {
            errorMessage = "Box not found for NFC tag: \(tagId)"
            foundBox = nil
        }
        isLoading = false
    }
}

