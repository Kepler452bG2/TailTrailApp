import SwiftUI

struct ChatRowView: View {
    let session: ChatSession

    private var shadowColor: Color {
        let colors: [Color] = [.blue.opacity(0.6), .green.opacity(0.6), .pink.opacity(0.6)]
        let hash = abs(session.participantName.hashValue)
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
                Image(systemName: session.participantAvatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.participantName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(session.lastMessageSnippet)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let timestamp = session.lastMessageTimestamp {
                    Text(timestamp.timeAgo())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white) // White card background
            .clipShape(RoundedRectangle(cornerRadius: 25)) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.black, lineWidth: 1.5) // Black border
            )
        }
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
    ChatRowView(session: MockData.chatSessions.first!)
        .padding()
} 