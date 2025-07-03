import Foundation
import CoreLocation

struct MockData {
    static let posts: [Post] = [
        Post(
            id: UUID().uuidString,
            title: "Missing Golden Retriever",
            species: .dog,
            breed: "Golden Retriever",
            age: 3,
            gender: .male,
            weight: .large,
            color: "Golden",
            imageNames: ["golden_retriever"],
            locationName: "Almaty, Bostandyk District",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 43.2389, longitude: 76.8897),
            description: "Friendly and playful golden retriever named Buddy. Last seen near Central Park. He has a blue collar with a name tag.",
            contactPhone: "+1 (555) 123-4567",
            authorId: "currentUser_123", // Belongs to current user
            timestamp: Date().addingTimeInterval(-3600 * 5), // 5 hours ago
            status: .lost
        ),
        Post(
            id: UUID().uuidString,
            title: "Found Siamese Cat",
            species: .cat,
            breed: "Siamese",
            age: 1,
            gender: .female,
            weight: .small,
            color: "Cream",
            imageNames: ["siamese_cat"],
            locationName: "Astana, Yesil District",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 51.1694, longitude: 71.4491),
            description: "Found a young Siamese cat hiding under a car. She is very shy but seems healthy. No collar.",
            contactPhone: "+7 (701) 987-6543",
            authorId: "user_abc_456", // Belongs to another user
            timestamp: Date().addingTimeInterval(-3600 * 24 * 2), // 2 days ago
            status: .found
        ),
        Post(
            id: UUID().uuidString,
            title: "Lost Holland Lop Bunny",
            species: .other, // Changed from .bunny
            breed: "Holland Lop",
            age: 2,
            gender: .male,
            weight: .small,
            color: "White",
            imageNames: ["bunny_placeholder_1"],
            locationName: "Shymkent, Al-Farabi District",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 42.3417, longitude: 69.5917),
            description: "Our bunny, Snowball, escaped from his hutch in the backyard. He is white with grey spots.",
            contactPhone: "+7 (777) 555-1234",
            authorId: "user_def_789", // Belongs to another user
            timestamp: Date().addingTimeInterval(-3600 * 24 * 7), // 1 week ago
            status: .lost
        ),
        Post(
            id: UUID().uuidString,
            title: "Lost Pomeranian Spitz",
            species: .dog,
            breed: "Pomeranian Spitz",
            age: 5,
            gender: .male,
            weight: .small,
            color: "White",
            imageNames: ["dog_placeholder_2"],
            locationName: "Almaty, Medeu District",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 43.2567, longitude: 76.9286),
            description: "Small, fluffy white Pomeranian named Archie. He is very energetic and might be scared.",
            contactPhone: "+1 (555) 123-4567",
            authorId: "currentUser_123", // Belongs to current user
            timestamp: Date().addingTimeInterval(-3600 * 3), // 3 hours ago
            status: .lost
        ),
        Post(
            id: UUID().uuidString,
            title: "Missing cat Phoebe",
            species: .cat,
            breed: "Unknown",
            age: 4,
            gender: .female,
            weight: .medium,
            color: "Calico",
            imageNames: ["phoebe_1", "phoebe_2", "phoebe_3"],
            locationName: "Fargo, ND",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 46.8772, longitude: -96.7898),
            description: "This is my family's cat phoebe, she went missing last night around 10-11pm she left from our balcony, and we tried getting her to come in but she ran away, the area is 17th Ave S fargo, and she might even be around Prairiewood, please lmk if you see her.",
            contactPhone: "+1 (701) 555-9876",
            authorId: "user_kchol_1",
            timestamp: Date().addingTimeInterval(-3600 * 12), // 12 hours ago
            status: .lost
        )
    ]

    static let chatSessions: [ChatSession] = [
        ChatSession(
            participantName: "Elena Petrova",
            participantAvatar: "person.crop.circle.fill",
            messages: [
                ChatMessage(text: "Hello! I think I saw your golden retriever near the Magnum store.", timestamp: Date().addingTimeInterval(-60 * 5), isFromCurrentUser: false),
                ChatMessage(text: "Really? That's great news! When was it?", timestamp: Date().addingTimeInterval(-60 * 3), isFromCurrentUser: true)
            ],
            unreadCount: 1,
            isOnline: false
        ),
        ChatSession(
            participantName: "Madge Gomez",
            participantAvatar: "person.crop.circle",
            messages: [
                ChatMessage(text: "Hahahaha thanks, i didnt know there were bots on ride", timestamp: Date().addingTimeInterval(-3600 * 2), isFromCurrentUser: false)
            ],
            unreadCount: 4,
            isOnline: true
        ),
        ChatSession(
            participantName: "Chad Griffin",
            participantAvatar: "person.crop.circle.fill",
            messages: [
                ChatMessage(text: "you interest the Pet show..?", timestamp: Date().addingTimeInterval(-3600 * 24), isFromCurrentUser: false)
            ],
            unreadCount: 0,
            isOnline: false
        ),
        ChatSession(
            participantName: "Glenn Guzman",
            participantAvatar: "person.crop.circle.fill",
            messages: [
                ChatMessage(text: "Thats pretty wild on you", timestamp: Date().addingTimeInterval(-3600 * 24), isFromCurrentUser: false)
            ],
            unreadCount: 0,
            isOnline: true
        ),
        ChatSession(
            participantName: "Cora Bush",
            participantAvatar: "person.crop.circle.fill",
            messages: [
                ChatMessage(text: "Hey hey, what are you favorites..?", timestamp: Date().addingTimeInterval(-3600 * 24), isFromCurrentUser: false)
            ],
            unreadCount: 2,
            isOnline: false
        )
    ]
    
    static let topHelpers: [Helper] = [
        Helper(id: "user_sarah_1", name: "Sarah", avatarName: "person.crop.circle.fill", rating: 4.9, bio: "Animal lover and long-time volunteer at the local shelter. Has a knack for finding lost cats.", isVerified: true),
        Helper(id: "currentUser_123", name: "Bradley", avatarName: "person.crop.circle.fill", rating: 4.8, bio: "I'm an avid animal enthusiast with a lively household of two playful dogs and a mischievous cat. My days are filled with wagging tails and cuddly purrs.", isVerified: false),
        Helper(id: "user_abc_456", name: "Elena", avatarName: "person.crop.circle.fill", rating: 4.7, bio: "Specializing in caring for birds and exotic pets. I believe every animal deserves love and a safe home.", isVerified: false),
        Helper(id: "user_def_789", name: "Timur", avatarName: "person.crop.circle.fill", rating: 4.6, bio: "Found my own lost cat using an app like this, now I'm paying it forward. Especially good with shy animals.", isVerified: false),
        Helper(id: "user_kchol_1", name: "Kchol Deng", avatarName: "person.crop.circle.fill", rating: 0.0, bio: "Trying to find my family's cat, Phoebe.", isVerified: false)
    ]
    
    static let notifications: [AppNotification] = [
        AppNotification(
            type: .petFound,
            description: "A golden retriever was found 0.5km from your location",
            timestamp: Date().addingTimeInterval(-60 * 2), // 2 minutes ago
            isUnread: true,
            postID: MockData.posts[0].id,
            chatID: nil
        ),
        AppNotification(
            type: .newMessage,
            description: "Sarah Johnson sent you a message about Max",
            timestamp: Date().addingTimeInterval(-60 * 5), // 5 minutes ago
            isUnread: true,
            postID: nil,
            chatID: MockData.chatSessions[0].id.uuidString
        ),
        AppNotification(
            type: .postLiked,
            description: "Mike Chen liked your lost pet post",
            timestamp: Date().addingTimeInterval(-3600 * 1), // 1 hour ago
            isUnread: false,
            postID: MockData.posts[1].id,
            chatID: nil
        ),
        AppNotification(
            type: .newAlert,
            description: "A husky went missing in your area - Queens",
            timestamp: Date().addingTimeInterval(-3600 * 2), // 2 hours ago
            isUnread: false,
            postID: MockData.posts[3].id,
            chatID: nil
        )
    ]
} 