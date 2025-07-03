import SwiftUI

struct NotificationRowView: View {
    let notification: AppNotification
    
    private var shadowColor: Color {
        switch notification.type {
        case .newMessage: return .blue.opacity(0.6)
        case .petFound, .newAlert: return .green.opacity(0.6)
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
                    .background(shadowColor.opacity(0.4))
                    .clipShape(Circle())
                    .foregroundColor(.black)

                VStack(alignment: .leading) {
                    Text(notification.description)
                        .fontWeight(.semibold)
                    Text(notification.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if let postID = notification.postID, let post = findPost(by: postID) {
                    NavigationLink(destination: PostDetailView(post: post)) {
                        Text("View").font(.headline)
                    }
                } else if let chatID = notification.chatID, let session = findChatSession(by: chatID) {
                    NavigationLink(destination: ChatDetailView(session: session)) {
                        Text("View").font(.headline)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.black, lineWidth: 1.5)
            )
        }
        .foregroundColor(.black)
    }
    
    private func findPost(by id: String) -> Post? {
        return MockData.posts.first { $0.id == id }
    }
    
    private func findChatSession(by id: String) -> ChatSession? {
        return MockData.chatSessions.first { $0.id.uuidString == id }
    }
}

#Preview {
    NotificationRowView(notification: MockData.notifications.first!)
        .padding()
} 