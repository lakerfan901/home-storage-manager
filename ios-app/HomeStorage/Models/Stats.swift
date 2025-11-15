import Foundation

struct Stats: Codable {
    let totalBoxes: Int
    let totalItems: Int
    let totalRooms: Int
    
    enum CodingKeys: String, CodingKey {
        case totalBoxes
        case totalItems
        case totalRooms
    }
}

