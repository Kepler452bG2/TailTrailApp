import SwiftUI

// MARK: - Reusable UI Components for Authentication

struct AuthTextField: View {
    let title: String
    @Binding var text: String
    @Binding var isValid: Bool
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.weight(.semibold))
            
            HStack {
                Group {
                    if isSecure {
                        SecureField("Enter \(title.lowercased())", text: $text)
                    } else {
                        TextField("Enter \(title.lowercased())", text: $text)
                            .keyboardType(keyboardType)
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

struct AuthButton: View {
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

struct GoogleSignInButton: View {
    @Binding var isLoggingIn: Bool
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Button(action: {
            Task {
                isLoggingIn = true
                await authManager.signInWithGoogle()
                isLoggingIn = false
            }
        }) {
            HStack {
                Image(systemName: "g.circle.fill")
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 24, height: 24)
                Text("Sign in with Google")
                    .fontWeight(.bold).foregroundColor(.black)
            }
            .frame(maxWidth: .infinity).padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 1.5))
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .font(.title2)
                .foregroundColor(configuration.isOn ? .blue : .secondary)
        }
    }
} 