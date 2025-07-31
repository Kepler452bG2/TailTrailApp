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
    RecentCaseCardView(post: Post(
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
    .padding()
    .background(Color.theme.background)
    .preferredColorScheme(.dark)
} 