import SwiftUI

struct MessagesView: View {
    @Binding var selectedTab: Int
    @State private var searchText = ""
    
    // Filtered chat sessions based on search text
    private var filteredSessions: [ChatSession] {
        if searchText.isEmpty {
            return MockData.chatSessions
        } else {
            return MockData.chatSessions.filter {
                $0.participantName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                VStack {
                    // Custom Header
                    HStack {
                        Button(action: { selectedTab = 0 }) {
                            Image(systemName: "chevron.left")
                                .font(.title2.bold())
                        }
                        Spacer()
                        Text("Messages")
                            .font(.title2.bold())
                        Spacer()
                    }
                    .padding()
                    .foregroundColor(.black)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: $searchText)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Chat List
                    List(filteredSessions) { session in
                        ZStack {
                            NavigationLink(destination: ChatDetailView(session: session)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            ChatRow(session: session)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Custom view for a single chat row
struct ChatRow: View {
    let session: ChatSession
    
    private var shadowColor: Color {
        let colors: [Color] = [.yellow, .pink, .blue, .green]
        let hash = abs(session.participantName.hashValue)
        return colors[hash % colors.count].opacity(0.7)
    }

    var body: some View {
        ZStack {
            // Colored shadow layer
            RoundedRectangle(cornerRadius: 25)
                .fill(shadowColor)
                .offset(x: 4, y: 4)

            // Main content layer
            HStack(spacing: 16) {
                avatar
                messageContent
                Spacer()
                statusIndicator
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.black, lineWidth: 1.5)
            )
        }
        .padding(.vertical, 4)
    }

    private var avatar: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: session.participantAvatar)
                .font(.system(size: 40))
                .foregroundColor(.black) // Black icon color
                .frame(width: 60, height: 60)
                .background(shadowColor.opacity(0.4)) // Lighter background
                .clipShape(Circle())
            
            if session.isOnline {
                Circle()
                    .fill(Color.green)
                    .frame(width: 15, height: 15)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
        }
    }

    private var messageContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.participantName)
                .font(.headline.bold())
            
            Text(session.messages.last?.text ?? "No messages yet")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
    
    private var statusIndicator: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text("23 Mins") // Placeholder
                .font(.caption)
                .foregroundColor(.gray)
            
            if session.unreadCount > 0 {
                Text("\(session.unreadCount)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

#Preview {
    MessagesView(selectedTab: .constant(2))
} 