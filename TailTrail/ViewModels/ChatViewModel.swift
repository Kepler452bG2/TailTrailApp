import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    
    @Published var messages: [ChatMessage]
    @Published var messageText: String = ""
    
    let chatPartnerName: String
    
    init(session: ChatSession) {
        self.messages = session.messages
        self.chatPartnerName = session.participantName
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let newMessage = ChatMessage(
            text: messageText,
            timestamp: Date(),
            isFromCurrentUser: true
        )
        
        messages.append(newMessage)
        messageText = ""
        
        // Simulate a reply after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let replyMessage = ChatMessage(
                text: "Thanks! I'll check it out.",
                timestamp: Date(),
                isFromCurrentUser: false
            )
            self.messages.append(replyMessage)
        }
    }
} 