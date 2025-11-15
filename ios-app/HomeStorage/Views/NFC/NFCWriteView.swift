import SwiftUI

struct NFCWriteView: View {
    let boxId: String
    let nfcTagId: String
    @StateObject private var nfcService = NFCService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var isWriting = false
    @State private var writeSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if isWriting {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Hold your iPhone near the NFC tag to write")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else if writeSuccess {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.green)
                        
                        Text("Success!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("NFC tag has been written successfully")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if let error = errorMessage {
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
                    VStack(spacing: 16) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 64))
                            .foregroundColor(.blue)
                        
                        Text("Write to NFC Tag")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Writing box ID: \(nfcTagId)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Tap the button below to start writing")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                Spacer()
                
                if !isWriting && !writeSuccess {
                    Button {
                        Task {
                            await writeTag()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("Start Writing")
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
            .navigationTitle("Write NFC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onChange(of: nfcService.isScanning) { newValue in
                isWriting = newValue
            }
        }
    }
    
    private func writeTag() async {
        isWriting = true
        errorMessage = nil
        writeSuccess = false
        
        let (success, error) = await nfcService.writeTag(data: nfcTagId)
        isWriting = false
        
        if success {
            writeSuccess = true
        } else {
            errorMessage = error ?? "Failed to write to NFC tag"
        }
    }
}

