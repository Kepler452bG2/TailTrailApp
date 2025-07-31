import SwiftUI

@MainActor
class NotificationsViewModel: ObservableObject {
    
    @Published var notifications: [AppNotification] = []
    @Published var path = NavigationPath()
    @Published var shareableItem: ShareableItem?

    struct ShareableItem: Identifiable {
        let id = UUID()
        let text: String
    }
    
    func handleAction(for notification: AppNotification, isPrimary: Bool) {
        switch notification.type {
        case .petFound:
            // For now, just dismiss the notification
            // In real app, would fetch post from API
            break
            
        case .newMessage:
            // For now, just dismiss the notification
            // In real app, would fetch chat from API
            break
            
        case .postLiked:
            // For now, just dismiss the notification
            // In real app, would fetch post from API
            break
        }
    }
} 