import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(session: ChatSession) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(session: session))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            messageList
            messageInputBar
        }
        .navigationTitle(viewModel.chatPartnerName)
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
        .onAppear { tabBarVisibility.isHidden = true }
        .onDisappear { tabBarVisibility.isHidden = false }
    }
    
    private var messageList: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
                .onChange(of: viewModel.messages.count) {
                    // Auto-scroll to the bottom on new message
                    if let lastMessageId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastMessageId, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    private var messageInputBar: some View {
        HStack(spacing: 16) {
            TextField("Message...", text: $viewModel.messageText)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.black, lineWidth: 1.5))
            
            Button(action: {
                viewModel.sendMessage()
            }) {
                Text("Send")
                    .fontWeight(.bold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .disabled(viewModel.messageText.isEmpty)
        }
        .padding()
        .background(Color.theme.background)
    }
}

// The view for a single message bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
            }
            
            Text(message.text)
                .padding(12)
                .background(message.isFromCurrentUser ? Color.blue : Color(white: 0.9))
                .foregroundColor(message.isFromCurrentUser ? .white : .black)
                .cornerRadius(16)
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
        .id(message.id) // Needed for ScrollViewReader
    }
}


#Preview {
    NavigationStack {
        ChatDetailView(session: MockData.chatSessions[0])
    }
    .environmentObject(TabBarVisibility())
    .preferredColorScheme(.dark)
} 