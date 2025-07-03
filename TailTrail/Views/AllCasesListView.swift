import SwiftUI

struct AllCasesListView: View {
    let posts: [Post]

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostCardView(post: post, color: .yellow.opacity(0.6))
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
        AllCasesListView(posts: MockData.posts)
            .preferredColorScheme(.dark)
    }
} 