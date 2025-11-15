import SwiftUI

struct BoxesListView: View {
    @StateObject private var apiService = APIService()
    @State private var boxes: [BoxLocation] = []
    @State private var filteredBoxes: [BoxLocation] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var showingAddBox = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredBoxes) { box in
                            NavigationLink(destination: BoxDetailView(boxId: box.boxId)) {
                                BoxLocationRow(box: box)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search boxes...")
                }
            }
            .navigationTitle("All Boxes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBox = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBox) {
                AddBoxForm(roomId: nil) {
                    Task {
                        await loadBoxes()
                    }
                }
            }
            .onChange(of: searchText) { newValue in
                filterBoxes()
            }
            .task {
                await loadBoxes()
            }
        }
    }
    
    private func loadBoxes() async {
        isLoading = true
        do {
            boxes = try await apiService.fetchBoxes()
            filterBoxes()
        } catch {
            // Handle error
        }
        isLoading = false
    }
    
    private func filterBoxes() {
        if searchText.isEmpty {
            filteredBoxes = boxes
        } else {
            let query = searchText.lowercased()
            filteredBoxes = boxes.filter { box in
                box.boxName?.lowercased().contains(query) ?? false ||
                box.roomName.lowercased().contains(query) ||
                box.floorName.lowercased().contains(query) ||
                box.nfcTagId.lowercased().contains(query)
            }
        }
    }
}

struct BoxLocationRow: View {
    let box: BoxLocation
    
    var body: some View {
        HStack {
            Image(systemName: "archivebox.fill")
                .foregroundColor(.green)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(box.boxName ?? "Box \(String(box.nfcTagId.prefix(8)))")
                    .font(.headline)
                Text("\(box.floorName) → \(box.roomName)\(box.rackName.map { " → \($0)" } ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("NFC: \(box.nfcTagId)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

