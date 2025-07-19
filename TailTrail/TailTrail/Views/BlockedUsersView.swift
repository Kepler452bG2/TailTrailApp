import SwiftUI

struct BlockedUsersView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var blockedUsers: [User] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else {
                ForEach(blockedUsers) { user in
                    HStack {
                        Text(user.email)
                        Spacer()
                        Button("Unblock") {
                            Task {
                                do {
                                    try await NetworkManager.shared
                                        .unblockUser(userId: user.id.uuidString, authManager: authManager)
                                    // Remove the user from the local list upon successful unblock
                                    blockedUsers.removeAll { $0.id == user.id }
                                } catch {
                                    print("Failed to unblock user: \(error)")
                                    // Optionally, show an error alert to the user
                                }
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Blocked Users")
        .onAppear(perform: loadBlockedUsers)
    }
    
    private func loadBlockedUsers() {
        isLoading = true
        Task {
            do {
                let users = try await NetworkManager.shared.fetchBlockedUsers(authManager: authManager)
                self.blockedUsers = users
            } catch {
                print("Failed to load blocked users: \(error)")
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        BlockedUsersView()
            .environmentObject(AuthenticationManager())
    }
} 