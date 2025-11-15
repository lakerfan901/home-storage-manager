import Foundation
import Combine

class ConfigService: ObservableObject {
    static let shared = ConfigService()
    
    @Published var apiBaseURL: String {
        didSet {
            UserDefaults.standard.set(apiBaseURL, forKey: Constants.apiBaseURLKey)
        }
    }
    
    private init() {
        self.apiBaseURL = UserDefaults.standard.string(forKey: Constants.apiBaseURLKey) ?? Constants.defaultBaseURL
    }
    
    var fullAPIBaseURL: String {
        return "\(apiBaseURL)\(Constants.apiBasePath)"
    }
}

