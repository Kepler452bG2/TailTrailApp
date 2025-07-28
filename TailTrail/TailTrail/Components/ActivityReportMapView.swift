import SwiftUI
import MapKit

struct ActivityReportMapView: View {
    let posts: [Post]
    
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        // Filter posts to only include those with valid coordinates
        let postsWithCoordinates = posts.filter { $0.coordinate != nil }
        
        Map(position: $position) {
            ForEach(postsWithCoordinates) { post in
                if let coordinate = post.coordinate {
                    Annotation(post.petName ?? "Pet", coordinate: coordinate) {
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
        .onAppear {
            // Set initial camera position
            if let firstCoordinate = posts.compactMap(\.coordinate).first {
                position = .region(MKCoordinateRegion(
                    center: firstCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                ))
            }
        }
    }
}

struct ActivityReportMapView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityReportMapView(posts: MockData.posts)
    }
} 