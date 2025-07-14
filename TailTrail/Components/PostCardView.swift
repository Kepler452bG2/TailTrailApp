import SwiftUI

struct PostCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: post.images.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3) // Placeholder color
            }
            .frame(height: 150)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(post.petName ?? "Unknown Name")
                    .font(.headline)
                Text(post.locationName ?? "Unknown Location")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(8)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    PostCardView(post: MockData.posts.first!)
        .padding()
} 