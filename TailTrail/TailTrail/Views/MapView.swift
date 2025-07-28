import SwiftUI
import MapKit

// Default region if no posts are available
private let defaultRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 43.2220, longitude: 76.8512), // Almaty
    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
)

struct MapView: View {
    @EnvironmentObject var postService: PostService
    @StateObject private var locationManager = LocationManager()
    
    @State private var selectedPost: Post?
    @State private var cameraPosition: MapCameraPosition = .region(defaultRegion)
    @State private var showUserLocation = true

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $cameraPosition) {
                // User location
                if showUserLocation, let userLocation = locationManager.location {
                    Annotation("You", coordinate: userLocation.coordinate) {
                        Image(systemName: "location.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                            .background(Circle().fill(.white))
                    }
                }
                
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
                // Request location updates
                locationManager.requestLocationUpdate()
            }
            .onChange(of: locationManager.location) { oldValue, newLocation in
                // Center map on user location when it's first obtained
                if oldValue == nil, let location = newLocation {
                    let userRegion = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )
                    cameraPosition = .region(userRegion)
                }
            }
            .overlay(alignment: .topTrailing) {
                // Location button
                Button(action: centerOnUserLocation) {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .padding(12)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
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
    
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            let userRegion = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            withAnimation {
                cameraPosition = .region(userRegion)
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