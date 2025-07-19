import SwiftUI
import AuthenticationServices

struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeToTerms = false
    @State private var isPasswordVisible = false
    @State private var isSigningUp = false
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && password == confirmPassword && agreeToTerms
    }

    var body: some View {
        ZStack {
            Image("catanddog")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            ScrollView {
        VStack(spacing: 20) {
                    Text("Sign Up to Continue")
                        .font(.largeTitle.bold())
                        .padding(.top, 40)

                    TextField("Email", text: $email)
                        .textFieldStyle(ModernTextFieldStyle())

                    // Password Field with inline icon
                    ZStack(alignment: .trailing) {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .textFieldStyle(ModernTextFieldStyle())
                                .autocapitalization(.none)
                        } else {
                            SecureField("Password", text: $password)
                                .textFieldStyle(ModernTextFieldStyle())
                .autocapitalization(.none)
                        }
                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 15)
                        }
                    }

                    // Confirm Password Field with inline icon
                    ZStack(alignment: .trailing) {
                        if isPasswordVisible {
                            TextField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(ModernTextFieldStyle())
                                .autocapitalization(.none)
                        } else {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(ModernTextFieldStyle())
                                .autocapitalization(.none)
                        }
                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 15)
                        }
                    }

                    HStack {
                        Button(action: { agreeToTerms.toggle() }) {
                            Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreeToTerms ? .yellow : .gray)
                        }
                        
                        Text("I agree to the [Terms & Privacy Policy](https://github.com/Kepler452bG2/tailtrail-support/blob/main/README.md)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    if isSigningUp {
                        ProgressView().padding()
                    } else {
            Button(action: {
                Task {
                    isSigningUp = true
                    let success = await authManager.registerUser(email: email, password: password)
                    if !success {
                                    // Handle error, e.g., show an alert
                    }
                    isSigningUp = false
                }
            }) {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(12)
                        }
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.5)
                    }
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
            HStack {
                            Text("Already have an account?")
                            Text("Login").fontWeight(.bold)
                        }
                    .font(.footnote)
                        .foregroundColor(.accentColor)
            }
                    .padding(.bottom)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 32)
            }
        }
        .navigationBarHidden(true)
    }
} 
