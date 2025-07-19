import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @EnvironmentObject var authManager: AuthenticationManager
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    var body: some View {
        ZStack {
            Image("catanddog")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
        VStack(spacing: 20) {
                    Text("Welcome Back")
                        .font(.largeTitle.bold())
                        .padding(.top, 40)
            
                    TextField("Email", text: $email)
                        .textFieldStyle(ModernTextFieldStyle())

                    SecureField("Password", text: $password)
                        .textFieldStyle(ModernTextFieldStyle())

                    if isLoggingIn {
                        ProgressView()
                    } else {
            Button(action: {
                            isLoggingIn = true
                Task {
                                _ = await authManager.loginUser(email: email, password: password)
                    isLoggingIn = false
                }
            }) {
                            Text("Login")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.8), Color.yellow]), startPoint: .top, endPoint: .bottom)
                                )
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.4), radius: 5, y: 5)
                        }
                        .disabled(!isFormValid)
                        .padding(.bottom, 10)
                }
                    
                    // SignInWithAppleButton has been removed.
            
            NavigationLink(destination: RegistrationView()) {
                HStack {
                            Text("Don't have an account?")
                            Text("Sign Up")
                        .fontWeight(.bold)
                }
                .font(.footnote)
                        .foregroundColor(.accentColor)
                    }
                    .padding(.bottom)
        }
        .padding()
                .background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            }
            .padding(.horizontal, 32)
        }
        .navigationBarHidden(true)
    }
} 
