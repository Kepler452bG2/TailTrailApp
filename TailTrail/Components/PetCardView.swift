import SwiftUI

struct PetCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(post.imageNames.first ?? "placeholder")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(post.petName)
                        .font(.headline.bold())
                        .foregroundColor(Color("PrimaryTextColor"))
                    Spacer()
                    Image(systemName: post.gender == .male ? "mars" : "venus")
                        .foregroundColor(.gray)
                }
                
                Text("\(post.ageCategory.rawValue.capitalized) | \(post.breed)")
                    .font(.subheadline)
                    .foregroundColor(Color("SecondaryTextColor"))
                
                HStack {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .background(Color("CardBackgroundColor"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    PetCardView(post: MockData.posts.first!)
        .padding()
        .background(Color("BackgroundColor"))
} 