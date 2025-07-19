import SwiftUI

struct MessagesView: View {
    @State private var searchText = ""
    
    var filteredSessions: [ChatSession] {
        if searchText.isEmpty {
            return MockData.chatSessions
        } else {
            return MockData.chatSessions.filter {
                $0.participantName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // This is for programmatic navigation from other views
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                
                VStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $searchText)
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ZStack {
                        // Outline
                        Text("Chats").offset(x: 1, y: 1)
                        Text("Chats").offset(x: -1, y: -1)
                        Text("Chats").offset(x: -1, y: 1)
                        Text("Chats").offset(x: 1, y: -1)
                    }
                    .font(.largeTitle.bold())
                    .foregroundColor(.black)
                    .overlay(
                        Text("Chats")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                    )
                    
                    // Chat List
                    List(filteredSessions) { session in
                        ZStack {
                            NavigationLink(destination: ChatDetailView(session: session)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            ChatRowView(session: session)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
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