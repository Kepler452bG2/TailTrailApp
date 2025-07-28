import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var searchText = ""
    @State private var showingCreateChat = false
    @State private var chats: [Chat] = []
    
    var filteredChats: [Chat] {
        if searchText.isEmpty {
            return chats
        } else {
            return chats.filter { chat in
                chat.name?.localizedCaseInsensitiveContains(searchText) ?? false ||
                chat.participants.contains { participant in
                    participant.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Connection status
                connectionStatusBar
                

                
                // Search bar
                searchBar
                
                // Chat list
                if chats.isEmpty {
                    emptyStateView
                } else {
                    chatListView
                }
            }
            .navigationTitle(languageManager.localizedString(forKey: "messages"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Temporarily hidden until chat creation is implemented
                    /*
                    Button(action: { showingCreateChat = true }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.orange)
                    }
                    */
                }
            }
            .background(Color.theme.background.ignoresSafeArea())
            .foregroundColor(Color.theme.primaryText)
            .onAppear {
                // Load chats from mock data for now
                loadChats()
            }
            .alert("Create Chat", isPresented: $showingCreateChat) {
                Button("Cancel", role: .cancel) { }
                Button("Create") {
                    // TODO: Implement chat creation
                    print("Create chat functionality not implemented yet")
                }
            } message: {
                Text("Chat creation feature is coming soon!")
                    }
        }
    }
    
    private var connectionStatusBar: some View {
        HStack {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text("Connected")
                .font(.caption)
                .foregroundColor(.green)
            Spacer()
                    }
                    .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color.theme.background)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(languageManager.localizedString(forKey: "search_chats"), text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(25)
                    .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.black, lineWidth: 1.5)
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(languageManager.localizedString(forKey: "no_chats_yet"))
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text(languageManager.localizedString(forKey: "start_conversation"))
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: { showingCreateChat = true }) {
                Text(languageManager.localizedString(forKey: "start_chat"))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var chatListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredChats) { chat in
                    NavigationLink(destination: ChatDetailView(chat: chat)
                        .environmentObject(authManager)) {
                        WebSocketChatRowView(chat: chat)
                        }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadChats() {
        // For now, use empty array. In a real app, this would load from API
        chats = []
    }
}

// MARK: - Chat Row View for WebSocket Chats
struct WebSocketChatRowView: View {
    let chat: Chat
    
    private var shadowColor: Color {
        let colors: [Color] = [.blue.opacity(0.6), .green.opacity(0.6), .pink.opacity(0.6)]
        let hash = abs(chat.id.hashValue)
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
                avatar
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chat.name ?? chat.participants.first?.email ?? "Unknown")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(chat.lastMessage ?? "No messages yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let lastMessageTime = chat.lastMessageTime {
                        Text(formatDate(lastMessageTime))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
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

    private var avatar: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
                .clipShape(Circle())
            
            if chat.participants.contains(where: { $0.isOnline }) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 15, height: 15)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
            let calendar = Calendar.current
            
            if calendar.isDateInToday(date) {
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: date)
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                formatter.dateFormat = "MMM dd"
                return formatter.string(from: date)
            }
    }
}

#Preview {
    MessagesView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(AuthenticationManager.shared)
        .preferredColorScheme(.dark)
} 