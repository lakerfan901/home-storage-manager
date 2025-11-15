import SwiftUI

struct FloorsListView: View {
    @StateObject private var apiService = APIService()
    @State private var floors: [Floor] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if floors.isEmpty {
                    Text("No floors found")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(floors) { floor in
                        NavigationLink(destination: FloorDetailView(floor: floor)) {
                            FloorListRow(floor: floor)
                        }
                    }
                }
            }
            .navigationTitle("Floors")
            .refreshable {
                await loadFloors()
            }
            .task {
                await loadFloors()
            }
        }
    }
    
    private func loadFloors() async {
        isLoading = true
        do {
            floors = try await apiService.fetchFloors()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct FloorListRow: View {
    let floor: Floor
    
    var body: some View {
        HStack {
            Image(systemName: "layers.fill")
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(floor.name.capitalized)
                    .font(.headline)
                if let roomCount = floor.roomCount {
                    Text("\(roomCount) room\(roomCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

