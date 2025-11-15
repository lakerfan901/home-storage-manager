import Foundation

struct Box: Codable, Identifiable {
    let id: String
    let nfcTagId: String
    let name: String?
    let description: String?
    let roomId: String?
    let rackId: String?
    let floorName: String?
    let roomName: String?
    let rackName: String?
    let locationType: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case nfcTagId = "nfc_tag_id"
        case name
        case description
        case roomId = "room_id"
        case rackId = "rack_id"
        case floorName = "floor_name"
        case roomName = "room_name"
        case rackName = "rack_name"
        case locationType = "location_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct BoxLocation: Codable, Identifiable {
    let boxId: String
    let nfcTagId: String
    let boxName: String?
    let floorName: String
    let roomName: String
    let rackName: String?
    let locationType: String
    
    var id: String { boxId }
    
    enum CodingKeys: String, CodingKey {
        case boxId = "box_id"
        case nfcTagId = "nfc_tag_id"
        case boxName = "box_name"
        case floorName = "floor_name"
        case roomName = "room_name"
        case rackName = "rack_name"
        case locationType = "location_type"
    }
}

struct BoxCreateRequest: Codable {
    let nfcTagId: String
    let name: String?
    let description: String?
    let roomId: String?
    let rackId: String?
    
    enum CodingKeys: String, CodingKey {
        case nfcTagId = "nfc_tag_id"
        case name
        case description
        case roomId = "room_id"
        case rackId = "rack_id"
    }
}

struct BoxUpdateRequest: Codable {
    let name: String?
    let description: String?
    let roomId: String?
    let rackId: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case roomId = "room_id"
        case rackId = "rack_id"
    }
}

struct BoxDetailResponse: Codable {
    let box: BoxLocation
    let items: [Item]
}

