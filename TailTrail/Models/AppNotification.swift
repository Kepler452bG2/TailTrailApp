import SwiftUI

enum NotificationType {
    case petFound
    case newMessage
    case postLiked
    case newAlert
    
    var title: String {
        switch self {
        case .petFound: return "Pet Found Near You!"
        case .newMessage: return "New Message"
        case .postLiked: return "Post Liked"
        case .newAlert: return "New Lost Pet Alert"
        }
    }
    
    var iconName: String {
        switch self {
        case .petFound: return "dog.fill"
        case .newMessage: return "message.fill"
        case .postLiked: return "heart.fill"
        case .newAlert: return "exclamationmark.triangle.fill"
        }
    }
    
    var iconBackgroundColor: Color {
        switch self {
        case .petFound: return .green
        case .newMessage: return .blue
        case .postLiked: return .red
        case .newAlert: return .orange
        }
    }
}

struct AppNotification: Identifiable {
    let id = UUID()
    let type: NotificationType
    let description: String
    let timestamp: Date
    let isUnread: Bool
    
    // Contextual info
    let postID: String?
    let chatID: String?
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
} 