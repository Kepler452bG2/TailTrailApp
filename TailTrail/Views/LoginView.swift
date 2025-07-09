import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        ZStack {
            // The absolute final, brightest seamless background color
            Color(red: 230/255, green: 255/255, blue: 110/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // GIF is positioned at the top
                GIFView("catgif")
                    .frame(height: 350)

                // Login card is pulled up to a precise, lower position
                mainCard
                    .offset(y: -60) // Lowered the card even further

                Spacer()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var mainCard: some View {
        VStack(spacing: 25) {
            AuthTextField(title: "Email", text: $email, isValid: $isEmailValid)
                .onChange(of: email) { newValue in
                    // Simple validation: contains @ and a dot.
                    isEmailValid = newValue.contains("@") && newValue.contains(".")
                }
            AuthTextField(title: "Password", text: $password, isValid: $isPasswordValid, isSecure: true)
                .onChange(of: password) { newValue in
                    // Simple validation: at least 6 characters.
                    isPasswordValid = newValue.count >= 6
                }
            
            AuthButton(title: "Login", backgroundColor: .orange, foregroundColor: .white) {
                if isEmailValid && isPasswordValid {
                    authManager.isAuthenticated = true
                }
            }
            .disabled(!(isEmailValid && isPasswordValid)) // Disable button if not valid
            .opacity((isEmailValid && isPasswordValid) ? 1.0 : 0.6) // Make it look disabled
            
            HStack(spacing: 0) {
                SocialButton(title: "Gmail", icon: "g_logo", color: Color.red.opacity(0.8))
                SocialButton(title: "Facebook", icon: "f_logo", color: Color.yellow.opacity(0.8))
            }
            .frame(height: 55)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black, lineWidth: 1.5)
            )
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(35)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .padding(.horizontal, 20)
    }

    private var termsText: some View {
        Text("By continuing, you accept our [Terms and Conditions](https://example.com) and [Privacy Policy](https://example.com).")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
}

// MARK: - Subviews for LoginView

private struct HeaderView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Color(red: 236/255, green: 98/255, blue: 126/255)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: "arrow.left")
                        .font(.title3.bold())
                        .padding(12)
                        .background(Color.white.opacity(0.3))
                        .clipShape(Circle())
                    Spacer()
                }
                
                Spacer()
                
                Text("Hello! Welcome Back")
                    .font(.largeTitle.weight(.heavy))
                
                Text("Sign in to Continue")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .foregroundColor(.white)
            .padding(30)
        }
    }
}

private struct AuthTextField: View {
    let title: String
    @Binding var text: String
    @Binding var isValid: Bool
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.weight(.semibold))
            
            HStack {
                Group {
                    if isSecure {
                        SecureField("Enter password", text: $text)
                    } else {
                        TextField("Enter email", text: $text)
                    }
                }
                
                if !text.isEmpty {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isValid ? .green : .red)
                }
            }
            .padding(15)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

private struct AuthButton: View {
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 1.5))
        }
    }
}

private struct SocialButton: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        Button(action: {}) {
            HStack {
                // Placeholder for logo
                Image(systemName: icon.contains("g_") ? "g.circle.fill" : "f.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                Text(title)
                    .fontWeight(.bold)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color)
        }
    }
}

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
} 
