import SwiftUI

struct ItemsListView: View {
    @StateObject private var apiService = APIService()
    @State private var items: [ItemLocation] = []
    @State private var filteredItems: [ItemLocation] = []
    @State private var searchText = ""
    @State private var selectedTag: String?
    @State private var availableTags: [String] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Tag Filters
                    if !availableTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                TagFilterButton(
                                    title: "All",
                                    isSelected: selectedTag == nil
                                ) {
                                    selectedTag = nil
                                    filterItems()
                                }
                                
                                ForEach(availableTags, id: \.self) { tag in
                                    TagFilterButton(
                                        title: tag,
                                        isSelected: selectedTag == tag
                                    ) {
                                        selectedTag = tag
                                        filterItems()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: BoxDetailView(boxId: item.boxId)) {
                                ItemLocationRow(item: item)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search items...")
                }
            }
            .navigationTitle("All Items")
            .onChange(of: searchText) { _ in
                filterItems()
            }
            .onChange(of: selectedTag) { _ in
                filterItems()
            }
            .task {
                await loadItems()
            }
        }
    }
    
    private func loadItems() async {
        isLoading = true
        do {
            items = try await apiService.fetchItems()
            extractTags()
            filterItems()
        } catch {
            // Handle error
        }
        isLoading = false
    }
    
    private func extractTags() {
        let tags = Set(items.compactMap { $0.itemTag })
        availableTags = Array(tags).sorted()
    }
    
    private func filterItems() {
        var filtered = items
        
        if let tag = selectedTag {
            filtered = filtered.filter { $0.itemTag == tag }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            filtered = filtered.filter { item in
                item.itemName.lowercased().contains(query) ||
                item.itemDescription?.lowercased().contains(query) ?? false ||
                item.boxName?.lowercased().contains(query) ?? false ||
                item.roomName.lowercased().contains(query)
            }
        }
        
        filteredItems = filtered
    }
}

struct ItemLocationRow: View {
    let item: ItemLocation
    
    var body: some View {
        HStack {
            Image(systemName: "cube.box.fill")
                .foregroundColor(.orange)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.itemName)
                        .font(.headline)
                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    if let tag = item.itemTag {
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                if let description = item.itemDescription {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Text("\(item.floorName) → \(item.roomName)\(item.rackName.map { " → \($0)" } ?? "") → \(item.boxName ?? "Box")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TagFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "tag.fill")
                    .font(.caption2)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

