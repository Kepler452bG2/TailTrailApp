import Foundation
import SwiftUI

struct AppNotification: Identifiable, Hashable {
    let id = UUID()
    let type: NotificationType
    let message: String
    let date: String
    let postID: String?
    let chatID: String?
    
    enum NotificationType: String {
        case petFound = "Pet Found"
        case newMessage = "New Message"
        case postLiked = "Post Liked"
        
        var iconName: String {
            switch self {
            case .petFound: return "pawprint.fill"
            case .newMessage: return "message.fill"
            case .postLiked: return "heart.fill"
            }
        }
        
        var iconColor: SwiftUI.Color {
            switch self {
            case .petFound: return .blue
            case .newMessage: return .green
            case .postLiked: return .pink
            }
        }
    }
} 