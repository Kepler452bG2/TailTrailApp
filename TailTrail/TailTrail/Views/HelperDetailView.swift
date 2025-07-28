import SwiftUI

struct HelperDetailView: View {
    let helper: Helper
    
    // Find all posts by this helper from the mock data
    private var helperPosts: [Post] {
        MockData.posts.filter { $0.userId == helper.id.uuidString }
    }
    
    // Find a chat session to navigate to. This is a simple simulation.
    private var chatSession: ChatSession? {
        MockData.chatSessions.first { $0.participantName.contains(helper.name) }
    }
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    profileHeader
                    
                    bioSection
                    
                    if !helperPosts.isEmpty {
                        postsSection
                    }
                }
                .padding()
            }
        }
        .navigationTitle(helper.name)
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(Color.theme.primaryText)
    }
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: helper.avatarName)
                .font(.system(size: 80))
                .foregroundColor(Color.theme.primaryText)
                .frame(width: 120, height: 120)
                .background(Color.theme.cardBackground)
                .clipShape(Circle())
                .shadow(radius: 10)
            
            Text("Hello! My name is \(helper.name).")
                .font(.largeTitle.bold())
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Rating")
                        .font(.caption)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", helper.rating))
                    }
                    .font(.headline)
                    .foregroundColor(Color.theme.secondaryText)
                }
                
                Spacer()
                
                if chatSession != nil {
                    // TODO: Convert session to Chat model
                    Button(action: {}) {
                        Text("Connect Me")
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color.theme.accent)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About Me")
                .font(.title2.bold())
            
            Text(helper.bio)
                .font(.body)
                .foregroundColor(Color.theme.secondaryText)
        }
    }
    
    private var postsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Posts")
                .font(.title2.bold())
            
            if helperPosts.isEmpty {
                Text("No posts found.")
                    .foregroundColor(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(helperPosts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            ProfilePostCard(post: post)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        HelperDetailView(helper: MockData.topHelpers[1])
            .preferredColorScheme(.dark)
    }
} 
