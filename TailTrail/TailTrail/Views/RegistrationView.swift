import SwiftUI
import AuthenticationServices

struct RegistrationView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeToTerms = false
    @State private var isPasswordVisible = false
    @State private var isSigningUp = false
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword && agreeToTerms
    }

    var body: some View {
        ZStack {
            // Orange background like other screens
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
                
                // Catasset.png in the middle
                Image("catasset")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 180)
                    .padding(.horizontal, 40)
                
                Spacer()

                // Beautiful registration form
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle.bold())
                        .foregroundColor(.black)
                        .padding(.top, 20)

                    // Name field
                    TextField("Full Name", text: $name)
                        .textFieldStyle(ModernTextFieldStyle())
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)

                    // Email field
                    TextField("Email", text: $email)
                        .textFieldStyle(ModernTextFieldStyle())
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .autocapitalization(.none)

                    // Password Field with inline icon
                    ZStack(alignment: .trailing) {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .textFieldStyle(ModernTextFieldStyle())
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Password", text: $password)
                                .textFieldStyle(ModernTextFieldStyle())
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
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
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(ModernTextFieldStyle())
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .autocapitalization(.none)
                        }
                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 15)
                        }
                    }

                    // Terms and Privacy Agreement
                    HStack(alignment: .top, spacing: 12) {
                        Button(action: { agreeToTerms.toggle() }) {
                            Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreeToTerms ? .yellow : .gray)
                                .font(.title2)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("I agree to the")
                                .font(.footnote)
                                .foregroundColor(.black.opacity(0.7))
                            
                            HStack(spacing: 4) {
                                Button("Terms of Service") {
                                    showingTerms = true
                                }
                                .font(.footnote)
                                .foregroundColor(.blue)
                                
                                Text("and")
                                    .font(.footnote)
                                    .foregroundColor(.black.opacity(0.7))
                                
                                Button("Privacy Policy") {
                                    showingPrivacy = true
                                }
                                .font(.footnote)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.top, 10)

                    if isSigningUp {
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding()
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
                            Text("Create Account")
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
                        .opacity(isFormValid ? 1.0 : 0.5)
                    }
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.black.opacity(0.7))
                            Text("Login")
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
        .sheet(isPresented: $showingTerms) {
            NavigationView {
                TermsOfServiceView()
                    .navigationBarItems(trailing: Button("Done") {
                        showingTerms = false
                    })
            }
        }
        .sheet(isPresented: $showingPrivacy) {
            NavigationView {
                PrivacyPolicyView()
                    .navigationBarItems(trailing: Button("Done") {
                        showingPrivacy = false
                    })
            }
        }
    }
} 
