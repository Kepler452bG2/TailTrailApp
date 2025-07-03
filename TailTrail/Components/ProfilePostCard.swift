import SwiftUI

struct ProfilePostCard: View {
    let post: Post
    let isBlackTheme: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(post.imageNames.first ?? "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                Spacer()
                
                Image(systemName: "ellipsis")
            }
            
            Spacer()
            
            Text(post.title)
                .font(.title2.bold())
            
            Text(post.breed)
                .font(.subheadline)
        }
        .padding()
        .frame(width: 180, height: 180)
        .background(isBlackTheme ? Color.black : Color.white)
        .foregroundColor(isBlackTheme ? Color.white : Color.black)
        .cornerRadius(24)
    }
}

#Preview {
    HStack {
        ProfilePostCard(post: MockData.posts[0], isBlackTheme: true)
        ProfilePostCard(post: MockData.posts[1], isBlackTheme: false)
    }
    .padding()
    .background(Color.gray)
} 