import SwiftUI
import CoreLocation

struct PostDetailView: View {
    let post: Post
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var postService: PostService
    @State private var showFullScreenImage = false
    @State private var chatToNavigate: Chat? = nil
    @State private var isLiked: Bool
    @State private var isShowingReportDialog = false
    @State private var showReportConfirmation = false
    @State private var showBlockConfirmation = false
    
    // Enum for report reasons
    enum ReportReason: String, CaseIterable, Identifiable {
        case spam = "It's spam"
        case inappropriate = "Inappropriate content"
        case harassment = "Harassment or hateful speech"
        case scam = "Scam or fraud"
        case other = "Other"
        
        var id: String { self.rawValue }
    }
    
    init(post: Post) {
        self.post = post
        _isLiked = State(initialValue: post.isLiked)
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Light background like Jeremy screen
            Color(red: 0.98, green: 0.96, blue: 0.94).ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top Image
                    AsyncImage(url: URL(string: post.images.first ?? "")) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: max(UIScreen.main.bounds.height / 3, 200))
                    .clipped()
                    .onTapGesture { showFullScreenImage = true }

                    // Content Card in Jeremy style
                    contentCard
                        .background(Color.white)
                        .cornerRadius(30, corners: [.topLeft, .topRight])
                        .offset(y: -30)
                }
            }

            // Back button overlay in Jeremy style
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image("backicon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 50)
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.all, edges: .top)
        .navigationDestination(isPresented: .constant(chatToNavigate != nil)) {
            chatDestination
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImageView(imageNames: post.images)
        }
    }
    
    // MARK: - Subviews for Content Card
    
    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 25) {
            postHeader
            petStory
            postedByView
        }
        .padding(25)
    }

    private var postHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status and name like Jeremy
            VStack(alignment: .leading, spacing: 8) {
                Text("Missing \(post.species ?? "pet")")
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.secondary)
                Text(post.petName ?? "No Name")
                    .font(.custom("Poppins-Bold", size: 32))
                    .foregroundColor(.black)
            }
            
            // Tags like Jeremy (Retriever, Male, 2 years)
            HStack(spacing: 12) {
                tagView(text: post.breed ?? "Unknown", color: Color(red: 1.0, green: 0.8, blue: 0.6)) // Light orange
                tagView(text: post.gender ?? "Unknown", color: Color(red: 0.7, green: 0.9, blue: 0.9)) // Light teal
                tagView(text: post.age != nil ? String(format: "%.0f years", post.age! / 12) : "Unknown", color: Color(red: 1.0, green: 0.8, blue: 0.6)) // Light orange
            }
            
            // Location
            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(post.locationName ?? "Unknown location")
            }
            .font(.custom("Poppins-Regular", size: 16))
            .foregroundColor(.secondary)
        }
    }
    
    private func tagView(text: String, color: Color) -> some View {
        Text(text)
            .font(.custom("Poppins-Medium", size: 14))
            .foregroundColor(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }


    
    private var petStory: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pet Story")
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.black)
            
            Text("Hi, I'm \(post.petName ?? "a pet"):")
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(.black)
            
            Text(post.description ?? "No description provided.")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.secondary)
                .lineLimit(nil) // Allow full text like Jeremy
        }
    }



    private var postedByView: some View {
        VStack(spacing: 16) {
            // Chat button with chatmess asset
            Button(action: {
                // Navigate to chat with post creator
                if let userUUID = UUID(uuidString: post.userId) {
                    self.chatToNavigate = findOrCreateChatSession(with: userUUID)
                }
            }) {
                Image("chatmess")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var chatDestination: some View {
        if let chat = chatToNavigate {
            ChatDetailView(chat: chat)
                .environmentObject(authManager)
        } else {
            EmptyView()
        }
    }

    private func findOrCreateChatSession(with userId: UUID) -> Chat {
        // TODO: Implement chat creation and navigation
        // For now, create a temporary chat
        let participant = Chat.Participant(
            id: userId.uuidString,
            email: "user@example.com",
            imageUrl: nil,
            isOnline: false,
            lastSeen: nil
        )
        
        return Chat(
            id: UUID().uuidString,
            name: post.petName ?? "Chat",
            isGroup: false,
            createdAt: Date(),
            updatedAt: Date(),
            participants: [participant],
            lastMessage: nil,
            lastMessageTime: nil,
            unreadCount: 0
        )
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    PostDetailView(post: Post(
        id: UUID(),
        petName: "Sample Pet",
        species: "dog",
        breed: "Golden Retriever",
        age: 3,
        gender: "male",
        weight: 25.0,
        color: "Golden",
        images: [],
        locationName: "Sample Location",
        lastSeenLocation: CLLocationCoordinate2D(latitude: 40.785091, longitude: -73.968285),
        description: "Sample description for preview",
        contactPhone: "555-1234",
        userId: "sample-user",
        createdAt: Date(),
        updatedAt: Date(),
        likesCount: 0,
        isLiked: false,
        status: "lost"
    ))
} 