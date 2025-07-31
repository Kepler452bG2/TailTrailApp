import SwiftUI
import Kingfisher

struct NearbyPetCardView: View {
    let post: Post
    @ObservedObject var postService: PostService
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with pet photo
            VStack {
                HStack {
                    // Status button (Lost/Found)
                    Text(post.status.capitalized)
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.94, green: 0.76, blue: 0.90)) // Light pink background
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 0.5)
                        )
                    
                    Spacer()
                    
                    // Like icon in top-right - now clickable
                    Button(action: {
                        postService.toggleLike(for: post)
                    }) {
                        Image("likeicon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(postService.isLiked(post: post) ? .black : .white.opacity(0.6))
                    }
                    .zIndex(2) // Повышаем zIndex чтобы кнопка была поверх
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                
                Spacer()
            }
            .frame(height: 140)
            .background(
                // Pet photo background - using first image from images array
                KFImage(URL(string: post.images.first ?? ""))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 210, height: 140)
                    .clipped()
                    .scaleEffect(1.0) // Убираем масштабирование
                    .id(post.images.first ?? "") // Принудительное обновление
            )
            
            // Bottom orange section with left-aligned text
            VStack(alignment: .leading, spacing: 6) { // Changed to .leading
                VStack(alignment: .leading, spacing: 4) { // Changed to .leading
                    // Pet name
                    Text(post.petName ?? "Unknown Pet")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    // Pet breed
                    Text(post.species?.capitalized ?? "Unknown Breed")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    // Location and time
                    Text("Almaty • 30 Minute")
                        .font(.custom("Poppins-Regular", size: 10))
                        .foregroundColor(.black)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color(red: 0.99, green: 0.83, blue: 0.64)) // FED3A4 color
        }
        .frame(width: 210, height: 220)
        .background(Color(red: 0.99, green: 0.83, blue: 0.64)) // FED3A4 color
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

extension PetSpecies {
    var color: Color {
        switch self {
        case .dog: return .yellow.opacity(0.8)
        case .cat: return .pink.opacity(0.7)
        case .bird: return .cyan.opacity(0.6)
        case .other: return .purple.opacity(0.7)
        }
    }
}

#Preview {
    NearbyPetCardView(
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
} 