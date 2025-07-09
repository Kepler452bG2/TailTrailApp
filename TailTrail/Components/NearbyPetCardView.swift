import SwiftUI

struct NearbyPetCardView: View {
    let post: Post
    
    var body: some View {
        ZStack {
            // Shadow layer that creates the "peel" effect
            AsymmetricCardShape()
                .fill(Color.black)
                .offset(x: -6, y: 6)
                .blur(radius: 1)

            // Main content layer with a colored background
            ZStack(alignment: .bottom) {
                // Background color that shows if image fails to load
                post.species.color

                // Image loading from local assets
                Image(post.imageNames.first ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                // Gradient overlay for text readability
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                Text(post.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(16)
            }
            .clipShape(AsymmetricCardShape())
            .overlay(
                AsymmetricCardShape()
                    .stroke(Color.black, lineWidth: 1.5)
            )
        }
    }
}

// Extension to provide a fallback color for each pet species
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