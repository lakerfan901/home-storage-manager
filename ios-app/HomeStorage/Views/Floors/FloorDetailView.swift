import SwiftUI

struct FloorDetailView: View {
    let floor: Floor
    @StateObject private var apiService = APIService()
    @State private var floorDetail: APIService.FloorDetailResponse?
    @State private var isLoading = true
    @State private var showingAddRoom = false
    @State private var editingRoom: Room?
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if let detail = floorDetail {
                if detail.rooms.isEmpty {
                    Text("No rooms on this floor yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(detail.rooms) { room in
                        NavigationLink(destination: RoomDetailView(roomId: room.id)) {
                            RoomListRow(room: room)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task {
                                    await deleteRoom(room.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                editingRoom = room
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(floor.name.capitalized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddRoom = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddRoom) {
            AddRoomForm(floorId: floor.id) {
                Task {
                    await loadFloorDetail()
                }
            }
        }
        .sheet(item: $editingRoom) { room in
            EditRoomForm(room: room) {
                Task {
                    await loadFloorDetail()
                }
            }
        }
        .task {
            await loadFloorDetail()
        }
    }
    
    private func loadFloorDetail() async {
        isLoading = true
        do {
            floorDetail = try await apiService.fetchFloor(id: floor.id)
        } catch {
            // Handle error
        }
        isLoading = false
    }
    
    private func deleteRoom(_ id: String) async {
        do {
            try await apiService.deleteRoom(id: id)
            await loadFloorDetail()
        } catch {
            // Handle error
        }
    }
}

struct RoomListRow: View {
    let room: Room
    
    var body: some View {
        HStack {
            Image(systemName: "door.left.hand.open")
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(room.name)
                    .font(.headline)
                if let boxCount = room.boxCount {
                    Text("\(boxCount) box\(boxCount == 1 ? "" : "es")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

