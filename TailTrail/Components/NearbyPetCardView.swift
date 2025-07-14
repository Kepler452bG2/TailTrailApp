import SwiftUI
import Kingfisher

struct NearbyPetCardView: View {
    let post: Post
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            if let url = post.imageURLs.first {
                KFImage(url)
                    .resizable()
                    .placeholder { Color.gray.opacity(0.3) }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 180)
            } else {
                // Fallback color with an icon
                ZStack {
                    post.speciesEnum.color
                    Image(systemName: post.speciesEnum.iconName)
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Gradient for text readability
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
            
            // Text Content
            VStack(alignment: .leading) {
                Spacer()
                Text(post.petName ?? "Unknown")
                    .font(.subheadline.bold())
                Text(post.status.capitalized)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding(10)
        }
        .frame(width: 140, height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}

// Extension to provide a fallback color and icon for each pet species
extension Post {
    var speciesEnum: PetSpecies {
        PetSpecies(rawValue: self.species ?? "other") ?? .other
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

#if DEBUG
struct NearbyPetCardView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyPetCardView(post: MockData.posts[1])
            .padding()
    }
}
#endif 