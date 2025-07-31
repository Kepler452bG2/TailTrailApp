import SwiftUI

struct AllCasesListView: View {
    @EnvironmentObject var postService: PostService

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(postService.posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostCardView(post: post, postService: postService)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("All Recent Cases")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(Color.theme.primaryText)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.theme.background, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        AllCasesListView()
            .preferredColorScheme(.dark)
            .environmentObject(PostService(authManager: AuthenticationManager()))
    }
} 