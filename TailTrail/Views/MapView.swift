import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var selectedPost: Post?
    @State private var isSearchActive = false
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.2220, longitude: 76.8512), // Almaty
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    ))

    var body: some View {
        ZStack {
            mapComponent
                .onChange(of: viewModel.selectedFilter) {
                    // When filter changes, hide the filter view
                    viewModel.isFilterViewPresented = false
                }
            
            VStack {
                topBar
                Spacer()
            }
            
            if viewModel.isFilterViewPresented {
                filterPanelView
            }
            
            if let post = selectedPost {
                MapDetailCardView(
                    post: post,
                    distance: distance(to: post),
                    selectedPost: $selectedPost
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: selectedPost)
        .animation(.bouncy, value: viewModel.isFilterViewPresented)
        .animation(.bouncy, value: isSearchActive)
        .preferredColorScheme(.dark)
    }

    private var mapComponent: some View {
        Map(position: $cameraPosition, selection: $selectedPost) {
            ForEach(viewModel.filteredPosts) { post in
                Annotation(post.title, coordinate: post.coordinate) {
                        PulsingMapPin(status: post.status, isSelected: selectedPost == post)
                            .scaleEffect(selectedPost == post ? 1.2 : 1.0)
                            .animation(.spring(), value: selectedPost)
                        .onTapGesture {
                            selectedPost = post
                    }
                }
                .tag(post)
            }
        }
        .ignoresSafeArea()
    }

    private var topBar: some View {
        HStack {
            if isSearchActive {
                searchBar
            } else {
                defaultTopBarButtons
            }
        }
        .padding()
        .foregroundColor(.white)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search by name, breed...", text: $viewModel.searchText)
                .autocorrectionDisabled()
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                }
            }
            
            Button("Cancel") {
                isSearchActive = false
                viewModel.searchText = ""
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
    
    private var defaultTopBarButtons: some View {
        HStack {
            Button(action: { viewModel.isFilterViewPresented.toggle() }) {
                Image(systemName: "line.3.horizontal.decrease")
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            
            Spacer()

            Button(action: { isSearchActive = true }) { Image(systemName: "magnifyingglass") }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .transition(.move(edge: .leading).combined(with: .opacity))

            Button(action: { centerOnUserLocation() }) { Image(systemName: "location.fill") }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
    
    private func centerOnUserLocation() {
        guard let userLocation = locationManager.location else {
            // If location is not available, you might want to request it again
            locationManager.requestLocation()
            return
        }
        withAnimation(.smooth) {
            cameraPosition = .region(MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }
    
    private var filterPanelView: some View {
        VStack(spacing: 12) {
            // First row of filters
            HStack {
                MapFilterCapsule(text: "All", filter: .all, selection: $viewModel.selectedFilter)
                MapFilterCapsule(text: "Lost", filter: .status(.lost), selection: $viewModel.selectedFilter)
                MapFilterCapsule(text: "Found", filter: .status(.found), selection: $viewModel.selectedFilter)
            }
            // Second row of filters
            HStack {
                MapFilterCapsule(text: "Dogs", filter: .species(.dog), selection: $viewModel.selectedFilter)
                MapFilterCapsule(text: "Cats", filter: .species(.cat), selection: $viewModel.selectedFilter)
                MapFilterCapsule(text: "Birds", filter: .species(.bird), selection: $viewModel.selectedFilter)
            }
            // Third row
            MapFilterCapsule(text: "Recent", filter: .recent, selection: $viewModel.selectedFilter)
            
            Divider().background(.gray)
            
            // Summary
            HStack {
                HStack {
                    Circle().fill(.red).frame(width: 8, height: 8)
                    Text("\(viewModel.lostCount) Lost")
                }
                Spacer()
                HStack {
                    Circle().fill(.green).frame(width: 8, height: 8)
                    Text("\(viewModel.foundCount) Found")
                }
            }
            .font(.caption)
            .foregroundColor(.white)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal, 40)
        .shadow(radius: 10)
        .transition(.scale.combined(with: .opacity))
    }

    private func distance(to post: Post) -> String? {
        guard let userLocation = locationManager.location else { return nil }
        let postLocation = CLLocation(latitude: post.coordinate.latitude, longitude: post.coordinate.longitude)
        let distanceInMeters = userLocation.distance(from: postLocation)
        
        let formatter = LengthFormatter()
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter.string(fromMeters: distanceInMeters)
    }
}

// Custom view for the map filter capsules
struct MapFilterCapsule: View {
    let text: String
    let filter: MapViewModel.MapFilter
    @Binding var selection: MapViewModel.MapFilter
    
    private var isSelected: Bool {
        filter == selection
    }
    
    var body: some View {
        Button(action: { selection = filter }) {
            Text(text)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(isSelected ? Color.blue : Color.black.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

// Custom view for the pulsing map annotation
struct PulsingMapPin: View {
    let status: PostStatus
    let isSelected: Bool
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill((status == .lost ? Color.red : Color.green).opacity(0.3))
                .frame(width: 40, height: 40)
                .scaleEffect(isPulsing ? 1.5 : 1.0)
                .opacity(isPulsing ? 0 : 1)
            
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundStyle(status == .lost ? .red : .green, Color.theme.background)
                .background(.white)
                .clipShape(Circle())
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }
}

// The card that slides up from the bottom
struct MapDetailCardView: View {
    let post: Post
    let distance: String?
    @Binding var selectedPost: Post?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(post.status.rawValue)
                    .fontWeight(.bold)
                    .foregroundColor(post.status == .lost ? .red : .green)
                if let distance = distance {
                    Text("· \(distance) away")
                        .foregroundColor(.secondary)
                }
                Text("· \(post.timeAgo)")
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    withAnimation {
                        selectedPost = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(post.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(post.locationName)
                .font(.subheadline)
            
            Text(post.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 16) {
                Button(action: {}) {
                    Text("Call")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.secondaryText.opacity(0.3))
                        .cornerRadius(12)
                }
                
                Button(action: {}) {
                    Text("Message")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.accent)
                        .cornerRadius(12)
                }
            }
            .foregroundColor(.white)
        }
        .padding(20)
        .background(Color.theme.cardBackground)
        .cornerRadius(24)
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
}

#Preview {
    MapView()
} 