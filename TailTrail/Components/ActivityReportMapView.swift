import SwiftUI
import MapKit

struct ActivityReportMapView: View {
    
    @State private var cameraPosition: MapCameraPosition
    
    let posts: [Post]
    
    init(posts: [Post]) {
        self.posts = posts
        _cameraPosition = State(initialValue: .region(ActivityReportMapView.calculateRegion(for: posts)))
    }
    
    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(posts) { post in
                Marker("", coordinate: post.lastSeenLocation)
                    .tint(post.status == .lost ? .red : .green)
            }
        }
        .mapControls {
            // Hides all map controls for a cleaner look
        }
        .disabled(true) // Make the map non-interactive
        .frame(height: 200)
        .cornerRadius(20)
    }
    
    static func calculateRegion(for posts: [Post]) -> MKCoordinateRegion {
        guard !posts.isEmpty else {
            // Return a default region if there are no posts
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 43.2220, longitude: 76.8512),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
        
        var minLat = posts[0].lastSeenLocation.latitude
        var maxLat = posts[0].lastSeenLocation.latitude
        var minLon = posts[0].lastSeenLocation.longitude
        var maxLon = posts[0].lastSeenLocation.longitude
        
        for post in posts {
            minLat = min(minLat, post.lastSeenLocation.latitude)
            maxLat = max(maxLat, post.lastSeenLocation.latitude)
            minLon = min(minLon, post.lastSeenLocation.longitude)
            maxLon = max(maxLon, post.lastSeenLocation.longitude)
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        // Add some padding to the span - bigger multiplier means more zoom out
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 2.5, longitudeDelta: (maxLon - minLon) * 2.5)
        
        return MKCoordinateRegion(center: center, span: span)
    }
}


#Preview {
    ActivityReportMapView(posts: MockData.posts)
        .padding()
        .background(Color.theme.background)
        .preferredColorScheme(.dark)
} 