import SwiftUI

struct PostCardView: View {
    let post: Post
    let color: Color
    @State private var isLiked = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background shadow layer
            RoundedRectangle(cornerRadius: 25)
                .fill(color)
                .offset(x: 4, y: 4)

            // Main content body
            VStack(spacing: 0) {
                imageSection
                infoSection
        }
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.black, lineWidth: 1.5)
            )
            
            // Hole punch
            Circle()
                .fill(Color.white)
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(Color.black, lineWidth: 1.5))
                .offset(y: 8)
        }
    }
    
    private var imageSection: some View {
        Image(post.imageNames.first ?? "photo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 140)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(10)
            .overlay(
                // Like button
                Button(action: { isLiked.toggle() }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(isLiked ? .red : .white)
                        .padding(6)
                        .background(.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .position(x: 165, y: 25)
            )
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(post.locationName.split(separator: ",").first ?? "")
                    .font(.caption.bold())
                
                Text(post.status.rawValue.capitalized)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .overlay(Capsule().stroke(Color.black, lineWidth: 1.5))
            }
            
            Text(post.title)
                .font(.title3.bold())
                        .lineLimit(1)
                }
        .foregroundColor(.black)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .frame(height: 80, alignment: .top)
    }
}

#Preview {
    HStack {
        PostCardView(post: MockData.posts[0], color: .yellow.opacity(0.6))
        PostCardView(post: MockData.posts[1], color: .pink.opacity(0.6))
    }
        .padding()
    .background(Color.gray)
} 