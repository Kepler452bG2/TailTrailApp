import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var showingCreateChat = false
    @State private var chats: [Chat] = []
    @State private var newChatName = ""
    @State private var selectedParticipants: [String] = []
    
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("backicon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Image("messages")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                }
            }
            .background(Color.clear.ignoresSafeArea())
            .foregroundColor(Color.theme.primaryText)
            .onAppear {
                // Load chats from mock data for now
                loadChats()
            }
            .sheet(isPresented: $showingCreateChat) {
                createChatView
            }
        }
    }
    
    private var connectionStatusBar: some View {
        HStack {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text("Online")
                .font(.caption)
                .foregroundColor(.green)
            Spacer()
                    }
                    .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color.clear)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.black)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.custom("Poppins-Regular", size: 16))
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(red: 0.7, green: 0.9, blue: 0.9)) // Light teal like in image
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.black, lineWidth: 1)
        )
        .cornerRadius(25)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("No chats yet")
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(.gray)
            
            Text("Start conversation")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: { showingCreateChat = true }) {
                Image("startchat")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
        }
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
    
    private var createChatView: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Chat name input with SearchBar
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chat Name")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.black)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.black)
                        
                        TextField("Enter chat name", text: $newChatName)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("Poppins-Regular", size: 16))
                        
                        if !newChatName.isEmpty {
                            Button(action: { newChatName = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color(red: 0.7, green: 0.9, blue: 0.9)) // Light teal like SearchBar
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .cornerRadius(25)
                }
                .padding(.horizontal)
                
                // Participants selection (simplified for demo)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Participants")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.black)
                    
                    Text("Demo: Will add with first message")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Create button with createchat asset
                Button(action: createChat) {
                    Image("createchat")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color.clear.ignoresSafeArea()) // Like FeedView
            .navigationTitle("Create Chat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingCreateChat = false
                    newChatName = ""
                }
                .foregroundColor(.blue)
                .font(.custom("Poppins-Regular", size: 16))
            )
        }
    }
    
    private func createChat() {
        // Create a new chat (name can be empty, will be set when first message is sent)
        let chatName = newChatName.isEmpty ? "New Chat" : newChatName
        
        let newChat = Chat(
            id: UUID().uuidString,
            name: chatName,
            isGroup: false,
            createdAt: Date(),
            updatedAt: Date(),
            participants: [
                Chat.Participant(
                    id: UUID().uuidString,
                    email: "demo@example.com",
                    imageUrl: nil,
                    isOnline: true,
                    lastSeen: Date()
                )
            ],
            lastMessage: "Chat created",
            lastMessageTime: Date(),
            unreadCount: 0
        )
        
        // Add to chats array
        chats.append(newChat)
        
        // Reset form and close sheet
        newChatName = ""
        showingCreateChat = false
        
        print("✅ Chat created: \(newChat.name ?? "Unknown")")
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