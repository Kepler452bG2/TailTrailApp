import Foundation
import UIKit

// A struct that matches the server's response for creating a post
struct CreatePostResponse: Decodable {
    let post: Post
}

enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse(String) // Now holds the server's error message
    case badStatus
    case failedToDecodeResponse
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let baseURL: URL

    private init() {
        guard let url = URL(string: Config.apiBaseURL) else {
            fatalError("Invalid API_BASE_URL. Check your configuration. The value was: '\(Config.apiBaseURL)'")
        }
        self.baseURL = url
        print("✅ API Base URL loaded: \(self.baseURL.absoluteString)")
    }
    
    func fetchData<T: Decodable>(from endpoint: String, authManager: AuthenticationManager) async throws -> T {
        guard let url = URL(string: baseURL.absoluteString + endpoint) else {
            throw NetworkError.badUrl
        }
        
        var request = URLRequest(url: url)
        if let token = await authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for token expiration first
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            let errorBody = String(data: data, encoding: .utf8) ?? ""
            if errorBody.contains("Token expired!") {
                await MainActor.run {
                    authManager.logout()
                }
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
            print("❌ Network Error in GET \(url.absoluteString): Received status code \((response as? HTTPURLResponse)?.statusCode ?? -1). Response body: \(errorBody)")
            throw NetworkError.badStatus
        }
        
        do {
            return try JSONDecoder.custom.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
            print("❌ DECODING ERROR: \(decodingError). \n---Response body---\n\(errorBody)")
            throw NetworkError.failedToDecodeResponse
        } catch {
            let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
            print("❌ UNKNOWN ERROR during decoding: \(error.localizedDescription). \n---Response body---\n\(errorBody)")
            throw NetworkError.failedToDecodeResponse
        }
    }
    
    func postData<T: Codable>(to endpoint: String, body: T, authManager: AuthenticationManager) async throws {
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = await authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Formatter.iso8601withFractionalSeconds)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for token expiration first
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            let errorBody = String(data: data, encoding: .utf8) ?? ""
            if errorBody.contains("Token expired!") {
                await MainActor.run {
                    authManager.logout()
                }
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
            print("❌ Network Error in POST \(url.absoluteString): Received status code \(statusCode). Response body: \(errorBody)")
            throw NetworkError.badResponse(errorBody)
        }
    }

    func uploadPost(postData: [String: Any], images: [UIImage], authManager: AuthenticationManager) async throws -> Post {
        let url = baseURL.appendingPathComponent("/api/v1/posts/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let token = await authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add form fields
        for (key, value) in postData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add images
        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            let filename = "image\(index).jpg"
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for token expiration first
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            let errorBody = String(data: data, encoding: .utf8) ?? ""
            if errorBody.contains("Token expired!") {
                await MainActor.run {
                    authManager.logout()
                }
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
            print("❌ Upload failed with status code \(statusCode). Response body: \(errorBody)")
            throw NetworkError.badResponse(errorBody)
        }
        
        // Decode the response body into a Post object and return it
        do {
            // First, decode the wrapper object that contains the post
            let createPostResponse = try JSONDecoder.custom.decode(CreatePostResponse.self, from: data)
            // Then, return the actual post object
            return createPostResponse.post
        } catch {
            print("❌ Failed to decode new post from response: \(error)")
            throw NetworkError.failedToDecodeResponse
        }
    }

    func reportPost(postId: String, reason: String, authManager: AuthenticationManager) async throws {
        let endpoint = "/api/v1/posts/\(postId)/complaint" // Changed from /report
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = await authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = ["complaint": reason] // Changed from "feedback"
        request.httpBody = try? JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
            print("❌ Report failed with status code \(statusCode). Response body: \(errorBody)")
            throw NetworkError.badResponse(errorBody)
        }
        
        print("✅ Post \(postId) reported successfully for reason: \(reason)")
    }

    func blockUser(userId: String, authManager: AuthenticationManager) async throws {
        let endpoint = "/api/v1/users/block/" // Changed endpoint
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = await authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // The user ID to block is sent in the body, not the URL
        let body = ["blocked_id": userId]
        request.httpBody = try? JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
            print("❌ Block user failed with status code \(statusCode). Response body: \(errorBody)")
            throw NetworkError.badResponse(errorBody)
        }
        
        print("✅ User \(userId) blocked successfully.")
    }

    func fetchBlockedUsers(authManager: AuthenticationManager) async throws -> [User] {
        let endpoint = "/api/v1/users/block/"
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = await authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
            print("❌ Fetching blocked users failed with status code \(statusCode). Response body: \(errorBody)")
            throw NetworkError.badResponse(errorBody)
        }
        
        // Assuming the response is a direct array of User objects
        return try JSONDecoder().decode([User].self, from: data)
    }

    func unblockUser(userId: String, authManager: AuthenticationManager) async throws {
        let endpoint = "/api/v1/users/block/\(userId)"
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        if let token = await authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else { // 204 No Content is a common success status for DELETE
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let errorBody = String(data: Data(), encoding: .utf8) ?? "Could not decode error body"
            print("❌ Unblock user failed with status code \(statusCode). Response body: \(errorBody)")
            throw NetworkError.badResponse("Failed to unblock user")
        }
        
        print("✅ User \(userId) unblocked successfully.")
    }
} 