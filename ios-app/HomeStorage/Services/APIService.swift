import Foundation

class APIService: ObservableObject {
    private let configService: ConfigService
    
    init(configService: ConfigService = .shared) {
        self.configService = configService
    }
    
    private var baseURL: String {
        return configService.fullAPIBaseURL
    }
    
    // MARK: - Generic Request Method
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "APIService", code: -1))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let error = try? JSONDecoder().decode(APIError.self, from: data) {
                throw error
            }
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Stats
    
    func fetchStats() async throws -> Stats {
        return try await request(endpoint: "/stats")
    }
    
    // MARK: - Floors
    
    func fetchFloors() async throws -> [Floor] {
        return try await request(endpoint: "/floors")
    }
    
    func fetchFloor(id: String) async throws -> FloorDetailResponse {
        return try await request(endpoint: "/floors/\(id)")
    }
    
    // MARK: - Rooms
    
    func fetchRooms() async throws -> [Room] {
        return try await request(endpoint: "/rooms")
    }
    
    func fetchRoom(id: String) async throws -> RoomDetailResponse {
        return try await request(endpoint: "/rooms/\(id)")
    }
    
    func createRoom(_ room: RoomCreateRequest) async throws -> Room {
        return try await request(endpoint: "/rooms", method: "POST", body: room)
    }
    
    func updateRoom(id: String, _ room: RoomUpdateRequest) async throws -> Room {
        return try await request(endpoint: "/rooms/\(id)", method: "PATCH", body: room)
    }
    
    func deleteRoom(id: String) async throws {
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await request(endpoint: "/rooms/\(id)", method: "DELETE")
    }
    
    // MARK: - Boxes
    
    func fetchBoxes() async throws -> [BoxLocation] {
        return try await request(endpoint: "/boxes")
    }
    
    func fetchBoxByNFC(nfcTagId: String) async throws -> BoxLocation {
        return try await request(endpoint: "/boxes?nfc_tag_id=\(nfcTagId)")
    }
    
    func fetchBox(id: String) async throws -> BoxDetailResponse {
        return try await request(endpoint: "/boxes/\(id)")
    }
    
    func createBox(_ box: BoxCreateRequest) async throws -> Box {
        return try await request(endpoint: "/boxes", method: "POST", body: box)
    }
    
    func updateBox(id: String, _ box: BoxUpdateRequest) async throws -> Box {
        return try await request(endpoint: "/boxes/\(id)", method: "PATCH", body: box)
    }
    
    func deleteBox(id: String) async throws {
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await request(endpoint: "/boxes/\(id)", method: "DELETE")
    }
    
    // MARK: - Items
    
    func fetchItems(tag: String? = nil, boxId: String? = nil) async throws -> [ItemLocation] {
        var endpoint = "/items"
        var queryItems: [String] = []
        
        if let tag = tag {
            queryItems.append("tag=\(tag)")
        }
        if let boxId = boxId {
            queryItems.append("box_id=\(boxId)")
        }
        
        if !queryItems.isEmpty {
            endpoint += "?" + queryItems.joined(separator: "&")
        }
        
        return try await request(endpoint: endpoint)
    }
    
    func fetchItem(id: String) async throws -> ItemLocation {
        return try await request(endpoint: "/items/\(id)")
    }
    
    func createItem(_ item: ItemCreateRequest) async throws -> Item {
        return try await request(endpoint: "/items", method: "POST", body: item)
    }
    
    func updateItem(id: String, _ item: ItemUpdateRequest) async throws -> Item {
        return try await request(endpoint: "/items/\(id)", method: "PATCH", body: item)
    }
    
    func deleteItem(id: String) async throws {
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await request(endpoint: "/items/\(id)", method: "DELETE")
    }
}

struct FloorDetailResponse: Codable {
    let floor: Floor
    let rooms: [Room]
}

