import Foundation

/// Represents the top-level response from the server when fetching a list of posts.
/// The backend wraps the list of posts in this paginated structure.
struct PostsResponse: Decodable {
    let posts: [Post]
    let total: Int
    let page: Int
    let perPage: Int
    let totalPages: Int
    let hasNext: Bool
    let hasPrev: Bool
    
    enum CodingKeys: String, CodingKey {
        case posts, total, page
        case perPage = "per_page"
        case totalPages = "total_pages"
        case hasNext = "has_next"
        case hasPrev = "has_prev"
    }
} 