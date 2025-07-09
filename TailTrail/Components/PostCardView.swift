import SwiftUI

struct PostCardView: View {
    let post: Post
    let color: Color

    var body: some View {
        // The inner white card content
        VStack(spacing: 0) {
            Image(post.imageNames.first ?? "placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .mask(
                    // Mask to give the image rounded top corners but sharp bottom corners
                    RoundedRectangle(cornerRadius: 22)
                        .padding(.bottom, -10) // Hides the bottom rounded corners
                )

            // Text content area
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(post.locationName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(post.status.rawValue.capitalized)
                        .font(.caption2.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .overlay(Capsule().stroke(Color.black, lineWidth: 1))
                }
                
                    Text(post.title)
                    .font(.headline.bold())
                    
                    Text(post.breed)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
            }
            .padding()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .padding(8) // This padding creates the outer colored border
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay(
            // The decorative "tag hole" at the top
            Circle()
                .fill(color)
                .overlay(Circle().stroke(.black, lineWidth: 1.5))
                .frame(width: 16, height: 16)
                .offset(y: -8),
            alignment: .top
        )
        .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
    }
}

#Preview {
    PostCardView(post: MockData.posts.first!, color: .pink.opacity(0.4))
        .padding()
} 