import SwiftUI
import GoogleSignIn

struct LoginView: View {
    var body: some View {
        NavigationStack {
            LoginContentView()
        }
    }
}

private struct LoginContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    @State private var isLoggingIn = false
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        ZStack {
            Color(red: 230/255, green: 255/255, blue: 110/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                GIFView("catgif")
                    .frame(height: 350)
                
                mainCard
                    .offset(y: -60)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var mainCard: some View {
        VStack(spacing: 20) {
            AuthTextField(title: "Email", text: $email, isValid: $isEmailValid)
                .onChange(of: email) {
                    isEmailValid = email.contains("@") && email.contains(".")
                }
            
            AuthTextField(title: "Password", text: $password, isValid: $isPasswordValid, isSecure: true)
                .onChange(of: password) {
                    isPasswordValid = password.count >= 6
                }
            
            if isLoggingIn {
                ProgressView().padding(.vertical)
            } else {
                VStack(spacing: 15) {
                    AuthButton(title: "Login", backgroundColor: .black, foregroundColor: .white) {
                        Task {
                            isLoggingIn = true
                            await authManager.loginUser(email: email, password: password)
                            isLoggingIn = false
                        }
                    }
                    .disabled(!(isEmailValid && isPasswordValid))
                    .opacity((isEmailValid && isPasswordValid) ? 1.0 : 0.6)
                    
                    Text("or")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    GoogleSignInButton(isLoggingIn: $isLoggingIn)

                    NavigationLink("Don't have an account? **Sign Up**") {
                        SignUpView()
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.top)
                }
            }
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(35)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .padding(.horizontal, 20)
    }
}


#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
} 
