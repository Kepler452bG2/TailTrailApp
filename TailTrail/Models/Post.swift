import Foundation
import CoreLocation

// The Post model now matches the structure of the data coming from the backend API.
struct Post: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let petName: String?
    let species: String?
    let breed: String?
    let age: Double?
    let gender: String? // Was Gender enum
    let weight: Double?
    let color: String?
    let images: [String] // Renamed from imageNames
    let locationName: String?
    let lastSeenLocation: CLLocationCoordinate2D?
    let description: String?
    let contactPhone: String?
    let userId: UUID // Renamed from authorId, changed type to UUID
    let createdAt: Date // Renamed from timestamp
    let updatedAt: Date
    let likesCount: Int
    let isLiked: Bool
    var status: String // Was PostStatus enum

    // Custom Codable implementation is still needed for CLLocationCoordinate2D
    enum CodingKeys: String, CodingKey {
        case id, age, gender, weight, color, images, description, status
        case petName = "pet_name"
        case species = "pet_species"
        case breed = "pet_breed"
        case locationName = "location_name"
        case lastSeenLocation = "last_seen_location"
        case contactPhone = "contact_phone"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case likesCount = "likes_count"
        case isLiked = "is_liked"
    }

    // A nested struct for decoding the location object from the JSON.
    struct Coordinate: Codable {
        var latitude: Double
        var longitude: Double
    }

    // We need a memberwise initializer because the custom Codable init below removes the automatic one.
    // This is primarily for MockData and previews.
    init(id: UUID, petName: String?, species: String?, breed: String?, age: Double?, gender: String?, weight: Double?, color: String?, images: [String], locationName: String?, lastSeenLocation: CLLocationCoordinate2D?, description: String?, contactPhone: String?, userId: UUID, createdAt: Date, updatedAt: Date, likesCount: Int, isLiked: Bool, status: String) {
        self.id = id
        self.petName = petName
        self.species = species
        self.breed = breed
        self.age = age
        self.gender = gender
        self.weight = weight
        self.color = color
        self.images = images
        self.locationName = locationName
        self.lastSeenLocation = lastSeenLocation
        self.description = description
        self.contactPhone = contactPhone
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.likesCount = likesCount
        self.isLiked = isLiked
        self.status = status
    }
    
    // Custom decoder to handle the nested coordinate object and snake_case keys.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        petName = try container.decodeIfPresent(String.self, forKey: .petName)
        species = try container.decodeIfPresent(String.self, forKey: .species)
        breed = try container.decodeIfPresent(String.self, forKey: .breed)
        age = try container.decodeIfPresent(Double.self, forKey: .age)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        images = try container.decode([String].self, forKey: .images)
        locationName = try container.decodeIfPresent(String.self, forKey: .locationName)
        
        if let coordinate = try container.decodeIfPresent(Coordinate.self, forKey: .lastSeenLocation) {
            lastSeenLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        } else {
            lastSeenLocation = nil
        }

        description = try container.decodeIfPresent(String.self, forKey: .description)
        contactPhone = try container.decodeIfPresent(String.self, forKey: .contactPhone)
        userId = try container.decode(UUID.self, forKey: .userId)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        likesCount = try container.decode(Int.self, forKey: .likesCount)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
        status = try container.decode(String.self, forKey: .status)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(petName, forKey: .petName)
        try container.encode(species, forKey: .species)
        try container.encode(breed, forKey: .breed)
        try container.encode(age, forKey: .age)
        try container.encode(gender, forKey: .gender)
        try container.encode(weight, forKey: .weight)
        try container.encode(color, forKey: .color)
        try container.encode(images, forKey: .images)
        try container.encode(locationName, forKey: .locationName)
        if let coordinate = lastSeenLocation {
            try container.encode(Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude), forKey: .lastSeenLocation)
        }
        try container.encode(description, forKey: .description)
        try container.encode(contactPhone, forKey: .contactPhone)
        try container.encode(userId, forKey: .userId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(likesCount, forKey: .likesCount)
        try container.encode(isLiked, forKey: .isLiked)
        try container.encode(status, forKey: .status)
    }

    // We don't need a custom encoder right now as we are not sending this full model back.
    // But if we did, it would go here.
    
    var coordinate: CLLocationCoordinate2D? {
        lastSeenLocation
    }

    var imageURLs: [URL] {
        images.compactMap { URL(string: $0) }
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    // Equatable conformance
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// We keep these enums for UI creation, but they are no longer part of the Post model directly.
enum AgeCategory: String, Codable, CaseIterable {
    case young = "Young"
    case adult = "Adult"
    case senior = "Senior"
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
}

enum PetSpecies: String, Codable, CaseIterable, Identifiable {
    case dog = "dog"
    case cat = "cat"
    case bird = "bird"
    case other = "other"

    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .dog:
            return "dog.fill"
        case .cat:
            return "cat.fill"
        case .bird:
            return "bird.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}

enum PetGender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
}

enum SpayedStatus: String, Codable, CaseIterable {
    case yes = "Yes"
    case no = "No"
    case notSure = "Not Sure"
}

enum PetWeight: String, Codable, CaseIterable {
    case small = "5-20 lb"
    case medium = "21-50 lb"
    case large = "51-99 lb"
    case xl = "100+ lb"

    var subtitle: String {
        switch self {
        case .small: return "SMALL"
        case .medium: return "MEDIUM"
        case .large: return "LARGE"
        case .xl: return "XL"
        }
    }
}

enum PostStatus: String, Codable, CaseIterable {
    case lost = "lost"
    case found = "found"
    case active = "active"
} 