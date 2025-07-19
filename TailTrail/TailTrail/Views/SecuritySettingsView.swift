import SwiftUI

struct SecuritySettingsView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @Environment(\.presentationMode) var presentationMode
    
    private var isFormValid: Bool {
        !currentPassword.isEmpty && !newPassword.isEmpty && newPassword == confirmPassword
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            VStack(spacing: 20) {
                // Custom Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(Color(hex: "#3E5A9A"))
                    }
                    Spacer()
                    Text("Security")
                        .font(.title2.bold())
                        .foregroundColor(Color(hex: "#3E5A9A"))
                    Spacer()
                    // Spacer to balance the back button
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding()
                .background(Color.white)


                VStack(spacing: 15) {
                    Text("CHANGE PASSWORD")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    SecureField("Current Password", text: $currentPassword)
                        .textFieldStyle(ModernTextFieldStyle())
                    SecureField("New Password", text: $newPassword)
                        .textFieldStyle(ModernTextFieldStyle())
                    SecureField("Confirm New Password", text: $confirmPassword)
                        .textFieldStyle(ModernTextFieldStyle())
                }
                .padding()

                Spacer()

                Button("Save Changes") {
                    // TODO: Add logic to change password
                    print("Password change logic goes here.")
                }
                .buttonStyle(ModernButtonStyle(
                    backgroundColor: isFormValid ? Color(hex: "#3E5A9A") : .gray,
                    isDisabled: !isFormValid
                ))
                .disabled(!isFormValid)
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    SecuritySettingsView()
} 