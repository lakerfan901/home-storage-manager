import SwiftUI

struct ContentView: View {
    @StateObject private var configService = ConfigService.shared
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BoxesListView()
                .tabItem {
                    Label("Boxes", systemImage: "archivebox.fill")
                }
            
            ItemsListView()
                .tabItem {
                    Label("Items", systemImage: "cube.box.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .environmentObject(configService)
    }
}

