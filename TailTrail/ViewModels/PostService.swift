import SwiftUI
import CoreLocation
import Foundation
import Combine

extension Formatter {
    static let iso8601withFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension JSONDecoder {
    static let custom: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601withFractionalSeconds)
        return decoder
    }()
}

@MainActor
class PostService: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isOffline = false
    @Published var selectedSpecies: PetSpecies? = nil
    @Published var searchText: String = ""
    @Published var likedPosts: [Post] = []
    @Published var likedPostIds: Set<String> = []
    
    private var currentPage = 1
    private let postsPerPage = 5
    @Published var canLoadMorePages = true
    private let authManager: AuthenticationManager
    private let networkManager: NetworkManager
    
    // Computed property for filtered posts
    var filteredPosts: [Post] {
        var filtered = posts
        
        // Filter by species if selected
        if let selectedSpecies = selectedSpecies {
            filtered = filtered.filter { $0.species == selectedSpecies.rawValue }
        }
        
        // Filter by search text if not empty
        if !searchText.isEmpty {
            filtered = filtered.filter { post in
                let petName = post.petName?.lowercased() ?? ""
                let searchQuery = searchText.lowercased()
                return petName.contains(searchQuery)
            }
        }
        
        return filtered
    }
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        self.networkManager = NetworkManager.shared
        
        // Monitor network connectivity
        networkManager.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isOffline = !isConnected
                if isConnected && self?.posts.isEmpty == true && authManager.isLoggedIn {
                    Task {
                        await self?.refreshPosts()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()

    func loadMorePosts() async {
        guard !isLoading && canLoadMorePages && authManager.isLoggedIn else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let endpoint = "/api/v1/posts/?page=\(currentPage)&size=\(postsPerPage)"
            print("🌐 Fetching posts from: \(endpoint)")
            let response: PostsResponse = try await networkManager.fetchData(from: endpoint, authManager: authManager)
            
            print("📥 Received \(response.posts.count) posts from server")
            
            if !response.posts.isEmpty {
                posts.append(contentsOf: response.posts)
                currentPage += 1
                print("✅ Added posts to list. Total posts: \(posts.count)")
            } else {
                canLoadMorePages = false
                print("📭 No more posts available")
            }
        } catch let networkError as NetworkError {
            print("❌ Network error: \(networkError)")
            // Don't show error for unauthorized when not logged in
            if case .unauthorized = networkError, !authManager.isLoggedIn {
                // Silently fail - user is not logged in
                canLoadMorePages = false
                print("🔒 User not logged in, silently failing")
            } else {
                handleNetworkError(networkError)
            }
        } catch {
            print("❌ Generic error: \(error)")
            handleGenericError(error)
        }

        isLoading = false
    }
    
    func refreshPosts() async {
        currentPage = 1
        canLoadMorePages = true
        posts = []
        errorMessage = nil
        
        await loadMorePosts()
    }
    
    func loadPostsNearLocation(_ location: CLLocation, radius: Double = 50.0) async {
        // Load all posts first
        await refreshPosts()
        
        // Filter posts by distance on client side using MapKit
        let filteredPosts = posts.filter { post in
            guard let postCoordinate = post.coordinate else { return false }
            let postLocation = CLLocation(latitude: postCoordinate.latitude, longitude: postCoordinate.longitude)
            let distance = location.distance(from: postLocation) / 1000 // Convert to km
            return distance <= radius
        }
        
        // Sort by distance (nearest first)
        posts = filteredPosts.sorted { post1, post2 in
            guard let coord1 = post1.coordinate, let coord2 = post2.coordinate else { return false }
            let loc1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
            let loc2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
            return location.distance(from: loc1) < location.distance(from: loc2)
        }
        
        print("📍 Found \(posts.count) posts within \(radius)km of user location")
    }

    func createPost(
        petName: String,
        petSpecies: String,
        petBreed: String,
        age: Double,
        gender: String,
        weight: Double,
        color: String,
        description: String,
        locationName: String,
        contactPhone: String,
        lastSeenLocation: CLLocationCoordinate2D,
        images: [UIImage],
        status: PostStatus = .lost
    ) async throws {
        
        let postData: [String: Any] = [
            "petName": petName,
            "petSpecies": petSpecies,
            "petBreed": petBreed,
            "age": age,
            "gender": gender,
            "weight": weight,
            "color": color,
            "description": description,
            "locationName": locationName,
            "contactPhone": contactPhone,
            "lat": lastSeenLocation.latitude,
            "lng": lastSeenLocation.longitude,
            "status": status.rawValue
        ]

        do {
            // Send to backend using the new multipart upload function
            _ = try await networkManager.uploadPost(postData: postData, images: images, authManager: authManager)
            
            // Add a small delay to give the backend time to process the new post
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Refresh posts to show the new one
            await refreshPosts()
        } catch let networkError as NetworkError {
            handleNetworkError(networkError)
            throw networkError
        } catch {
            handleGenericError(error)
            throw error
        }
    }
    
    private func handleNetworkError(_ error: NetworkError) {
        errorMessage = error.localizedDescription
        showError = true
        
        switch error {
        case .noInternetConnection:
            isOffline = true
        case .unauthorized:
            // Handle logout if needed
            break
        case .serverUnavailable, .timeout:
            // These are temporary errors, user can retry
            break
        default:
            break
        }
    }
    
    private func handleGenericError(_ error: Error) {
        errorMessage = "An unexpected error occurred. Please try again."
        showError = true
        print("❌ Generic error in PostService: \(error)")
    }
    
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    func retry() async {
        clearError()
        await refreshPosts()
    }
    
    // MARK: - Like functionality
    
    func toggleLike(for post: Post) {
        let postId = post.id.uuidString
        
        // Optimistically update UI
        if likedPostIds.contains(postId) {
            likedPostIds.remove(postId)
            likedPosts.removeAll { $0.id.uuidString == postId }
        } else {
            likedPostIds.insert(postId)
            likedPosts.append(post)
        }
        
        // Send API request
        toggleLikeAPI(postId: postId)
    }
    
    func isLiked(post: Post) -> Bool {
        let postId = post.id.uuidString
        return likedPostIds.contains(postId)
    }
    
    func loadLikedPosts() {
        // For now, we'll use local storage
        // In a real app, you'd fetch from backend
        likedPosts = posts.filter { post in
            let postId = post.id.uuidString
            return likedPostIds.contains(postId)
        }
    }
    

    
    private func toggleLikeAPI(postId: String) {
        Task {
            do {
                let endpoint = "/api/v1/posts/\(postId)/like"
                let emptyBody = [String: String]()
                try await networkManager.postData(to: endpoint, body: emptyBody, authManager: authManager)
                print("✅ Post \(postId) like toggled successfully")
            } catch {
                print("❌ Failed to toggle like for post \(postId): \(error)")
                // Revert local state if API call fails
                DispatchQueue.main.async {
                    // Toggle back the state
                    if self.likedPostIds.contains(postId) {
                        self.likedPostIds.remove(postId)
                        self.likedPosts.removeAll { $0.id.uuidString == postId }
                    } else {
                        self.likedPostIds.insert(postId)
                        if let post = self.posts.first(where: { $0.id.uuidString == postId }) {
                            self.likedPosts.append(post)
                        }
                    }
                }
            }
        }
    }
} 