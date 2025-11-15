import SwiftUI

struct AddBoxForm: View {
    let roomId: String?
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var apiService = APIService()
    @StateObject private var nfcService = NFCService()
    @State private var rooms: [Room] = []
    @State private var nfcTagId = ""
    @State private var name = ""
    @State private var description = ""
    @State private var selectedRoomId: String?
    @State private var isSubmitting = false
    @State private var isScanningNFC = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("NFC Tag") {
                    HStack {
                        TextField("NFC Tag ID", text: $nfcTagId)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        Button {
                            Task {
                                await scanNFC()
                            }
                        } label: {
                            Image(systemName: "waveform")
                        }
                        .disabled(isScanningNFC)
                    }
                }
                
                Section {
                    TextField("Box name (optional)", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Location") {
                    if rooms.isEmpty {
                        Text("Loading rooms...")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Room", selection: $selectedRoomId) {
                            Text("Select Room").tag(nil as String?)
                            ForEach(rooms) { room in
                                Text("\(room.floorName ?? "") - \(room.name)").tag(room.id as String?)
                            }
                        }
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Box")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await createBox()
                        }
                    }
                    .disabled(nfcTagId.isEmpty || selectedRoomId == nil || isSubmitting)
                }
            }
            .task {
                await loadRooms()
                if let roomId = roomId {
                    selectedRoomId = roomId
                }
            }
            .onChange(of: nfcService.lastScannedTag) { newValue in
                if let tag = newValue {
                    nfcTagId = tag
                    isScanningNFC = false
                }
            }
        }
    }
    
    private func loadRooms() async {
        do {
            rooms = try await apiService.fetchRooms()
        } catch {
            // Handle error
        }
    }
    
    private func scanNFC() async {
        isScanningNFC = true
        let tagId = await nfcService.scanTag()
        if let tagId = tagId {
            nfcTagId = tagId
        }
        isScanningNFC = false
    }
    
    private func createBox() async {
        isSubmitting = true
        errorMessage = nil
        
        guard let roomId = selectedRoomId else {
            errorMessage = "Please select a room"
            isSubmitting = false
            return
        }
        
        let request = BoxCreateRequest(
            nfcTagId: nfcTagId,
            name: name.isEmpty ? nil : name,
            description: description.isEmpty ? nil : description,
            roomId: roomId,
            rackId: nil
        )
        
        do {
            _ = try await apiService.createBox(request)
            onSuccess()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
}

