import SwiftUI

struct FullScreenImageView: View {
    let imageNames: [String] // This should be 'images' to be consistent, but let's just fix the call site.
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            
            TabView {
                ForEach(imageNames, id: \.self) { name in
                    if let url = URL(string: name) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure, .empty:
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(name) // Fallback for local asset names
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title2.bold())
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .padding()
        }
    }
}

#Preview {
    FullScreenImageView(
        imageNames: MockData.posts[0].images
    )
} 