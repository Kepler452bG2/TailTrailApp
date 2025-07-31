import SwiftUI

struct AllPostsView: View {
    let posts: [Post]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var postService = PostService(authManager: AuthenticationManager())
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("All Posts Nearby")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(red: 0.98, green: 0.97, blue: 0.95))
                
                // Posts list
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(posts) { post in
                            NearbyPetCardView(post: post, postService: postService)
                                .frame(height: 244)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
        }
        .navigationBarHidden(true)
    }
} 