import SwiftUI
import CoreLocation

@MainActor
class PostService: ObservableObject {
    @Published var posts: [Post] = MockData.posts
    
    // In a real app, this would come from an authentication service
    private let currentUserId = "currentUser_123"
    
    func createPost(petName: String, petSpecies: PetSpecies, petBreed: String, age: Double, gender: PetGender, weight: PetWeight, color: String, description: String, locationName: String, contactPhone: String, lastSeenLocation: CLLocationCoordinate2D, images: [UIImage]) {
        // In a real app, images would be uploaded and we'd get URLs.
        // For now, we use placeholders.
        let imageNames = images.isEmpty ? ["dog_placeholder_2"] : (1...images.count).map { "uploaded_image_\($0)" }
        
        let newPost = Post(
            id: UUID().uuidString,
            title: petName,
            species: petSpecies,
            breed: petBreed,
            age: age,
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