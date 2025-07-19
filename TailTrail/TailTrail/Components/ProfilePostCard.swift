import SwiftUI

struct ProfilePostCard: View {
    let post: Post
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: post.images.first ?? "")) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .aspectRatio(contentMode: .fill)
            .frame(height: 100)
            .clipped()
            
            Text(post.petName ?? "Unknown")
                .font(.caption)
                .padding(8)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    HStack {
        ProfilePostCard(post: MockData.posts[0])
        ProfilePostCard(post: MockData.posts[1])
    }
    .padding()
    .background(Color.gray)
} 