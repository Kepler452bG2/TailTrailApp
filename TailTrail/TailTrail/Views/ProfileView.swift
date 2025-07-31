import SwiftUI

struct ProfileView: View {
    @State private var showSettings = false
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: LanguageManager
    @ObservedObject var postService: PostService
    @Environment(\.presentationMode) var presentationMode
    
    private var currentLanguageDisplay: String {
        let display = switch languageManager.currentLanguage {
        case "en": "English (US)"
        case "ru": "Русский"
        case "kk": "Қазақша"
        default: "English (US)"
        }
        print("📱 Current language display: \(display) for code: \(languageManager.currentLanguage)")
        return display
    }
    
    // Check if this view is presented as a main tab or as a modal/navigation
    private var isMainTab: Bool {
        // If dismiss environment is available, it means we're in a modal/navigation
        // If we're in the main tab, dismiss won't be available
        return false // Show back button when dismiss is available
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Orange background like other screens
                Color(hex: "FED3A4").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Conditional back button - only show if not in main tab
                    if !isMainTab {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image("backicon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                            }
                            .padding(.leading, 20)
                            .padding(.top, 50)
                            Spacer()
                        }
                    }
                    
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
                        .padding(.top, 20)
                    } else {
                        // Show a loading state or placeholder
                        ProgressView()
                            .frame(height: 200) // Give it some space
                    }
                    
                    // Settings list with orange theme
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
        ScrollView {
            VStack(spacing: 0) {
                // Settings items
                SettingsRow(icon: "bell.fill", title: "notification".localized(), destination: NotificationsView())
                SettingsRow(icon: "lock.fill", title: "security".localized(), destination: SecuritySettingsView())
                // SettingsRow(icon: "hand.raised.fill", title: "blocked_users".localized(), destination: BlockedUsersView()) // Temporarily disabled - backend not implemented
                SettingsRow(icon: "location.fill", title: "location".localized(), destination: LocationSettingsView())
                SettingsRow(icon: "globe", title: "language".localized(), value: currentLanguageDisplay, destination: LanguageSelectionView())
                SettingsRow(icon: "questionmark.circle.fill", title: "help_support".localized(), destination: HelpAndSupportView())
                SettingsRow(icon: "shield.lefthalf.filled", title: "privacy_policy".localized(), destination: PrivacyPolicyView())
                SettingsRow(icon: "heart.fill", title: "Favorites", destination: FavoritesView(postService: postService))
                
                // Logout button
                Button(action: {
                    authManager.logout()
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "arrow.right.to.line")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(width: 30)
                        Text("Logout")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.3))
                }
            }
            .background(Color.white.opacity(0.3))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100) // Add padding to account for the custom tab bar
        }
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
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.black)
                Spacer()
                if let value {
                    Text(value)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.3))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// A placeholder view for unimplemented screens
struct PlaceholderView: View {
    let title: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(hex: "FED3A4").ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image("backicon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text(title)
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding()
                Spacer()
                Text("\(title) screen coming soon!")
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.black)
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(postService: PostService(authManager: AuthenticationManager()))
                .environmentObject(AuthenticationManager())
        }
    }
} 