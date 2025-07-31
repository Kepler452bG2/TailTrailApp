import SwiftUI
import MapKit

struct ActivityReportMapView: View {
    let posts: [Post]
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedStatus: PostStatus? = nil
    
    var body: some View {
        // Filter posts to only include those with valid coordinates
        let postsWithCoordinates = filteredPosts
        
        Map(position: $position) {
            ForEach(postsWithCoordinates) { post in
                if let coordinate = post.coordinate {
                    Annotation(post.petName ?? "Pet", coordinate: coordinate) {
                        MapAnnotationView(
                            isSelected: false,
                            status: PostStatus(rawValue: post.status) ?? .lost
                        )
                    }
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            // Status filter
            Menu {
                Button("All Posts") {
                    selectedStatus = nil
                }
                ForEach(PostStatus.allCases, id: \.self) { status in
                    Button(status.displayName) {
                        selectedStatus = status
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(selectedStatus?.displayName ?? "All Posts")
                    Image(systemName: "chevron.down")
                }
                .padding(8)
                .background(.regularMaterial)
                .clipShape(Capsule())
            }
            .padding()
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
    
    private var filteredPosts: [Post] {
        if let status = selectedStatus {
            return posts.filter { $0.coordinate != nil && $0.status == status.rawValue }
        } else {
            return posts.filter { $0.coordinate != nil }
        }
    }
}

struct ActivityReportMapView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityReportMapView(posts: [])
    }
} 