import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("welcome_back")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            TextField("email", text: $email)
                .textFieldStyle(CustomTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("password", text: $password)
                .textFieldStyle(CustomTextFieldStyle())

            Button(action: {
                Task {
                    isLoggingIn = true
                    let success = await authManager.loginUser(email: email, password: password)
                    if !success {
                        // TODO: Show error alert
                        print("Login failed")
                    }
                    isLoggingIn = false
                }
            }) {
                if isLoggingIn {
                    ProgressView()
                } else {
                    Text("login")
                }
            }
            .buttonStyle(SimpleLandingButtonStyle(backgroundColor: .blue))
            .disabled(isLoggingIn || !authManager.isFormValid)
            .padding(.top)
            
            HStack {
                VStack { Divider() }
                Text("or")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                VStack { Divider() }
            }
            .padding(.vertical)
            
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    authManager.handleSignInWithApple(result: result)
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(8)
            
            Spacer()
            
            NavigationLink(destination: RegistrationView()) {
                HStack {
                    Text("dont_have_account")
                    Text("sign_up")
                        .fontWeight(.bold)
                }
                .font(.footnote)
            }
        }
        .padding()
        .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
    }
} 
