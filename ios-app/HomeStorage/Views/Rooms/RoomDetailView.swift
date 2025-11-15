import SwiftUI

struct RoomDetailView: View {
    let roomId: String
    @StateObject private var apiService = APIService()
    @State private var roomDetail: RoomDetailResponse?
    @State private var isLoading = true
    @State private var showingAddBox = false
    @State private var editingBox: Box?
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if let detail = roomDetail {
                // Racks Section
                if !detail.racks.isEmpty {
                    Section("Storage Racks") {
                        ForEach(detail.racks) { rack in
                            HStack {
                                Image(systemName: "square.stack.3d.up.fill")
                                    .foregroundColor(.indigo)
                                Text(rack.name)
                                    .font(.headline)
                            }
                        }
                    }
                }
                
                // Boxes Section
                Section {
                    if detail.boxes.isEmpty {
                        Text("No boxes in this room yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(detail.boxes) { box in
                            NavigationLink(destination: BoxDetailView(boxId: box.id)) {
                                BoxListRow(box: box)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await deleteBox(box.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    editingBox = box
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Boxes")
                        Spacer()
                        Button {
                            showingAddBox = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
        }
        .navigationTitle(roomDetail?.room.name ?? "Room")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddBox) {
            if let room = roomDetail?.room {
                AddBoxForm(roomId: room.id) {
                    Task {
                        await loadRoomDetail()
                    }
                }
            }
        }
        .sheet(item: $editingBox) { box in
            EditBoxForm(box: box) {
                Task {
                    await loadRoomDetail()
                }
            }
        }
        .task {
            await loadRoomDetail()
        }
    }
    
    private func loadRoomDetail() async {
        isLoading = true
        do {
            roomDetail = try await apiService.fetchRoom(id: roomId)
        } catch {
            // Handle error
        }
        isLoading = false
    }
    
    private func deleteBox(_ id: String) async {
        do {
            try await apiService.deleteBox(id: id)
            await loadRoomDetail()
        } catch {
            // Handle error
        }
    }
}

struct BoxListRow: View {
    let box: Box
    
    var body: some View {
        HStack {
            Image(systemName: "archivebox.fill")
                .foregroundColor(.green)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(box.name ?? "Box \(String(box.nfcTagId.prefix(8)))")
                    .font(.headline)
                if let description = box.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Text("NFC: \(box.nfcTagId)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

