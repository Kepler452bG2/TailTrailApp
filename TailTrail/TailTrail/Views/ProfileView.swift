import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color from the new palette
                Color(hex: "#22A6A2").ignoresSafeArea() // Teal color

                VStack {
                    // Top profile section
                    profileHeader
                    
                    // White content card with a subtle shadow
                    settingsList
                        .background(Color(.systemBackground)) // Adapts to light/dark mode
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#3E5A9A")) // Blue Icon
                        .padding(10)
                        .background(Color(hex: "#FBCF3A").opacity(0.8)) // Yellow Accent
                        .clipShape(Circle())
                }
            }
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.9))
            
            Text(authManager.user?.email ?? "user@example.com")
                .font(.title.bold())
                .foregroundColor(.white)
            
            Spacer().frame(height: 20)
        }
        .padding()
    }
    
    private var settingsList: some View {
        List {
            SettingsRow(icon: "person.fill", title: "Profile", destination: EditProfileView())
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


#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
} 