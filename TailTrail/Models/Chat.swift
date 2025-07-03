import Foundation
import SwiftUI

// Represents a single message within a chat
struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let timestamp: Date
    let isFromCurrentUser: Bool
}

// Represents a single chat conversation thread
struct ChatSession: Identifiable, Hashable {
    let id = UUID()
    let participantName: String
    let participantAvatar: String // Placeholder for image name
    var messages: [ChatMessage]
    
    var lastMessageSnippet: String {
        messages.last?.text ?? "No messages yet."
    }
    
    var lastMessageTimestamp: Date? {
        messages.last?.timestamp
    }
    
    // In a real app, this would be calculated based on read receipts
    var unreadCount: Int
    var isOnline: Bool
} 