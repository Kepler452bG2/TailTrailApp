import SwiftUI

struct NotificationRowView: View {
    let notification: AppNotification
    
    private var shadowColor: Color {
        switch notification.type {
        case .newMessage: return .blue.opacity(0.6)
        case .petFound: return .green.opacity(0.6)
        case .postLiked: return .pink.opacity(0.6)
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(shadowColor)
                .offset(x: 4, y: 4)

            HStack(spacing: 16) {
                Image(systemName: notification.type.iconName)
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .background(notification.type.iconColor.opacity(0.2))
                    .clipShape(Circle())
                    .foregroundColor(notification.type.iconColor)

                VStack(alignment: .leading) {
                    Text(notification.message)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    Text(notification.date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if let postID = notification.postID, let post = findPost(by: postID) {
                    NavigationLink(destination: PostDetailView(post: post)) {
                        Text("View").font(.headline)
                    }
                } else if notification.chatID != nil {
                    // For now, we'll disable chat navigation from notifications
                    // TODO: Implement proper chat lookup from notification
                    Text("View")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color("CardBackgroundColor"))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .foregroundColor(Color("PrimaryTextColor"))
    }
    
    private func findPost(by id: String) -> Post? {
        // In real app, would fetch from PostService or API
        return nil
    }
}

#Preview {
    NotificationsView()
        .environmentObject(NotificationsViewModel())
} 