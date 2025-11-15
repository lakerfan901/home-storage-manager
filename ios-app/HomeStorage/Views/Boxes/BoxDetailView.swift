import SwiftUI

struct BoxDetailView: View {
    let boxId: String
    @StateObject private var apiService = APIService()
    @State private var boxDetail: BoxDetailResponse?
    @State private var isLoading = true
    @State private var showingAddItem = false
    @State private var editingItem: Item?
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if let detail = boxDetail {
                // Box Info Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(detail.box.boxName ?? "Box \(String(detail.box.nfcTagId.prefix(8)))")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let description = detail.box.boxName {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("NFC: \(detail.box.nfcTagId)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Location: \(detail.box.floorName) → \(detail.box.roomName)\(detail.box.rackName.map { " → \($0)" } ?? "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Items Section
                Section {
                    if detail.items.isEmpty {
                        Text("No items in this box yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(detail.items) { item in
                            ItemRow(item: item)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await deleteItem(item.id)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        editingItem = item
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                }
                        }
                    }
                } header: {
                    HStack {
                        Text("Items (\(detail.items.count))")
                        Spacer()
                        Button {
                            showingAddItem = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
        }
        .navigationTitle("Box")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddItem) {
            if let box = boxDetail?.box {
                AddItemForm(boxId: box.boxId) {
                    Task {
                        await loadBoxDetail()
                    }
                }
            }
        }
        .sheet(item: $editingItem) { item in
            EditItemForm(item: item) {
                Task {
                    await loadBoxDetail()
                }
            }
        }
        .task {
            await loadBoxDetail()
        }
    }
    
    private func loadBoxDetail() async {
        isLoading = true
        do {
            boxDetail = try await apiService.fetchBox(id: boxId)
        } catch {
            // Handle error
        }
        isLoading = false
    }
    
    private func deleteItem(_ id: String) async {
        do {
            try await apiService.deleteItem(id: id)
            await loadBoxDetail()
        } catch {
            // Handle error
        }
    }
}

struct ItemRow: View {
    let item: Item
    
    var body: some View {
        HStack {
            Image(systemName: "cube.box.fill")
                .foregroundColor(.orange)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    if let tag = item.tag {
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                if let description = item.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
    }
}

