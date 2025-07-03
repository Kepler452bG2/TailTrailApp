import Foundation

struct Helper: Identifiable, Hashable {
    let id: String
    let name: String
    let avatarName: String // SFSymbol name for now
    let rating: Double
    let bio: String
    let isVerified: Bool
} 