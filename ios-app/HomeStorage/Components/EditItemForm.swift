import SwiftUI

struct EditItemForm: View {
    let item: Item
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var apiService = APIService()
    @State private var name: String
    @State private var description: String
    @State private var quantity: Int
    @State private var tag: String
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    init(item: Item, onSuccess: @escaping () -> Void) {
        self.item = item
        self.onSuccess = onSuccess
        _name = State(initialValue: item.name)
        _description = State(initialValue: item.description ?? "")
        _quantity = State(initialValue: item.quantity)
        _tag = State(initialValue: item.tag ?? "")
    }
    
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
            .navigationTitle("Edit Item")
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
                            await updateItem()
                        }
                    }
                    .disabled(name.isEmpty || isSubmitting)
                }
            }
        }
    }
    
    private func updateItem() async {
        isSubmitting = true
        errorMessage = nil
        
        let request = ItemUpdateRequest(
            name: name,
            description: description.isEmpty ? nil : description,
            quantity: quantity,
            tag: tag.isEmpty ? nil : tag
        )
        
        do {
            _ = try await apiService.updateItem(id: item.id, request)
            onSuccess()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
}

