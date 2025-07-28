import Foundation
import CoreLocation

struct MockData {
    static let posts: [Post] = [
        Post(
            id: UUID(),
            petName: "Buddy",
            species: "dog",
            breed: "Golden Retriever",
            age: 5,
            gender: "male",
            weight: 30.0,
            color: "Golden",
            images: ["dog1", "dog2"],
            locationName: "Central Park, NYC",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 40.785091, longitude: -73.968285),
            description: "Very friendly, was wearing a blue collar. Answers to Buddy.",
            contactPhone: "555-1234",
            userId: "mock-user-1",
            createdAt: Date().addingTimeInterval(-3600 * 4),
            updatedAt: Date().addingTimeInterval(-3600 * 4),
            likesCount: 12,
            isLiked: true,
            status: "lost"
        ),
        Post(
            id: UUID(),
            petName: "Unknown",
            species: "cat",
            breed: "Siamese",
            age: 2,
            gender: "female",
            weight: 4.5,
            color: "Cream with dark points",
            images: ["cat1", "cat2"],
            locationName: "Brooklyn Bridge Park",
            lastSeenLocation: CLLocationCoordinate2D(latitude: 40.706000, longitude: -73.997000),
            description: "A bit shy, but seems healthy. Found near the carousel.",
            contactPhone: "555-8888",
            userId: "mock-user-1",
            createdAt: Date().addingTimeInterval(-86400 * 3),
            updatedAt: Date().addingTimeInterval(-3600 * 24 * 2),
            likesCount: 3,
            isLiked: false,
            status: "found"
        )
    ]
    
    static let notifications: [AppNotification] = [
        AppNotification(type: .newMessage, message: "Alex sent you a message about 'Buddy'.", date: "1h ago", postID: MockData.posts[0].id.uuidString, chatID: MockData.chatSessions[0].id.uuidString),
        AppNotification(type: .petFound, message: "A pet matching 'Buddy''s description was found near you.", date: "3h ago", postID: MockData.posts[0].id.uuidString, chatID: nil),
        AppNotification(type: .postLiked, message: "Someone liked your post about 'Buddy'.", date: "4h ago", postID: MockData.posts[0].id.uuidString, chatID: nil),
    ]

    static let topHelpers: [Helper] = [
        Helper(id: UUID(), name: "John Doe", avatarName: "person.circle.fill", rating: 4.8, bio: "Animal lover and rescue volunteer.", isVerified: true),
        Helper(id: UUID(), name: "Jane Smith", avatarName: "person.circle.fill", rating: 4.9, bio: "Expert in finding lost dogs.", isVerified: false),
        Helper(id: UUID(), name: "Alex Johnson", avatarName: "person.circle.fill", rating: 4.7, bio: "I have two cats of my own and know the area well.", isVerified: true)
    ]

    static var chatSessions: [ChatSession] = [
        ChatSession(
            participantName: "John Doe",
            participantAvatar: "person.circle.fill",
            messages: [
                ChatMessage(text: "I think I saw Buddy near the fountain in Central Park yesterday evening.", timestamp: Date().addingTimeInterval(-3600 * 23), isFromCurrentUser: false),
                ChatMessage(text: "Really? Around what time?", timestamp: Date().addingTimeInterval(-3600 * 22), isFromCurrentUser: true),
                ChatMessage(text: "Around 7 PM. He was chasing squirrels.", timestamp: Date().addingTimeInterval(-3600 * 21), isFromCurrentUser: false)
            ],
            unreadCount: 1,
            isOnline: true
        ),
        ChatSession(
            participantName: "Jane Smith",
            participantAvatar: "person.circle.fill",
            messages: [
                ChatMessage(text: "I've shared your post with the local community group. Hope you find him soon!", timestamp: Date().addingTimeInterval(-3600 * 48), isFromCurrentUser: false)
            ],
            unreadCount: 0,
            isOnline: false
        )
    ]

    static let helper1 = Helper(id: UUID(), name: "Sarah Johnson", avatarName: "person.fill", rating: 4.8, bio: "Experienced dog walker and pet sitter. Available in Downtown area.", isVerified: true)
    
    static let helper2 = Helper(id: UUID(), name: "Mike Wilson", avatarName: "person.fill", rating: 4.9, bio: "Professional dog trainer with 5 years experience.", isVerified: true)
    
    static let helper3 = Helper(id: UUID(), name: "Alex Chen", avatarName: "person.fill", rating: 4.9, bio: "Certified pet care specialist. Dog training and pet sitting services.", isVerified: false)
    
    static let helpers = [helper1, helper2, helper3]
    
    // Mock data for new Chat model
    static let chats: [Chat] = [
        Chat(
            id: "mock-chat-1",
            name: nil,
            isGroup: false,
            createdAt: Date().addingTimeInterval(-86400),
            updatedAt: Date(),
            participants: [
                Chat.Participant(
                    id: "user1",
                    email: "jane.smith@example.com",
                    imageUrl: nil,
                    isOnline: true,
                    lastSeen: Date()
                ),
                Chat.Participant(
                    id: "current-user",
                    email: "current@example.com",
                    imageUrl: nil,
                    isOnline: true,
                    lastSeen: Date()
                )
            ],
            lastMessage: "I've shared your post with the local community group. Hope you find him soon!",
            lastMessageTime: Date().addingTimeInterval(-3600),
            unreadCount: 0
        )
    ]
} 