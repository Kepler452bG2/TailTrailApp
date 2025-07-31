import SwiftUI

struct ChatRowView: View {
    let chat: Chat
    let currentUserId: String
    
    private var otherParticipant: Chat.Participant? {
        chat.participants.first { $0.id != currentUserId }
    }
    
    private var participantName: String {
        otherParticipant?.email ?? "Unknown User"
    }

    private var shadowColor: Color {
        let colors: [Color] = [.blue.opacity(0.6), .green.opacity(0.6), .pink.opacity(0.6)]
        let hash = abs(participantName.hashValue)
        let index = hash % colors.count
        return colors[index]
    }

    var body: some View {
        ZStack {
            // Replicating the shadow effect from NotificationRowView with varied colors
            RoundedRectangle(cornerRadius: 25)
                .fill(shadowColor)
                .offset(x: 4, y: 4)

            HStack(spacing: 16) {
                // Avatar or placeholder
                if let imageUrl = otherParticipant?.imageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(participantName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if let lastMessage = chat.lastMessage {
                        Text(lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    } else {
                        Text("No messages yet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let timestamp = chat.lastMessageTime {
                        Text(timestamp.timeAgo())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(minWidth: 20)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
            .background(Color.white) // White card background
            .clipShape(RoundedRectangle(cornerRadius: 25)) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 4)
    }
}

// Helper for displaying relative time
extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    ChatRowView(
        chat: Chat(
            id: "sample-chat-id",
            name: "Sample Chat",
            isGroup: false,
            createdAt: Date(),
            updatedAt: Date(),
            participants: [
                Chat.Participant(
                    id: "user1",
                    email: "user1@example.com",
                    imageUrl: nil,
                    isOnline: true,
                    lastSeen: Date()
                ),
                Chat.Participant(
                    id: "user2",
                    email: "user2@example.com",
                    imageUrl: nil,
                    isOnline: false,
                    lastSeen: Date()
                )
            ],
            lastMessage: "Sample message",
            lastMessageTime: Date(),
            unreadCount: 0
        ),
        currentUserId: "user1"
    )
} 