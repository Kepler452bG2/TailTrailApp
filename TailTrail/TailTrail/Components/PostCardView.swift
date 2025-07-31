import SwiftUI
import CoreLocation

struct PostCardView: View {
    let post: Post
    @StateObject private var locationManager = LocationManager()
    @ObservedObject var postService: PostService
    
    private var distanceText: String? {
        guard let userLocation = locationManager.location,
              let postCoordinate = post.coordinate else { return nil }
        
        let postLocation = CLLocation(latitude: postCoordinate.latitude, longitude: postCoordinate.longitude)
        let distance = userLocation.distance(from: postLocation) / 1000 // km
        
        if distance < 1 {
            return "\(Int(distance * 1000))m away"
        } else {
            return String(format: "%.1fkm away", distance)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            AsyncImage(url: URL(string: post.images.first ?? "")) { phase in
                switch phase {
                                    case .empty:
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(height: 100) // Уменьшаем высоту изображения еще больше
                            .overlay(
                                ProgressView()
                                    .tint(.gray)
                            )
                                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 100) // Уменьшаем высоту изображения еще больше
                            .clipped()
                            .scaleEffect(1.0) // Убираем масштабирование
                                    case .failure:
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(height: 100) // Уменьшаем высоту изображения еще больше
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            )
                @unknown default:
                    EmptyView()
                }
            }
            .id(post.images.first ?? "") // Принудительное обновление при изменении URL

            // Info section
            VStack(alignment: .leading, spacing: 4) {
                Text(post.petName ?? "Unknown Name")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                HStack(spacing: 2) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                    Text(post.breed ?? "Unknown breed")
                        .font(.system(size: 12))
                        .lineLimit(1)
                }
                .foregroundColor(.gray)
                
                // Show distance if available
                if let distance = distanceText {
                    HStack(spacing: 2) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(distance)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.orange)
                }
            }
            .padding(12)
            .background(Color.clear) // Убираем белый фон
        }
        .frame(height: 160) // Уменьшаем высоту карточки еще больше
        .background(Color.clear) // Убираем белый фон
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PostCardView(
        post: Post(
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
        ),
        postService: PostService(authManager: AuthenticationManager())
    )
    .padding()
} 