import SwiftUI

struct AddItemForm: View {
    let boxId: String
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var apiService = APIService()
    @State private var name = ""
    @State private var description = ""
    @State private var quantity = 1
    @State private var tag = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Item name", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...999)
                    TextField("Tag (optional)", text: $tag)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Item")
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
                            await createItem()
                        }
                    }
                    .disabled(name.isEmpty || isSubmitting)
                }
            }
        }
    }
    
    private func createItem() async {
        isSubmitting = true
        errorMessage = nil
        
        let request = ItemCreateRequest(
            boxId: boxId,
            name: name,
            description: description.isEmpty ? nil : description,
            quantity: quantity,
            tag: tag.isEmpty ? nil : tag
        )
        
        do {
            _ = try await apiService.createItem(request)
            onSuccess()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
}

