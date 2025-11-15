import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var configService: ConfigService
    @State private var apiURL: String = ""
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("API Configuration") {
                    HStack {
                        Text("Base URL")
                        Spacer()
                        TextField("http://192.168.1.75:3000", text: $apiURL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Button {
                        configService.apiBaseURL = apiURL.isEmpty ? Constants.defaultBaseURL : apiURL
                        showingSaveAlert = true
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Section("Application") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Framework")
                        Spacer()
                        Text("SwiftUI")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("About") {
                    Text("Home Storage Manager iOS App")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                apiURL = configService.apiBaseURL
            }
            .alert("Settings Saved", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("API URL has been updated")
            }
        }
    }
}

