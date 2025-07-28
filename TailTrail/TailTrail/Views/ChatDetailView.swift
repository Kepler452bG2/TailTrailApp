import SwiftUI
import Combine

struct ChatDetailView: View {
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var messages: [Message] = []
    @State private var messageText: String = ""
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var webSocketTask: URLSessionWebSocketTask?
    @Environment(\.presentationMode) var presentationMode
    
    let chat: Chat
    
    private var otherParticipant: Chat.Participant? {
        chat.participants.first { $0.id != authManager.currentUser?.id }
    }
    
    private var chatPartnerName: String {
        otherParticipant?.email ?? "Unknown User"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView("Loading messages...")
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task {
                            await loadMessages()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
            } else {
                messageList
                messageInputBar
            }
        }
        .navigationTitle(chatPartnerName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.orange)
                }
            }
        }
        .background(Color.theme.background.ignoresSafeArea())
        .foregroundColor(Color.theme.primaryText)
        .onAppear { 
            tabBarVisibility.isHidden = true
            Task {
                await loadMessages()
                await connectWebSocket()
            }
        }
        .onDisappear { 
            tabBarVisibility.isHidden = false
            disconnectWebSocket()
        }
    }
    
    private var messageList: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack {
                    ForEach(messages) { message in
                        MessageBubble(
                            text: message.content,
                            isFromCurrentUser: message.sender.id == authManager.currentUser?.id,
                            timestamp: message.createdAt
                        )
                    }
                }
                .padding()
                .onChange(of: messages.count) { oldCount, newCount in
                    // Auto-scroll to the bottom on new message
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    private var messageInputBar: some View {
        HStack {
            TextField("Type a message", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    sendMessage()
                }
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(messageText.isEmpty ? .gray : .orange)
            }
            .disabled(messageText.isEmpty)
        }
        .padding()
        .background(Color.theme.background)
    }
    
    private func loadMessages() async {
        isLoading = true
        errorMessage = nil
        
        guard let token = authManager.currentToken else {
            errorMessage = "Not authenticated"
            isLoading = false
            return
        }
        
        do {
            guard let url = URL(string: "\(Config.backendURL)/api/v1/messages/chats/\(chat.id)/messages") else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                // Custom date decoding
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    // Try different date formats
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    // Try without microseconds
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    // Try ISO8601
                    if let date = ISO8601DateFormatter().date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                
                messages = try decoder.decode([Message].self, from: data)
                print("✅ Loaded \(messages.count) messages")
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            print("❌ Failed to load messages: \(error)")
            errorMessage = "Failed to load messages"
        }
        
        isLoading = false
    }
    
    private func connectWebSocket() async {
        guard let token = authManager.currentToken,
              let userId = authManager.currentUser?.id,
              let url = URL(string: "\(Config.websocketURL)/api/v1/websocket/ws/\(userId)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        
        print("🔌 WebSocket connecting to: \(url)")
        
        // Send ping to keep connection alive
        sendPing()
        
        // Listen for messages
        receiveMessage()
    }
    
    private func sendPing() {
        guard let webSocketTask = webSocketTask else { return }
        
        // Send JSON ping message instead of native ping
        let pingMessage: [String: Any] = [
            "type": "ping",
            "data": [:] // Empty data object as server expects
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: pingMessage),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            webSocketTask.send(.string(jsonString)) { error in
                if let error = error {
                    print("❌ WebSocket ping error: \(error)")
                } else {
                    // Schedule next ping in 30 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                        self.sendPing()
                    }
                }
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let type = json["type"] as? String,
                       type == "new_message",
                       let messageData = json["data"] as? [String: Any] {
                        // Parse the message manually
                        if let chatId = messageData["chat_id"] as? String,
                           chatId == self.chat.id,
                           let content = messageData["content"] as? String,
                           let senderData = messageData["sender"] as? [String: Any],
                           let senderId = senderData["id"] as? String,
                           let senderEmail = senderData["email"] as? String {
                            
                            let newMessage = Message(
                                id: UUID().uuidString,
                                chatId: chatId,
                                sender: MessageSender(
                                    id: senderId,
                                    email: senderEmail,
                                    imageUrl: senderData["image_url"] as? String
                                ),
                                content: content,
                                createdAt: Date(),
                                updatedAt: nil
                            )
                            
                            DispatchQueue.main.async {
                                self.messages.append(newMessage)
                            }
                        }
                    }
                case .data:
                    break
                @unknown default:
                    break
                }
                
                // Continue listening
                self.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            }
        }
    }
    
    private func disconnectWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let content = messageText
        messageText = ""
        
        // Send via WebSocket
        let messageData: [String: Any] = [
            "type": "send_message",
            "data": [
                "chat_id": chat.id,
                "content": content
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: messageData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            webSocketTask?.send(.string(jsonString)) { error in
                if let error = error {
                    print("WebSocket send error: \(error)")
                }
            }
        }
    }
}

// Message bubble component
struct MessageBubble: View {
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading) {
                Text(text)
                    .padding()
                    .background(isFromCurrentUser ? Color.orange : Color.gray.opacity(0.2))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(20)
                
                Text(timestamp.timeAgo())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !isFromCurrentUser { Spacer() }
        }
        .id(UUID())
    }
}


#Preview {
    NavigationStack {
        ChatDetailView(chat: MockData.chats[0])
    }
    .environmentObject(TabBarVisibility())
    .environmentObject(AuthenticationManager())
    .preferredColorScheme(.dark)
} 