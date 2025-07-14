import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var agreesToTerms = false
    
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    @State private var isPhoneValid = false
    
    @State private var isSigningUp = false
    
    private var isFormValid: Bool {
        isEmailValid && isPasswordValid && isPhoneValid && agreesToTerms
    }

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 20) {
                AuthTextField(title: "Email", text: $email, isValid: $isEmailValid)
                    .onChange(of: email) { isEmailValid = email.contains("@") }

                AuthTextField(title: "Password", text: $password, isValid: $isPasswordValid, isSecure: true)
                    .onChange(of: password) { isPasswordValid = password.count >= 6 }
                
                AuthTextField(title: "Phone Number", text: $phone, isValid: $isPhoneValid, keyboardType: .phonePad)
                    .onChange(of: phone) { isPhoneValid = !phone.isEmpty }
                
                TermsAndConditionsView(agreesToTerms: $agreesToTerms)
                
                if isSigningUp {
                    ProgressView().padding(.vertical)
                } else {
                    AuthButton(title: "Sign Up", backgroundColor: .orange, foregroundColor: .white) {
                        Task {
                            isSigningUp = true
                            await authManager.signUpUser(email: email, password: password, phone: phone)
                            isSigningUp = false
                            if authManager.isUserAuthenticated {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                }
                
                Spacer()
            }
            .padding(30)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Sign Up").bold()
            }
        }
    }
}

// MARK: - Terms and Conditions View

private struct TermsAndConditionsView: View {
    @Binding var agreesToTerms: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Toggle(isOn: $agreesToTerms) { }
                .toggleStyle(CheckboxToggleStyle())
            
            Text(termsAttributedString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var termsAttributedString: AttributedString {
        var string = AttributedString("I agree to the Terms of Service and Privacy Policy.")
        
        if let termsRange = string.range(of: "Terms of Service") {
            string[termsRange].link = URL(string: "https://gist.github.com/Kepler452bG2/5361b3e605a78da7d4180834b7a5d903")
            string[termsRange].foregroundColor = .blue
        }
        
        if let policyRange = string.range(of: "Privacy Policy") {
            string[policyRange].link = URL(string: "https://gist.github.com/Kepler452bG2/f2271c5c976bc872fc638de4ec17081f")
            string[policyRange].foregroundColor = .blue
        }
        
        return string
    }
}

// Preview
#if DEBUG
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpView()
                .environmentObject(AuthenticationManager())
        }
    }
}
#endif 