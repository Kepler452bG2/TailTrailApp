import SwiftUI
import MapKit
import UserNotifications

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
    @State private var selectedStatus: PostStatus? = nil
    @State private var isLiveModeEnabled = true
    @State private var nearbyRadius: Double = 5.0 // km

    
    // Timer for live updates
    @State private var updateTimer: Timer?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mapView
            filterControls
            detailCard
        }
    }
    
    private var mapView: some View {
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
            
            // Posts
            ForEach(filteredPosts) { post in
                Annotation(post.petName ?? "Pet", coordinate: post.coordinate!) {
                    MapAnnotationView(
                        isSelected: selectedPost?.id == post.id,
                        status: PostStatus(rawValue: post.status) ?? .lost
                    )
                    .onTapGesture {
                        selectedPost = post
                        
                        // Zoom to the selected post
                        withAnimation(.easeInOut(duration: 0.5)) {
                            let postRegion = MKCoordinateRegion(
                                center: post.coordinate!,
                                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                            )
                            cameraPosition = .region(postRegion)
                        }
                        
                        if isNearby(post: post) {
                            sendNearbyNotification(for: post)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            locationManager.requestLocationUpdate()
            startLiveUpdates()
            requestNotificationPermission()
        }
        .onDisappear {
            stopLiveUpdates()
        }
        .onChange(of: locationManager.location) { oldValue, newLocation in
            if oldValue == nil, let location = newLocation {
                let userRegion = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
                cameraPosition = .region(userRegion)
            }
        }
        .overlay(alignment: .topTrailing) {
            mapControls
        }
    }
    

    

    

    private var filterControls: some View {
        VStack {
            // Status filter buttons
            HStack(spacing: 30) {
                // All Posts button with menu
                Menu {
                    Button("All Posts") { selectedStatus = nil }
                    ForEach(PostStatus.allCases, id: \.self) { status in
                        Button(status.displayName) { selectedStatus = status }
                    }
                } label: {
                    Image("allposts")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(selectedStatus == nil ? .blue : .gray)
                }
                
                Spacer()
                
                // Location icon only
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.5)) {
                        let userRegion = MKCoordinateRegion(
                            center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 43.238949, longitude: 76.889709),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                        cameraPosition = .region(userRegion)
                    }
                }) {
                    Image(systemName: "location.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                        .background(Circle().fill(.white))
                        .shadow(radius: 2)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 60)
    }
    
    private var mapControls: some View {
        VStack(spacing: 12) {
            Button(action: toggleLiveMode) {
                HStack(spacing: 4) {
                    Image(systemName: isLiveModeEnabled ? "wifi" : "wifi.slash")
                        .font(.caption)
                    Text(isLiveModeEnabled ? "LIVE" : "OFF")
                        .font(.caption.bold())
                }
                .padding(8)
                .background(isLiveModeEnabled ? Color.green : Color.gray)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(radius: 2)
            }
        }
        .padding()
    }
    
    private var detailCard: some View {
        Group {
            if let post = selectedPost {
                MapDetailCardView(post: post, selectedPost: $selectedPost)
                    .padding()
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: selectedPost)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredPosts: [Post] {
        var posts = postService.posts.filter { $0.coordinate != nil }
        
        // Filter by status
        if let status = selectedStatus {
            posts = posts.filter { $0.status == status.rawValue }
        }
        
        // Filter by distance - removed nearby toggle, but keep for notifications
        
        return posts
    }
    
    // MARK: - Live Mode Functions
    
    private func startLiveUpdates() {
        guard isLiveModeEnabled else { return }
        
        // Update every 30 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task {
                await refreshPosts()
            }
        }
    }
    
    private func stopLiveUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func toggleLiveMode() {
        isLiveModeEnabled.toggle()
        
        if isLiveModeEnabled {
            startLiveUpdates()
        } else {
            stopLiveUpdates()
        }
    }
    
    private func refreshPosts() async {
        await postService.refreshPosts()
        
        // Check for new nearby posts and send notifications
        if let userLocation = locationManager.location {
            let newPosts = postService.posts.filter { post in
                guard let postCoordinate = post.coordinate else { return false }
                let postLocation = CLLocation(latitude: postCoordinate.latitude, longitude: postCoordinate.longitude)
                let distance = userLocation.distance(from: postLocation) / 1000
                return distance <= nearbyRadius
            }
            
            // Send notification for new posts
            for post in newPosts.prefix(3) { // Limit to 3 notifications
                sendNearbyNotification(for: post)
            }
        }
    }
    
    // MARK: - Location Functions
    
    // Function removed - location centering is now handled in filterControls
    
    private func isNearby(post: Post) -> Bool {
        guard let userLocation = locationManager.location,
              let postCoordinate = post.coordinate else { return false }
        
        let postLocation = CLLocation(latitude: postCoordinate.latitude, longitude: postCoordinate.longitude)
        let distance = userLocation.distance(from: postLocation) / 1000
        return distance <= nearbyRadius
    }
    
    
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "lost":
            return .red
        case "found":
            return .green
        case "active":
            return .blue
        default:
            return .gray
        }
    }
    
    // MARK: - Notification Functions
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func sendNearbyNotification(for post: Post) {
        let content = UNMutableNotificationContent()
        content.title = "New \(PostStatus(rawValue: post.status)?.displayName ?? "pet") nearby!"
        content.body = "\(post.petName ?? "Pet") - \(post.breed ?? "Unknown breed")"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "nearby-\(post.id.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error)")
            }
        }
    }
}

// MARK: - Map Annotation View

struct MapAnnotationView: View {
    let isSelected: Bool
    let status: PostStatus
    
    var body: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.title)
            .foregroundColor(pinColor)
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .shadow(radius: 5)
            .padding()
            .background(Color(.systemGray6), in: Circle())
    }
    
    private var pinColor: Color {
        switch status {
        case .lost:
            return .red
        case .found:
            return .green
        case .active:
            return .blue
        }
    }
}

// MARK: - Map Detail Card View

struct MapDetailCardView: View {
    let post: Post
    @Binding var selectedPost: Post?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(post.petName ?? "Unknown Pet")
                    .font(.title2.bold())
                
                Spacer()
                
                // Status badge
                Text(PostStatus(rawValue: post.status)?.displayName ?? "Unknown")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                
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
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
    
    private var statusColor: Color {
        switch PostStatus(rawValue: post.status) {
        case .lost:
            return .red
        case .found:
            return .green
        case .active:
            return .blue
        default:
            return .gray
        }
    }
}

// MARK: - Extensions

extension PostStatus {
    var displayName: String {
        switch self {
        case .lost:
            return "Lost"
        case .found:
            return "Found"
        case .active:
            return "Active"
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let service = PostService(authManager: AuthenticationManager())
        return MapView()
            .environmentObject(service)
    }
} 
