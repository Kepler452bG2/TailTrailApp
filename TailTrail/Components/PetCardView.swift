import SwiftUI

struct PetCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            imageSection
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.petName ?? "Unknown Name")
                    .font(.headline)
                    .foregroundColor(Color("PrimaryTextColor"))
                
                Text(post.breed ?? "Unknown Breed")
                    .font(.subheadline)
                    .foregroundColor(Color("SecondaryTextColor"))
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(post.locationName ?? "Unknown Location")
                }
                .font(.caption)
                .foregroundColor(Color("SecondaryTextColor"))
            }
            .padding([.horizontal, .bottom], 8)
        }
        .background(Color.background) // Use system background for better contrast
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay( // Add a border
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a shadow
    }
    
    private var imageSection: some View {
        AsyncImage(url: URL(string: post.images.first ?? "")) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(Color.gray.opacity(0.1))
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
            case .failure:
                Image(systemName: "photo.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(Color.gray.opacity(0.1))
            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    PetCardView(post: MockData.posts[0])
        .padding()
        .background(Color.gray.opacity(0.2)) // Add a background to the preview
} 