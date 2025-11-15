import Foundation

struct Room: Codable, Identifiable {
    let id: String
    let floorId: String
    let name: String
    let description: String?
    let floorName: String?
    let floorLevel: Int?
    let boxCount: Int?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case floorId = "floor_id"
        case name
        case description
        case floorName = "floor_name"
        case floorLevel = "floor_level"
        case boxCount = "box_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct RoomCreateRequest: Codable {
    let floorId: String
    let name: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case floorId = "floor_id"
        case name
        case description
    }
}

struct RoomUpdateRequest: Codable {
    let name: String?
    let description: String?
}

struct RoomDetailResponse: Codable {
    let room: Room
    let racks: [Rack]
    let boxes: [Box]
}

struct Rack: Codable, Identifiable {
    let id: String
    let roomId: String
    let name: String
    let description: String?
    let position: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomId = "room_id"
        case name
        case description
        case position
    }
}

