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
            // Orange background like AuthScreenView
            Color(hex: "FED3A4")
                .ignoresSafeArea()
            
            VStack {
                // Made.png at the top
                Image("made")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 250)
                    .padding(.horizontal, 40)
                    .padding(.top, 40)
                
                Spacer()
                
                // Turtle 1 image in the middle
                Image("turtle 1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Login form
                VStack(spacing: 20) {
                    Text("Welcome Back")
                        .font(.largeTitle.bold())
                        .foregroundColor(.black)
                        .padding(.top, 20)
            
                    TextField("Email", text: $email)
                        .textFieldStyle(ModernTextFieldStyle())
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)

                    SecureField("Password", text: $password)
                        .textFieldStyle(ModernTextFieldStyle())
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)

                    if isLoggingIn {
                        ProgressView()
                            .scaleEffect(1.2)
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
                    
                    NavigationLink(destination: RegistrationView()) {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.black.opacity(0.7))
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .font(.footnote)
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 30)
                .background(
                    Color.white.opacity(0.3),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
} 
