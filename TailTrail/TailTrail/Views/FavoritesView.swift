import SwiftUI

struct FavoritesView: View {
    @ObservedObject var postService: PostService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .ignoresSafeArea()
                
                if postService.likedPosts.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No favorites yet")
                            .font(.custom("Poppins-SemiBold", size: 24))
                            .foregroundColor(.black)
                        
                        Text("Posts you like will appear here")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    // Favorites list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(postService.likedPosts) { post in
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    PostCardView(post: post, postService: postService)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image("backicon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .onAppear {
            postService.loadLikedPosts()
        }
    }
}

#Preview {
    FavoritesView(postService: PostService(authManager: AuthenticationManager()))
} 