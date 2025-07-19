import SwiftUI
import MapKit

struct ActivityReportMapView: View {
    let posts: [Post]
    
    // Compute the region to display
    private var region: MKCoordinateRegion {
        // Find the first valid coordinate to center the map on
        guard let firstCoordinate = posts.compactMap(\.coordinate).first else {
            // Return a default region if no posts have coordinates
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
        
        return MKCoordinateRegion(
            center: firstCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }

    var body: some View {
        // Filter posts to only include those with valid coordinates
        let postsWithCoordinates = posts.filter { $0.coordinate != nil }

        Map(coordinateRegion: .constant(region), annotationItems: postsWithCoordinates) { post in
            MapAnnotation(coordinate: post.coordinate!) { // Force-unwrap is safe here due to the filter above
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(post.status == PostStatus.lost.rawValue ? .red : .green)
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 2)
                    )
            }
        }
    }
}

struct ActivityReportMapView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityReportMapView(posts: MockData.posts)
    }
} 