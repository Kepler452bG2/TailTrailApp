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
        ProfilePostCard(post: Post(
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
            lastSeenLocation: nil,
            description: "Sample description",
            contactPhone: "123-456-7890",
            userId: "sample-user",
            createdAt: Date(),
            updatedAt: Date(),
            likesCount: 0,
            isLiked: false,
            status: "lost"
        ))
    }
    .padding()
    .background(Color.gray)
} 