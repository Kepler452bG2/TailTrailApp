import SwiftUI
import GoogleSignIn

// This is a placeholder file to resolve a build issue.
// If AuthenticationManager is no longer needed, this file can be deleted
// from the project and the filesystem.

class AuthenticationManager: ObservableObject {
    @Published var isUserAuthenticated: Bool = false
    @MainActor var currentToken: String?
    
    var currentUser: User?

    // Structures for login network call
    private struct LoginRequest: Codable {
        let email: String
        let password: String
    }
    
    private struct TokenResponse: Decodable {
        let token: String
    }

    init() {
        // MARK: - For Debugging
        // To bypass login, uncomment these lines and paste your API token.
//        self.isUserAuthenticated = true
//        self.currentToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDVmMGI4MzMtM2ZiZS00MzY0LWE1MmUtMGJiNTdjY2IwNjk1IiwiZXhwIjoxNzUyMzI2MDU5fQ.eDRnFtmkKwco6e70ZwvrlrTvoZLL7fBHk4fF2A6lUHQ"
//        self.currentUser = User(id: "debug_user", email: "debug@example.com")
    }

    func loginUser(email: String, password: String) async {
        let url = URL(string: Config.apiBaseURL + "/api/v1/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // The backend expects a JSON object for login
        let body = LoginRequest(email: email, password: password)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("❌ Failed to encode login request body: \(error)")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ Failed to login. Status: \((response as? HTTPURLResponse)?.statusCode ?? 0). Response: \(errorBody)")
                // Optionally, handle the error on the main thread, e.g., show an alert
                return
            }
            
            let tokenResponse = try JSONDecoder.custom.decode(TokenResponse.self, from: data)
            
            await MainActor.run {
                self.isUserAuthenticated = true
                self.currentToken = tokenResponse.token
                // TODO: Fetch user profile separately after login or decode from token
                self.currentUser = User(id: "logged-in-user", email: email)
                print("✅ Login successful. Token received.")
            }
            
        } catch {
            print("❌ Network error or decoding failed during login: \(error)")
        }
    }

    func signUpUser(email: String, password: String, phone: String) async {
        let url = URL(string: Config.apiBaseURL + "/api/v1/auth/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email,
            "password": password,
            "phone": phone
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("❌ Failed to encode signup request body: \(error)")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ Failed to sign up. Status: \((response as? HTTPURLResponse)?.statusCode ?? 0). Response: \(errorBody)")
                return
            }
            
            print("✅ SignUp successful. Now attempting to log in.")
            // After successful signup, log the user in to get a token
            await loginUser(email: email, password: password)
            
        } catch {
            print("❌ Network error during signup: \(error)")
        }
    }

    func signInWithGoogle() async {
        guard let topVC = UIApplication.shared.keyWindow?.rootViewController else {
            print("❌ No top view controller found")
            return
        }

        do {
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
            
            guard let idToken = gidSignInResult.user.idToken?.tokenString else {
                print("❌ ID Token not found in Google Sign In result")
                return
            }
            
            // Now, exchange the Google ID token for your own backend token
            await exchangeGoogleTokenForAPIToken(googleToken: idToken)

        } catch {
            print("❌ Error during Google Sign In: \(error.localizedDescription)")
            // Handle the error, maybe show an alert to the user
        }
    }

    private func exchangeGoogleTokenForAPIToken(googleToken: String) async {
        // Assume your backend has an endpoint like /auth/google
        let url = URL(string: Config.apiBaseURL + "/api/v1/auth/google")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["token": googleToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ Failed to exchange token. Server response: \(errorBody)")
                return
            }
            
            // Assume the server returns a JSON with your API token, e.g., {"access_token": "..."}
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let apiToken = json["access_token"] as? String {
                
                await MainActor.run {
                    self.isUserAuthenticated = true
                    self.currentToken = apiToken
                    // You might want to decode the user profile from the token or response as well
                    self.currentUser = User(id: "google-user", email: "signed_in_with_google@example.com")
                }
            } else {
                print("❌ Could not parse API token from response.")
            }
            
        } catch {
            print("❌ Network error during token exchange: \(error.localizedDescription)")
        }
    }

    func logout() {
        GIDSignIn.sharedInstance.signOut()
        Task { @MainActor in
            self.isUserAuthenticated = false
            self.currentUser = nil
            self.currentToken = nil
            // Add any other logout logic here, like clearing tokens
        }
    }
}