import Foundation

struct Item: Codable, Identifiable {
    let id: String
    let boxId: String
    let name: String
    let description: String?
    let quantity: Int
    let tag: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case boxId = "box_id"
        case name
        case description
        case quantity
        case tag
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ItemLocation: Codable, Identifiable {
    let itemId: String
    let itemName: String
    let itemDescription: String?
    let quantity: Int
    let itemTag: String?
    let boxId: String
    let boxName: String?
    let floorName: String
    let roomName: String
    let rackName: String?
    
    var id: String { itemId }
    
    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case itemName = "item_name"
        case itemDescription = "item_description"
        case quantity
        case itemTag = "item_tag"
        case boxId = "box_id"
        case boxName = "box_name"
        case floorName = "floor_name"
        case roomName = "room_name"
        case rackName = "rack_name"
    }
}

struct ItemCreateRequest: Codable {
    let boxId: String
    let name: String
    let description: String?
    let quantity: Int
    let tag: String?
    
    enum CodingKeys: String, CodingKey {
        case boxId = "box_id"
        case name
        case description
        case quantity
        case tag
    }
}

struct ItemUpdateRequest: Codable {
    let name: String?
    let description: String?
    let quantity: Int?
    let tag: String?
}

