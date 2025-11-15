import SwiftUI

struct AddRoomForm: View {
    let floorId: String
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var apiService = APIService()
    @State private var name = ""
    @State private var description = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
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
            .navigationTitle("Add Room")
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
                            await createRoom()
                        }
                    }
                    .disabled(name.isEmpty || isSubmitting)
                }
            }
        }
    }
    
    private func createRoom() async {
        isSubmitting = true
        errorMessage = nil
        
        let request = RoomCreateRequest(
            floorId: floorId,
            name: name,
            description: description.isEmpty ? nil : description
        )
        
        do {
            _ = try await apiService.createRoom(request)
            onSuccess()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
}

