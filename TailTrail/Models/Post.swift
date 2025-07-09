import Foundation
import CoreLocation

struct Post: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let title: String
    let petName: String
    let species: PetSpecies
    let breed: String
    let age: Double
    let ageCategory: AgeCategory
    let gender: Gender
    let weight: PetWeight
    let color: String
    let imageNames: [String]
    let locationName: String
    let lastSeenLocation: CLLocationCoordinate2D
    let description: String
    let contactPhone: String
    let authorId: String
    let timestamp: Date
    var status: PostStatus
    
    var coordinate: CLLocationCoordinate2D {
        lastSeenLocation
    }

    var imageURLs: [URL] {
        imageNames.compactMap { URL(string: $0) }
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
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

enum SpayedStatus: String, Codable, CaseIterable {
    case yes = "Yes"
    case no = "No"
    case notSure = "Not Sure"
}

enum PostStatus: String, Codable {
    case lost = "lost"
    case found = "found"
    case reunited = "reunited"
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
} 