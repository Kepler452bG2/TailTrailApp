import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("general_settings")) {
                    NavigationLink(destination: BlockedUsersView()) {
                        Text("blocked_users")
                    }
                }

                Section(header: Text("Legal")) {
                    if let url = URL(string: "https://github.com/Kepler452bG2/tailtrail-support/blob/main/README.md") {
                        Link("Privacy Policy", destination: url)
                    }
                }

                Section(header: Text("app")) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("privacy_policy")
                    }
                    Button(action: {
                        authManager.logout()
                    }) {
                        Text("logout")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
    SettingsView()
        .environmentObject(AuthenticationManager())
    }
} 