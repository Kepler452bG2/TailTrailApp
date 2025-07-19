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

                Section(header: Text("account_management")) {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Text("delete_account")
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
            .navigationTitle("settings")
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("are_you_sure"),
                    message: Text("account_deletion_warning"),
                    primaryButton: .destructive(Text("delete")) {
                        Task {
                            await authManager.deleteAccount()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationManager())
} 