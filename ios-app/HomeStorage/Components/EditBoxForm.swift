import SwiftUI

struct EditBoxForm: View {
    let box: Box
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var apiService = APIService()
    @State private var rooms: [Room] = []
    @State private var name: String
    @State private var description: String
    @State private var selectedRoomId: String?
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    init(box: Box, onSuccess: @escaping () -> Void) {
        self.box = box
        self.onSuccess = onSuccess
        _name = State(initialValue: box.name ?? "")
        _description = State(initialValue: box.description ?? "")
        _selectedRoomId = State(initialValue: box.roomId)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("NFC Tag") {
                    Text(box.nfcTagId)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    TextField("Box name", text: $name)
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
            .navigationTitle("Edit Box")
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
                            await updateBox()
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
            .task {
                await loadRooms()
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
    
    private func updateBox() async {
        isSubmitting = true
        errorMessage = nil
        
        let request = BoxUpdateRequest(
            name: name.isEmpty ? nil : name,
            description: description.isEmpty ? nil : description,
            roomId: selectedRoomId,
            rackId: nil
        )
        
        do {
            _ = try await apiService.updateBox(id: box.id, request)
            onSuccess()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
}

