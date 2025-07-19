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
    private var currentPage = 1
    private let postsPerPage = 5
    private var canLoadMorePages = true
    private let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }

    func loadMorePosts() async {
        guard !isLoading && canLoadMorePages else {
            return
        }

        isLoading = true

        do {
            let endpoint = "/api/v1/posts/?page=\(currentPage)&size=\(postsPerPage)"
            let response: PostsResponse = try await NetworkManager.shared.fetchData(from: endpoint, authManager: authManager)
            
            if !response.posts.isEmpty {
                posts.append(contentsOf: response.posts)
                currentPage += 1
            } else {
                canLoadMorePages = false
            }
        } catch {
            print("Error fetching posts: \(error)")
            // Here you could set an error state to show in the UI
        }

        isLoading = false
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
        images: [UIImage]
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
            "status": PostStatus.lost.rawValue // Defaulting to 'lost'
        ]

        // Send to backend using the new multipart upload function
        try await NetworkManager.shared.uploadPost(postData: postData, images: images, authManager: authManager)
        
        // Add a small delay to give the backend time to process the new post
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Refresh all posts to get the new one from the server
        await refreshPosts()
    }

    func refreshPosts() async {
        // Reset pagination and clear current posts
        currentPage = 1
        posts = []
        canLoadMorePages = true
        // Load the first page
        await loadMorePosts()
    }

    func fetchPosts(forUserId userId: String) async -> [Post] {
        guard let currentUserId = authManager.currentUser?.id else {
            print("❌ Cannot fetch posts, user not logged in.")
            return []
        }
        
        let endpoint = "/api/v1/posts/?user_id=\(currentUserId)"
        do {
            let response: PostsResponse = try await NetworkManager.shared.fetchData(from: endpoint, authManager: authManager)
            return response.posts
        } catch {
            print("❌ Error fetching posts for user \(currentUserId): \(error)")
            return []
        }
    }

    func isPostOwnedByCurrentUser(_ post: Post) -> Bool {
        guard let currentUserId = authManager.currentUser?.id else { return false }
        return post.userId == currentUserId
    }
} 