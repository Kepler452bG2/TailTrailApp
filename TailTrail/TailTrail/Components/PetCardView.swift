import SwiftUI
import CoreLocation

struct PetCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.petName ?? "Unknown Name")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                            .lineLimit(1)
                        
                        Text(post.breed ?? "Unknown Breed")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Status badge
                    Text(post.status == "lost" ? "LOST" : "FOUND")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            post.status == "lost" ? 
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.9, green: 0.3, blue: 0.3),
                                    Color(red: 1.0, green: 0.5, blue: 0.3)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.8, blue: 0.4),
                                    Color(red: 0.1, green: 0.7, blue: 0.6)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                    Text(post.locationName ?? "Unknown Location")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .lineLimit(1)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var imageSection: some View {
        AsyncImage(url: URL(string: post.images.first ?? "")) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.95, green: 0.97, blue: 1.0),
                                Color(red: 0.98, green: 0.98, blue: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.5))
                            Text("Image unavailable")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        }
                    )
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipped()
            case .failure(_):
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.1),
                                Color.pink.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(.purple.opacity(0.5))
                            Text("Image unavailable")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            @unknown default:
                EmptyView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    PetCardView(post: Post(
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
        lastSeenLocation: CLLocationCoordinate2D(latitude: 40.785091, longitude: -73.968285),
        description: "Sample description",
        contactPhone: "555-1234",
        userId: "sample-user",
        createdAt: Date(),
        updatedAt: Date(),
        likesCount: 0,
        isLiked: false,
        status: "lost"
    ))
    .padding()
    .background(Color.gray.opacity(0.2)) // Add a background to the preview
} 