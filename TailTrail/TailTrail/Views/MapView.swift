import SwiftUI
import MapKit

// Default region if no posts are available
private let defaultRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 43.2220, longitude: 76.8512), // Almaty
    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
)

struct MapView: View {
    @EnvironmentObject var postService: PostService
    
    @State private var selectedPost: Post?
    @State private var cameraPosition: MapCameraPosition = .region(defaultRegion)

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $cameraPosition) {
                // Filter posts to only show those with valid coordinates
                ForEach(postService.posts.filter { $0.coordinate != nil }) { post in
                    Annotation(post.petName ?? "Pet", coordinate: post.coordinate!) {
                        MapAnnotationView(isSelected: selectedPost?.id == post.id)
                            .onTapGesture {
                                self.selectedPost = post
                            }
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                // When the map appears, center it on the first available post
                if let firstPostCoordinate = postService.posts.compactMap(\.coordinate).first {
                    cameraPosition = .region(MKCoordinateRegion(center: firstPostCoordinate, span: defaultRegion.span))
                }
            }
            
            // Show detail card if a post is selected
            if let post = selectedPost {
                MapDetailCardView(post: post, selectedPost: $selectedPost)
                    .padding()
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: selectedPost)
            }
        }
    }
}

// A view for the map pin
struct MapAnnotationView: View {
    let isSelected: Bool
    
    var body: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.title)
            .foregroundColor(isSelected ? .blue : .red)
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .shadow(radius: 5)
            .padding()
            .background(.regularMaterial, in: Circle())
    }
}

// A view for the card that appears when a pin is tapped
struct MapDetailCardView: View {
    let post: Post
    @Binding var selectedPost: Post?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(post.petName ?? "Unknown Pet")
                    .font(.title2.bold())
                Spacer()
                Button(action: { selectedPost = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            Text(post.description ?? "No description available.")
                .lineLimit(2)
            
            NavigationLink(destination: PostDetailView(post: post)) {
                Text("View Details")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let service = PostService(authManager: AuthenticationManager())
        service.posts = MockData.posts
        return MapView()
            .environmentObject(service)
    }
} 