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
            if isPrimary { // View Location
                guard let postId = notification.postID, let post = MockData.posts.first(where: { $0.id == postId }) else { return }
                path.append(post)
            } else { // Contact Owner
                guard let postId = notification.postID,
                      let post = MockData.posts.first(where: { $0.id == postId }),
                      let helper = MockData.topHelpers.first(where: { $0.id == post.userId }) else { return }
                path.append(helper)
            }
            
        case .newMessage:
            guard let chatId = notification.chatID, let session = MockData.chatSessions.first(where: { $0.id.uuidString == chatId }) else { return }
            path.append(session)
            
        case .postLiked:
            guard let postId = notification.postID, let post = MockData.posts.first(where: { $0.id == postId }) else { return }
            path.append(post)
        }
    }
} 