import SwiftUI

struct DashboardView: View {
    @StateObject private var apiService = APIService()
    @StateObject private var nfcService = NFCService()
    @State private var stats = Stats(totalBoxes: 0, totalItems: 0, totalRooms: 0)
    @State private var floors: [Floor] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingNFCScan = false
    @State private var scannedBoxId: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Stats Cards
                    HStack(spacing: 12) {
                        StatCard(title: "Rooms", value: stats.totalRooms, color: .blue)
                        StatCard(title: "Boxes", value: stats.totalBoxes, color: .green)
                        StatCard(title: "Items", value: stats.totalItems, color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Error Banner
                    if let error = errorMessage {
                        ErrorBanner(message: error)
                            .padding(.horizontal)
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            QuickActionButton(
                                title: "Scan NFC",
                                icon: "waveform",
                                color: .blue
                            ) {
                                showingNFCScan = true
                            }
                            
                            NavigationLink(destination: BoxesListView()) {
                                QuickActionButtonContent(
                                    title: "View Boxes",
                                    icon: "archivebox",
                                    color: .green
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Floors Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Floors")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if floors.isEmpty {
                            EmptyStateView(
                                icon: "building.2",
                                message: "No floors found"
                            )
                            .padding()
                        } else {
                            ForEach(floors) { floor in
                                NavigationLink(destination: FloorDetailView(floor: floor)) {
                                    FloorRow(floor: floor)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home Storage")
            .refreshable {
                await loadData()
            }
            .task {
                await loadData()
            }
            .sheet(isPresented: $showingNFCScan) {
                NFCScanView(scannedBoxId: $scannedBoxId)
            }
            .onChange(of: scannedBoxId) { newValue in
                if let boxId = newValue {
                    // Navigate to box detail
                    scannedBoxId = nil
                }
            }
        }
    }
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        async let statsTask = apiService.fetchStats()
        async let floorsTask = apiService.fetchFloors()
        
        do {
            stats = try await statsTask
            floors = try await floorsTask
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct StatCard: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            QuickActionButtonContent(title: title, icon: icon, color: color)
        }
    }
}

struct QuickActionButtonContent: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
            Text(title)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(12)
    }
}

struct FloorRow: View {
    let floor: Floor
    
    var body: some View {
        HStack {
            Image(systemName: "layers.fill")
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(floor.name.capitalized)
                    .font(.headline)
                if let roomCount = floor.roomCount {
                    Text("\(roomCount) room\(roomCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red)
        .cornerRadius(8)
    }
}

struct EmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

