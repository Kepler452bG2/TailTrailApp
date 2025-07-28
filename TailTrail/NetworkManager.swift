import Foundation
import UIKit
import Network

// A struct that matches the server's response for creating a post
struct CreatePostResponse: Decodable {
    let post: Post
}

enum NetworkError: Error, LocalizedError {
    case badUrl
    case invalidRequest
    case badResponse(String) // Now holds the server's error message
    case badStatus
    case failedToDecodeResponse
    case noInternetConnection
    case serverUnavailable
    case timeout
    case unauthorized
    case forbidden
    case notFound
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .badUrl:
            return "Invalid URL"
        case .invalidRequest:
            return "Invalid request"
        case .badResponse(let message):
            return message
        case .badStatus:
            return "Server error"
        case .failedToDecodeResponse:
            return "Failed to process server response"
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .serverUnavailable:
            return "Server is temporarily unavailable. Please try again later."
        case .timeout:
            return "Request timed out. Please try again."
        case .unauthorized:
            return "Please log in again"
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error. Please try again later."
        }
    }
}

class NetworkManager: ObservableObject {
    
    static let shared = NetworkManager()
    
    private let baseURL: URL
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType = .other

    private init() {
        guard let url = URL(string: Config.backendURL) else {
            fatalError("Invalid API_BASE_URL. Check your configuration. The value was: '\(Config.backendURL)'")
        }
        self.baseURL = url
        print("✅ API Base URL loaded: \(self.baseURL.absoluteString)")
        
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type ?? .other
                
                if path.status == .satisfied {
                    print("✅ Network connection restored")
                } else {
                    print("❌ Network connection lost")
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    private func checkConnectivity() throws {
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }
    }
    
    private func handleHTTPError(_ statusCode: Int, errorBody: String) -> NetworkError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 500...599:
            return .serverError
        default:
            return .badResponse(errorBody)
        }
    }
    
    func fetchData<T: Decodable>(from endpoint: String, authManager: AuthenticationManager) async throws -> T {
        try checkConnectivity()
        
        guard let url = URL(string: baseURL.absoluteString + endpoint) else {
            throw NetworkError.badUrl
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30 // 30 seconds timeout
        if let token = authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badStatus
            }
            
            // Check for token expiration first
            if httpResponse.statusCode == 401 {
                let errorBody = String(data: data, encoding: .utf8) ?? ""
                if errorBody.contains("Token expired!") {
                    Task { @MainActor in
                        authManager.logout()
                    }
                }
                throw NetworkError.unauthorized
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
                // Don't log 403 errors as they're expected when not authenticated
                if httpResponse.statusCode != 403 {
                    print("❌ Network Error in GET \(url.absoluteString): Received status code \(httpResponse.statusCode). Response body: \(errorBody)")
                }
                throw handleHTTPError(httpResponse.statusCode, errorBody: errorBody)
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
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.serverUnavailable
            }
        }
    }
    
    func postData<T: Codable>(to endpoint: String, body: T, authManager: AuthenticationManager) async throws {
        try checkConnectivity()
        
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Formatter.iso8601withFractionalSeconds)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badStatus
            }
            
            // Check for token expiration first
            if httpResponse.statusCode == 401 {
                let errorBody = String(data: data, encoding: .utf8) ?? ""
                if errorBody.contains("Token expired!") {
                    Task { @MainActor in
                        authManager.logout()
                    }
                }
                throw NetworkError.unauthorized
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
                print("❌ Network Error in POST \(url.absoluteString): Received status code \(httpResponse.statusCode). Response body: \(errorBody)")
                throw handleHTTPError(httpResponse.statusCode, errorBody: errorBody)
            }
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.serverUnavailable
            }
        }
    }

    func uploadPost(postData: [String: Any], images: [UIImage], authManager: AuthenticationManager) async throws -> Post {
        try checkConnectivity()
        
        let url = baseURL.appendingPathComponent("/api/v1/posts/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60 // Longer timeout for uploads

        if let token = authManager.currentToken {
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
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badStatus
            }
            
            // Check for token expiration first
            if httpResponse.statusCode == 401 {
                let errorBody = String(data: data, encoding: .utf8) ?? ""
                if errorBody.contains("Token expired!") {
                    Task { @MainActor in
                        authManager.logout()
                    }
                }
                throw NetworkError.unauthorized
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
                print("❌ Upload failed with status code \(httpResponse.statusCode). Response body: \(errorBody)")
                throw handleHTTPError(httpResponse.statusCode, errorBody: errorBody)
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
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.serverUnavailable
            }
        }
    }

    func reportPost(postId: String, reason: String, authManager: AuthenticationManager) async throws {
        try checkConnectivity()
        
        let endpoint = "/api/v1/posts/\(postId)/complaint" // Changed from /report
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = ["complaint": reason] // Changed from "feedback"
        request.httpBody = try? JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badStatus
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
                print("❌ Report failed with status code \(httpResponse.statusCode). Response body: \(errorBody)")
                throw handleHTTPError(httpResponse.statusCode, errorBody: errorBody)
            }
            
            print("✅ Post \(postId) reported successfully for reason: \(reason)")
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.serverUnavailable
            }
        }
    }

    func blockUser(userId: String, authManager: AuthenticationManager) async throws {
        try checkConnectivity()
        
        let endpoint = "/api/v1/users/block/" // Changed endpoint
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // The user ID to block is sent in the body, not the URL
        let body = ["blocked_id": userId]
        request.httpBody = try? JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badStatus
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
                print("❌ Block user failed with status code \(httpResponse.statusCode). Response body: \(errorBody)")
                throw handleHTTPError(httpResponse.statusCode, errorBody: errorBody)
            }
            
            print("✅ User \(userId) blocked successfully.")
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.serverUnavailable
            }
        }
    }

    func fetchBlockedUsers(authManager: AuthenticationManager) async throws -> [User] {
        try checkConnectivity()
        
        let endpoint = "/api/v1/users/block/"
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badStatus
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Could not decode error body"
                print("❌ Fetching blocked users failed with status code \(httpResponse.statusCode). Response body: \(errorBody)")
                throw handleHTTPError(httpResponse.statusCode, errorBody: errorBody)
            }
            
            // Assuming the response is a direct array of User objects
            return try JSONDecoder().decode([User].self, from: data)
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.serverUnavailable
            }
        }
    }

    func unblockUser(userId: String, authManager: AuthenticationManager) async throws {
        try checkConnectivity()
        
        let endpoint = "/api/v1/users/block/\(userId)"
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        if let token = authManager.currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badStatus
            }
            
            guard httpResponse.statusCode == 204 else { // 204 No Content is a common success status for DELETE
                let errorBody = String(data: Data(), encoding: .utf8) ?? "Could not decode error body"
                print("❌ Unblock user failed with status code \(httpResponse.statusCode). Response body: \(errorBody)")
                throw NetworkError.badResponse("Failed to unblock user")
            }
            
            print("✅ User \(userId) unblocked successfully.")
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.serverUnavailable
            }
        }
    }

    // MARK: - Delete Chat
    func deleteChat(chatId: String, token: String) async throws {
        try checkConnectivity()
        
        guard let url = URL(string: "\(Config.backendURL)/api/v1/chat/chats/\(chatId)") else {
            throw NetworkError.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badStatus
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorBody = String(data: Data(), encoding: .utf8) ?? "Could not decode error body"
                print("❌ Delete chat failed with status code \(httpResponse.statusCode). Response body: \(errorBody)")
                throw NetworkError.badResponse(errorBody)
            }
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.serverUnavailable
            }
        }
    }
    
    deinit {
        monitor.cancel()
    }
} 