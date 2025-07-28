import SwiftUI
import CoreLocation

struct PostCardView: View {
    let post: Post
    @StateObject private var locationManager = LocationManager()
    
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
                        .frame(height: 100)
                        .overlay(
                            ProgressView()
                                .tint(.gray)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 100)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }

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
            .background(Color.white)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PostCardView(post: MockData.posts.first!)
        .padding()
} 