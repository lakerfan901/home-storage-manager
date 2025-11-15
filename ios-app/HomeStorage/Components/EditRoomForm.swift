import SwiftUI

struct EditRoomForm: View {
    let room: Room
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var apiService = APIService()
    @State private var name: String
    @State private var description: String
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    init(room: Room, onSuccess: @escaping () -> Void) {
        self.room = room
        self.onSuccess = onSuccess
        _name = State(initialValue: room.name)
        _description = State(initialValue: room.description ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Room name", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Room")
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
                            await updateRoom()
                        }
                    }
                    .disabled(name.isEmpty || isSubmitting)
                }
            }
        }
    }
    
    private func updateRoom() async {
        isSubmitting = true
        errorMessage = nil
        
        let request = RoomUpdateRequest(
            name: name,
            description: description.isEmpty ? nil : description
        )
        
        do {
            _ = try await apiService.updateRoom(id: room.id, request)
            onSuccess()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
}

