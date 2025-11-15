import SwiftUI

@main
struct HomeStorageApp: App {
    @StateObject private var configService = ConfigService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(configService)
        }
    }
}

