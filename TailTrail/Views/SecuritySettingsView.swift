import SwiftUI

struct SecuritySettingsView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        Form {
            Section(header: Text("Change Password")) {
                SecureField("Current Password", text: $currentPassword)
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmPassword)
            }
            
            Button("Save Changes") {
                // TODO: Add logic to change password
                print("Password change logic goes here.")
            }
            .disabled(newPassword.isEmpty || newPassword != confirmPassword)
        }
        .navigationTitle("Security")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SecuritySettingsView()
    }
} 