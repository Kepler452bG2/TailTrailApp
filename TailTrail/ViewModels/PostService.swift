import SwiftUI
import CoreLocation
import Foundation
import Combine

@MainActor
class PostService: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    private var currentPage = 0
    private let postsPerPage = 5
    private var canLoadMorePages = true
    
    // In a real app, this would come from an authentication service
    private let currentUserId = "currentUser_123"
    
    init() {
        loadMorePosts()
    }

    func loadMorePosts() {
        guard !isLoading && canLoadMorePages else {
            return
        }

        isLoading = true

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let allPosts = MockData.posts
            let startIndex = self.currentPage * self.postsPerPage
            let endIndex = min(startIndex + self.postsPerPage, allPosts.count)
            
            if startIndex < endIndex {
                let newPosts = Array(allPosts[startIndex..<endIndex])
                self.posts.append(contentsOf: newPosts)
                self.currentPage += 1
            } else {
                self.canLoadMorePages = false
            }

            self.isLoading = false
        }
    }

    func createPost(petName: String, petSpecies: PetSpecies, petBreed: String, age: Double, ageCategory: AgeCategory, gender: Gender, weight: PetWeight, color: String, description: String, locationName: String, contactPhone: String, lastSeenLocation: CLLocationCoordinate2D, images: [UIImage]) {
        // In a real app, images would be uploaded and we'd get URLs.
        // For now, we use placeholders.
        let imageNames = images.isEmpty ? ["dog_placeholder_2"] : (1...images.count).map { "uploaded_image_\($0)" }
        
        let newPost = Post(
            id: UUID().uuidString,
            title: "Lost \(petBreed)",
            petName: petName,
            species: petSpecies,
            breed: petBreed,
            age: age,
            ageCategory: ageCategory,
            gender: gender,
            weight: weight,
            color: color,
            imageNames: imageNames,
            locationName: locationName,
            lastSeenLocation: lastSeenLocation,
            description: description,
            contactPhone: contactPhone, // Placeholder phone
            authorId: currentUserId,
            timestamp: Date(),
            status: .lost // Default to lost
        )
        
        // Add the new post to the beginning of the list
        posts.insert(newPost, at: 0)
    }

    func isPostOwnedByCurrentUser(_ post: Post) -> Bool {
        return post.authorId == currentUserId
    }
} 