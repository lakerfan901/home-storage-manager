import Foundation

struct Floor: Codable, Identifiable {
    let id: String
    let name: String
    let level: Int
    let roomCount: Int?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case level
        case roomCount = "room_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

