import Foundation
import SwiftUI

// API-compatible Chat model
struct Chat: Identifiable, Codable {
    let id: String
    let name: String?
    let isGroup: Bool
    let createdAt: Date
    let updatedAt: Date
    let participants: [Participant]
    let lastMessage: String?
    let lastMessageTime: Date?
    let unreadCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isGroup = "is_group"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case participants
        case lastMessage = "last_message"
        case lastMessageTime = "last_message_time"
        case unreadCount = "unread_count"
    }
    
    struct Participant: Codable {
        let id: String
        let email: String
        let imageUrl: String?
        let isOnline: Bool
        let lastSeen: Date?  // Made optional since it can be null
        
        enum CodingKeys: String, CodingKey {
            case id
            case email
            case imageUrl = "image_url"
            case isOnline = "is_online"
            case lastSeen = "last_seen"
        }
    }
}

// Legacy models for MockData compatibility
struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let timestamp: Date
    let isFromCurrentUser: Bool
}

struct ChatSession: Identifiable, Hashable {
    let id = UUID()
    let participantName: String
    let participantAvatar: String
    var messages: [ChatMessage]
    
    var lastMessageSnippet: String {
        messages.last?.text ?? "No messages yet."
    }
    
    var lastMessageTimestamp: Date? {
        messages.last?.timestamp
    }
    
    var unreadCount: Int
    var isOnline: Bool
} 