import SwiftUI

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
            Color(.systemGray6).ignoresSafeArea() // Use a subtle off-white background

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

                    // White Content Card
                    contentCard
                        .background(Color(.systemBackground))
                        .cornerRadius(30, corners: [.topLeft, .topRight])
                        .offset(y: -30)
                }
            }

            // Back button overlay
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.leading) // Added padding here
                .padding(.top)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.all, edges: .top)
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImageView(imageNames: post.images)
        }
    }
    
    // MARK: - Subviews for Content Card
    
    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 25) {
            postHeader
            detailsGrid
            petStory
            postedByView
        }
        .padding(25)
    }

    private var postHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Missing \(post.species ?? "pet")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(post.petName ?? "No Name")
                    .font(.largeTitle.bold())
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(post.locationName ?? "Unknown location")
                }.font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            actionButtons
        }
    }

    private var actionButtons: some View {
        HStack {
            // Like Button
            Button(action: {
                isLiked.toggle()
                // TODO: Call a service to update the backend.
            }) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? Color(hex: "#3E5A9A") : .gray) // Blue when liked
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .gray.opacity(0.3), radius: 5)
            }

            // Report and Block Menu
            Menu {
                Button {
                    isShowingReportDialog = true
                } label: {
                    Label("Report Post", systemImage: "exclamationmark.bubble")
                }
                
                Button(role: .destructive) {
                    Task {
                        do {
                            try await NetworkManager.shared.blockUser(userId: post.userId, authManager: authManager)
                            showBlockConfirmation = true
                        } catch {
                            print("❌ Failed to block user: \(error)")
                        }
                    }
                } label: {
                    Label("Block User", systemImage: "person.crop.circle.badge.xmark")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.primary)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .gray.opacity(0.3), radius: 5)
            }
        }
        .confirmationDialog("Report Post", isPresented: $isShowingReportDialog, titleVisibility: .visible) {
            ForEach(ReportReason.allCases) { reason in
                Button(reason.rawValue) {
                    Task {
                        do {
                            try await NetworkManager.shared.reportPost(postId: post.id.uuidString, reason: reason.rawValue, authManager: authManager)
                            showReportConfirmation = true
                        } catch {
                            // Optionally, show an error alert to the user
                            print("❌ Failed to submit report: \(error)")
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Thank You", isPresented: $showReportConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your report has been submitted and will be reviewed.")
        }
        .alert("User Blocked", isPresented: $showBlockConfirmation) {
            Button("OK", role: .cancel) {
                Task {
                    await postService.refreshPosts()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text("You will no longer see posts or receive messages from this user.")
        }
    }
    
    private var petStory: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pet Story").font(.title3.bold())
            Text(post.description ?? "No description provided.")
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(4)
        }
    }

    private var detailsGrid: some View {
        let details = [
            ("Age", post.age != nil ? String(format: "%.1f months", post.age!) : "N/A"),
            ("Breed", post.breed ?? "N/A"),
            ("Color", post.color ?? "N/A"),
            ("Weight", post.weight != nil ? String(format: "%.1f lb", post.weight!) : "N/A"),
            ("Gender", post.gender ?? "N/A")
        ]
        
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(Array(details.enumerated()), id: \.offset) { index, detail in
                infoBox(title: detail.0, value: detail.1, index: index)
            }
        }
    }

    private func infoBox(title: String, value: String, index: Int) -> some View {
        let colors = [Color(hex: "#22A6A2"), Color(hex: "#FBCF3A")] // Teal and Yellow
        let backgroundColor = colors[index % colors.count].opacity(0.8)
        
        return VStack {
            Text(title).font(.caption).foregroundColor(.white.opacity(0.9))
            Text(value)
                .font(.subheadline.weight(.heavy))
                .foregroundColor(.white)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .padding(8)
        .background(backgroundColor)
        .cornerRadius(12)
    }

    private var postedByView: some View {
        HStack {
            Image("dog1").resizable().aspectRatio(contentMode: .fill).frame(width: 50, height: 50).clipShape(Circle())
            Text("Nannie Barker").font(.subheadline.bold())
            Spacer()

            Button(action: {
                if let userUUID = UUID(uuidString: post.userId) {
                    self.chatToNavigate = findOrCreateChatSession(with: userUUID)
                }
            }) {
                Text("Contact Me")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#3E5A9A")) // Blue button
                    .clipShape(Capsule())
            }
            .navigationDestination(isPresented: .constant(chatToNavigate != nil)) {
                chatDestination
            }
        }
        .padding()
        .background(Color(white: 0.95))
        .cornerRadius(25)
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
    PostDetailView(post: MockData.posts.first!)
} 