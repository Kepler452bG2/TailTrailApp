import Foundation
import Combine
import SwiftUI
import AuthenticationServices

class AuthenticationManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var user: User? = nil
    
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
        user = nil
    }
    
    // MARK: - User Profile
    
    @MainActor
    func fetchUserProfile() async {
        // Placeholder for actual profile fetching logic
        // This would involve calling an API endpoint to get the user's details
        // For now, we'll just simulate a successful fetch
        print("Fetching user profile...")
        // In a real app, you'd decode the user data from keychain or an API response
        // For example:
        // let userData = keychain.getUserData()
        // self.user = try? JSONDecoder().decode(User.self, from: userData)
    }
    
    @MainActor
    func loginUser(email: String, password: String) async -> Bool {
        guard let url = URL(string: Config.apiBaseURL + "/api/v1/login") else {
            print("❌ Invalid URL for login")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Error: Invalid response from server during login.")
                return false
            }
            
            let decodedResponse = try JSONDecoder().decode(TokenExchangeResponse.self, from: data)
            
            keychain.save(token: decodedResponse.accessToken)
            
            self.isLoggedIn = true
            self.user = decodedResponse.user
            
            print("✅ Email/Password login successful.")
            return true
            
        } catch {
            print("❌ Failed to log in with email/password: \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    func registerUser(email: String, password: String) async -> Bool {
        guard let url = URL(string: Config.apiBaseURL + "/api/v1/signup") else {
            print("❌ Invalid URL for signup")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password, "first_name": "New", "last_name": "User"]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                print("❌ Error: Invalid response from server during signup.")
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

    // MARK: - Sign in with Apple
    
    @MainActor
    func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                print("❌ Error: Could not get Apple ID Credential.")
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("❌ Error: Missing identity token.")
                return
            }
            
            guard let tokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("❌ Error: Unable to convert token to string.")
                return
            }
            
            // Отправляем токен на бэкенд
            Task {
                await exchangeAppleTokenForAPIToken(tokenString)
            }
            
        case .failure(let error):
            print("❌ Sign in with Apple failed: \(error.localizedDescription)")
        }
    }
    
    private func exchangeAppleTokenForAPIToken(_ appleToken: String) async {
        guard let url = URL(string: Config.apiBaseURL + "/api/v1/auth/apple") else {
            print("❌ Invalid URL for Apple auth")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["token": appleToken]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Error: Invalid response from server during Apple token exchange.")
                return
            }
            
            let decodedResponse = try JSONDecoder().decode(TokenExchangeResponse.self, from: data)
            
            // Сохраняем токен и обновляем состояние
            keychain.save(token: decodedResponse.accessToken)
            
            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.user = decodedResponse.user
            }
            
            print("✅ Apple Sign-In successful. App token received and saved.")
            
        } catch {
            print("❌ Failed to exchange Apple token: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deleteAccount() async {
        guard let token = keychain.getToken() else {
            print("❌ No token found for deletion.")
            return
        }
        
        guard let url = URL(string: Config.apiBaseURL + "/api/v1/users/me") else {
            print("❌ Invalid URL for account deletion.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                print("❌ Failed to delete account on server.")
                // Тут можно показать ошибку пользователю
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
struct TokenExchangeRequest: Codable {
    let token: String
}

struct TokenExchangeResponse: Codable {
    let accessToken: String
    let user: User
} 