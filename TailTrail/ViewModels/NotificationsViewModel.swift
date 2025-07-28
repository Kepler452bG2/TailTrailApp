import SwiftUI

@MainActor
class NotificationsViewModel: ObservableObject {
    
    @Published var notifications = MockData.notifications
    @Published var path = NavigationPath()
    @Published var shareableItem: ShareableItem?

    struct ShareableItem: Identifiable {
        let id = UUID()
        let text: String
    }
    
    func handleAction(for notification: AppNotification, isPrimary: Bool) {
        switch notification.type {
        case .petFound:
            guard let postId = notification.postID,
                  let post = MockData.posts.first(where: { $0.id.uuidString == postId }) else { return }
            // Navigate to post detail
            path.append(post)
            
        case .newMessage:
            guard let chatId = notification.chatID, let session = MockData.chatSessions.first(where: { $0.id.uuidString == chatId }) else { return }
            path.append(session)
            
        case .postLiked:
            guard let postId = notification.postID, let post = MockData.posts.first(where: { $0.id.uuidString == postId }) else { return }
            path.append(post)
        }
    }
} 