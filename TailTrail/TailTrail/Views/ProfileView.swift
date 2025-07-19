import SwiftUI

struct ProfileView: View {
    @State private var showSettings = false
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color from the new palette
                Color(hex: "#22A6A2").ignoresSafeArea() // Teal color

                VStack {
                    // Top profile section
                    if let user = authManager.currentUser {
                        UserProfileCard(
                            authManager: authManager,
                            name: user.name ?? "Anonymous",
                            bio: "Pet lover from your city!", // Placeholder, can be a user property
                            onEditProfile: {
                                showSettings = true
                            }
                        )
                        .padding(.top) // Add some padding at the top
                    } else {
                        // Show a loading state or placeholder
                        ProgressView()
                            .frame(height: 200) // Give it some space
                    }
                    
                    // Restore the settings list
                    settingsList
                }
                .sheet(isPresented: $showSettings) {
                    // Present EditProfileView as a sheet
                    EditProfileView(authManager: authManager)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            if authManager.currentUser == nil {
                Task {
                    await authManager.fetchUserProfile()
                }
            }
        }
    }
    
    private var settingsList: some View {
        List {
            // You can remove the "Profile" row if UserProfileCard handles navigation
            // SettingsRow(icon: "person.fill", title: "Profile", destination: EditProfileView(authManager: authManager))
            SettingsRow(icon: "bell.fill", title: "Notification", destination: NotificationsView())
            SettingsRow(icon: "lock.fill", title: "Security", destination: SecuritySettingsView())
            SettingsRow(icon: "hand.raised.fill", title: "Blocked Users", destination: BlockedUsersView())
            SettingsRow(icon: "location.fill", title: "Location", destination: LocationSettingsView())
            SettingsRow(icon: "globe", title: "Language", value: "English (US)", destination: LanguageSelectionView())
            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", destination: HelpAndSupportView())
            SettingsRow(icon: "shield.lefthalf.filled", title: "Privacy Policy", destination: PrivacyPolicyView())
            SettingsRow(icon: "heart.fill", title: "Favorites", destination: PlaceholderView(title: "Favorites"))
            
            Button(action: {
                authManager.logout()
            }) {
                HStack {
                    Image(systemName: "arrow.right.to.line")
                    Text("Logout")
                }
                .foregroundColor(.red)
            }
        }
        .listStyle(.plain)
        .padding(.top, 10)
        .padding(.bottom, 80) // Add padding to account for the custom tab bar
    }
}

// Reusable row for the settings list
private struct SettingsRow<Destination: View>: View {
    let icon: String
    let title: String
    var value: String? = nil
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#3E5A9A")) // Blue Icon
                    .frame(width: 30)
                Text(title)
                Spacer()
                if let value {
                    Text(value)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// A placeholder view for unimplemented screens
struct PlaceholderView: View {
    let title: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(title)
                    .font(.headline)
                Spacer()
            }
            .padding()
            Spacer()
            Text("\(title) screen coming soon!")
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
    ProfileView()
        .environmentObject(AuthenticationManager())
        }
    }
} 