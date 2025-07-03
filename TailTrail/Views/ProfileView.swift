import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var postService: PostService
    
    private var myPosts: [Post] {
        // Renamed from myPets for clarity
        Array(MockData.posts.prefix(4))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    UserProfileCard()
                        myPostsSection
                    }
                    .padding()
            }
                .background(Color.theme.background)
            .navigationBarHidden(true)
        }
    }
    
    private var myPostsSection: some View {
        VStack {
            HStack {
                Text("My Posts")
                    .font(.title2.bold())
                Spacer()
                Button("See all") {}
                    .font(.headline)
                    .foregroundColor(.gray)
        }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)]) {
                ForEach(myPosts) { pet in
                    MyPetCard(post: pet)
                }
                }
            }
        }
    }
    
// MARK: - Subviews for Profile

private struct MyPetCard: View {
    let post: Post
    
    private var shadowColor: Color {
        post.id.hashValue.isMultiple(of: 2) ? .pink.opacity(0.6) : .blue.opacity(0.6)
        }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(shadowColor)
                .offset(x: 4, y: 4)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                            Image(post.imageNames.first ?? "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                                .clipShape(Circle())
                    Spacer()
                    Image(systemName: "ellipsis")
                }
                
                Spacer()
                
                Text(post.title)
                    .font(.headline.bold())
                Text(post.breed)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(width: 160, height: 160)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.black, lineWidth: 1.5)
            )
        }
        .foregroundColor(.black)
            }
        }

private struct PetCareRow: View {
    let name: String
    let distance: Double
    let rating: Double
    
    var body: some View {
        HStack {
            Image(systemName: "pawprint.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
                .background(Color.black)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline.bold())
                HStack {
                    Image(systemName: "location.fill")
                    Text("\(String(format: "%.1f", distance)) km")
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", rating))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "ellipsis")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}

private struct CareServiceButton: View {
    let title: String
    
    var body: some View {
        Button(action: {}) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.gray.opacity(0.3)))
        }
        .foregroundColor(.black)
    }
}

#Preview {
        ProfileView()
    .environmentObject(PostService())
} 