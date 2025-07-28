import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let chatId: String
    let sender: MessageSender
    let content: String
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case sender
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct MessageSender: Codable {
    let id: String
    let email: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case imageUrl = "image_url"
    }
} 