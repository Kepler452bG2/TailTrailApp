import SwiftUI

struct BlockedUsersView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var blockedUsers: [User] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            // Custom header with back button
            HStack {
                Button(action: { 
                    dismiss()
                }) {
                    Image("backicon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Blocked Users")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            
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
                                            .unblockUser(userId: user.id, authManager: authManager)
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
            .listStyle(PlainListStyle())
        }
        .navigationBarHidden(true)
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