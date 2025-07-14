import SwiftUI

struct RecentCaseCardView: View {
    let post: Post
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: post.images.first ?? "")) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(post.petName ?? "Unknown Name")
                    .font(.headline)
                Text(post.status.capitalized)
                    .font(.subheadline)
                    .foregroundColor(post.status == PostStatus.lost.rawValue ? .red : .green)
            }
            Spacer()
        }
    }
}

#Preview {
    RecentCaseCardView(post: MockData.posts[0])
        .padding()
        .background(Color.theme.background)
        .preferredColorScheme(.dark)
} 