import SwiftUI

struct PetCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.petName ?? "Unknown Name")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(post.breed ?? "Unknown Breed")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                    Text(post.locationName ?? "Unknown Location")
                        .font(.system(size: 12))
                        .lineLimit(1)
                }
                .foregroundColor(.secondary)
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var imageSection: some View {
        AsyncImage(url: URL(string: post.images.first ?? "")) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 140)
                    .overlay(
                        ProgressView()
                            .tint(.gray)
                    )
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipped()
            case .failure(_):
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 140)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            Text("Image unavailable")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            @unknown default:
                EmptyView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    PetCardView(post: MockData.posts[0])
        .padding()
        .background(Color.gray.opacity(0.2)) // Add a background to the preview
} 