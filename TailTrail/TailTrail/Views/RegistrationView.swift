import SwiftUI
import AuthenticationServices

struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSigningUp = false
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("create_account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            TextField("email", text: $email)
                .textFieldStyle(CustomTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("password", text: $password)
                .textFieldStyle(CustomTextFieldStyle())
            
            SecureField("confirm_password", text: $confirmPassword)
                .textFieldStyle(CustomTextFieldStyle())

            Button(action: {
                Task {
                    isSigningUp = true
                    let success = await authManager.registerUser(email: email, password: password)
                    if !success {
                        // Показать ошибку
                        print("Registration failed")
                    }
                    isSigningUp = false
                }
            }) {
                if isSigningUp {
                    ProgressView()
                } else {
                    Text("sign_up")
                }
            }
            .modifier(ModernButtonModifier(color: .green))
            .disabled(isSigningUp || email.isEmpty || password.isEmpty || password != confirmPassword)
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
                .signUp,
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
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Text("already_have_account")
                    Text("login")
                        .fontWeight(.bold)
                }
                .font(.footnote)
            }
        }
        .padding()
        .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
    }
} 
