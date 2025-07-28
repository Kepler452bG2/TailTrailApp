import Foundation
import Combine
import SwiftUI
import AuthenticationServices

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User? = nil
    
    private let keychain = KeychainHelper.standard

    var currentToken: String? {
        keychain.getToken()
    }

    init() {
        self.isLoggedIn = keychain.hasToken()
        if self.isLoggedIn {
            Task {
                await fetchUserProfile()
            }
        }
    }
    
    // MARK: - General Auth Flow
    
    func logout() {
        keychain.deleteToken()
        isLoggedIn = false
        currentUser = nil
    }
    
    // MARK: - User Profile
    
    @MainActor
    func fetchUserProfile() async {
        print("Fetching user profile...")
        guard let token = keychain.getToken() else {
            print("❌ No token found, cannot fetch profile.")
            return
        }
        
        guard let url = URL(string: "\(Config.backendURL)/api/v1/users/profile") else {
            print("❌ Invalid URL for user profile")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Error: Invalid response from server when fetching profile.")
                if let httpResponse = response as? HTTPURLResponse {
                    print("Received status code: \(httpResponse.statusCode)")
                }
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseBody)")
                }
                return
            }
            
            let fetchedUser = try JSONDecoder().decode(User.self, from: data)
            self.currentUser = fetchedUser
            print("✅ User profile fetched successfully.")
            
        } catch {
            print("❌ Failed to fetch or decode user profile: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func loginUser(email: String, password: String) async -> Bool {
        guard let url = URL(string: "\(Config.backendURL)/api/v1/auth/login") else {
            print("❌ Invalid URL for login")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = ["email": trimmedEmail, "password": trimmedPassword]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Error: Invalid response from server (not HTTP).")
                return false
            }
            
            guard httpResponse.statusCode == 200 else {
                print("❌ Error: Invalid response from server during login.")
                print("Received status code: \(httpResponse.statusCode)")
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseBody)")
                }
                return false
            }
            
            let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            keychain.save(token: decodedResponse.token)
            
            self.isLoggedIn = true
            
            print("✅ Email/Password login successful. Token received. Fetching profile...")
            print("🔑 Your token: \(decodedResponse.token)")
            print("📧 Logged in as: \(email)")
            await fetchUserProfile()

            // DEBUG: Check user state immediately after fetching
            if let user = self.currentUser {
                print("🔍 DEBUG: User is now set to: \(user.email)")
            } else {
                print("🔍 DEBUG: User is still nil after fetch.")
            }
            
            return true
            
        } catch {
            print("❌ Failed to log in with email/password: \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    func registerUser(email: String, password: String) async -> Bool {
        guard let url = URL(string: "\(Config.backendURL)/api/v1/auth/signup") else {
            print("❌ Invalid URL for signup")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = ["email": trimmedEmail, "password": trimmedPassword]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Error: Invalid response from server (not HTTP) during signup.")
                return false
            }

            guard httpResponse.statusCode == 201 else {
                print("❌ Error: Invalid response from server during signup.")
                print("Received status code: \(httpResponse.statusCode)")
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseBody)")
                }
                return false
            }
            
            print("✅ Registration successful. Now logging in...")
            // Сразу логиним пользователя после успешной регистрации
            return await loginUser(email: email, password: password)
            
        } catch {
            print("❌ Failed to sign up with email/password: \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    func updateUserProfile(
        name: String? = nil,
        phone: String? = nil,
        currentPassword: String? = nil,
        newPassword: String? = nil,
        image: UIImage? = nil
    ) async -> Bool {
        guard let token = keychain.getToken() else {
            print("❌ No token found.")
            return false
        }

        var multipart = MultipartRequest()
        
        if let name = name, let nameData = name.data(using: .utf8) {
            multipart.add(key: "name", value: name, data: nameData)
        }
        if let phone = phone, let phoneData = phone.data(using: .utf8) {
            multipart.add(key: "phone", value: phone, data: phoneData)
        }
        if let currentPassword = currentPassword, let currentPasswordData = currentPassword.data(using: .utf8) {
            multipart.add(key: "current_password", value: currentPassword, data: currentPasswordData)
            }
        if let newPassword = newPassword, let newPasswordData = newPassword.data(using: .utf8) {
            multipart.add(key: "new_password", value: newPassword, data: newPasswordData)
        }
        if let image, let imageData = image.jpegData(compressionQuality: 0.8) {
            multipart.add(
                key: "profile_image",
                fileName: "profile.jpg",
                fileMimeType: "image/jpeg",
                fileData: imageData
            )
        }
        
        guard let url = URL(string: "\(Config.backendURL)/api/v1/users/profile") else {
            print("❌ Invalid URL for profile update.")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(multipart.httpContentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = multipart.httpBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Failed to update profile on server.")
                if let httpResponse = response as? HTTPURLResponse {
                    print("Received status code: \(httpResponse.statusCode)")
                }
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseBody)")
                }
                return false
            }
            
            let updatedUser = try JSONDecoder().decode(User.self, from: data)
            self.currentUser = updatedUser
            print("✅ Profile updated successfully.")
            return true
            
        } catch {
            print("❌ Error during profile update request: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Sign in with Apple logic removed
    
    @MainActor
    func deleteAccount() async {
        guard let token = keychain.getToken() else {
            print("❌ No token found for deletion.")
            return
        }
        
        guard let url = URL(string: "\(Config.backendURL)/api/v1/users/profile") else {
            print("❌ Invalid URL for account deletion.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (httpResponse.statusCode == 200 || httpResponse.statusCode == 204) else {
                print("❌ Failed to delete account on server.")
                if let httpResponse = response as? HTTPURLResponse {
                    print("Received status code: \(httpResponse.statusCode)")
                }
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseBody)")
                }
                return
            }
            
            print("✅ Account deleted successfully on server.")
            // Выходим из аккаунта локально
            logout()
            
        } catch {
            print("❌ Error during account deletion request: \(error.localizedDescription)")
        }
    }
}

// MARK: - Token Handling

struct LoginResponse: Codable {
    let token: String
}

struct TokenExchangeRequest: Codable {
    let token: String
}

struct TokenExchangeResponse: Codable {
    let accessToken: String
    let user: User
} 