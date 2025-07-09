import Foundation
import CoreLocation

struct MockData {
    static let posts: [Post] = [
        Post(
            id: "1",
            title: "Lost Golden Retriever",
            petName: "Buddy",
            species: .dog,
            breed: "Golden Retriever",
            age: 3,
            ageCategory: .adult,
            gender: .male,
            weight: .large,
            color: "Golden",
            imageNames: ["golden_retriever"],
            locationName: "Central Park",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 40.785091, longitude: -73.968285),
            description: "Friendly golden retriever, answers to the name of 'Buddy'. Last seen near the carousel.",
            contactPhone: "123-456-7890",
            authorId: "user1",
            timestamp: Date().addingTimeInterval(-3600),
            status: .lost
        ),
        Post(
            id: "2",
            title: "Found Siamese Cat",
            petName: "Luna",
            species: .cat,
            breed: "Siamese",
            age: 2,
            ageCategory: .young,
            gender: .female,
            weight: .small,
            color: "Cream",
            imageNames: ["siamese_cat"],
            locationName: "Times Square",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
            description: "Found a Siamese cat, very vocal and seems lost. No collar.",
            contactPhone: "098-765-4321",
            authorId: "user2",
            timestamp: Date().addingTimeInterval(-7200),
            status: .found
        ),
        Post(
            id: "3",
            title: "Missing cat Phoebe",
            petName: "Phoebe",
            species: .cat,
            breed: "Calico",
            age: 4,
            ageCategory: .adult,
            gender: .female,
            weight: .medium,
            color: "Calico",
            imageNames: ["phoebe_1", "phoebe_2", "phoebe_3"],
            locationName: "Fargo, ND",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 46.8772, longitude: -96.7898),
            description: "This is my family's cat phoebe, she went missing last night around 10-11pm she left from our balcony, and we tried getting her to come in but she ran away, the area is 17th Ave S fargo, and she might even be around Prairiewood, please lmk if you see her.",
            contactPhone: "+1 (701) 555-9876",
            authorId: "user_kchol_1",
            timestamp: Date().addingTimeInterval(-43200),
            status: .lost
        ),
        Post(
            id: "4",
            title: "Found Cat Near Me",
            petName: "Leo",
            species: .cat,
            breed: "Tabby",
            age: 1,
            ageCategory: .young,
            gender: .male,
            weight: .small,
            color: "Brown",
            imageNames: ["phoebe_2"],
            locationName: "East Village",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 40.7265, longitude: -73.9835),
            description: "Found this little guy wandering around. He's very friendly and playful.",
            contactPhone: "555-987-6543",
            authorId: "user4",
            timestamp: Date().addingTimeInterval(-172800),
            status: .found
        )
    ]

    static let chatSessions: [ChatSession] = [
        ChatSession(
            participantName: "Elena Petrova",
            participantAvatar: "phoebe_1",
            messages: [
                ChatMessage(text: "Hello! I think I saw your golden retriever near the Magnum store.", timestamp: Date().addingTimeInterval(-60 * 5), isFromCurrentUser: false),
                ChatMessage(text: "Really? That's great news! When was it?", timestamp: Date().addingTimeInterval(-60 * 3), isFromCurrentUser: true)
            ],
            unreadCount: 1,
            isOnline: false
        ),
        ChatSession(
            participantName: "Madge Gomez",
            participantAvatar: "phoebe_2",
            messages: [
                ChatMessage(text: "Hahahaha thanks, i didnt know there were bots on ride", timestamp: Date().addingTimeInterval(-3600 * 2), isFromCurrentUser: false)
            ],
            unreadCount: 4,
            isOnline: true
        ),
        ChatSession(
            participantName: "Chad Griffin",
            participantAvatar: "phoebe_3",
            messages: [
                ChatMessage(text: "you interest the Pet show..?", timestamp: Date().addingTimeInterval(-3600 * 24), isFromCurrentUser: false)
            ],
            unreadCount: 0,
            isOnline: false
        ),
        ChatSession(
            participantName: "Glenn Guzman",
            participantAvatar: "siamese_cat",
            messages: [
                ChatMessage(text: "Thats pretty wild on you", timestamp: Date().addingTimeInterval(-3600 * 24), isFromCurrentUser: false)
            ],
            unreadCount: 0,
            isOnline: true
        ),
        ChatSession(
            participantName: "Cora Bush",
            participantAvatar: "golden_retriever",
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