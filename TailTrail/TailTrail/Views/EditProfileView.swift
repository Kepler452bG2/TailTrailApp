import SwiftUI
import PhotosUI

@MainActor
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authManager: AuthenticationManager
    
    // User profile state
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    
    // Password state
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    
    // Image picker state
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileUIImage: UIImage?
    @State private var showingDeleteConfirmation = false
    
    // Loading State
    @State private var isSaving = false

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }

    var body: some View {
        ZStack {
            // Background from the image palette
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#1FA6A2"), Color(hex: "#FBCF3A")]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 30) {
                    profileHeader
                    personalInfoSection
                    passwordSection
                    deleteButton
                }
                .padding()
            }
        }
        .onAppear(perform: loadUserData)
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete your account? This action cannot be undone.",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
            Task {
                    // TODO: Implement account deletion
                    print("Delete account requested")
                }
            }
        }
    }

    private func loadUserData() {
        if let user = authManager.currentUser {
            self.name = user.name ?? ""
            self.email = user.email
            self.phone = user.phone ?? ""
        }
    }
    
    private var profileHeader: some View {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                VStack {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let image = MainActor.assumeIsolated({ profileUIImage }) {
                            Image(uiImage: image)
                            .resizable()
                        } else if let imageUrlString = authManager.currentUser?.imageUrl, let url = URL(string: imageUrlString) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                    } else {
                            Image(systemName: "person.fill")
                            .resizable()
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 130, height: 130)
                .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                    
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(hex: "#3E5A9A")) // Blue color for icon
                        .background(Color.white)
                        .clipShape(Circle())
                }
                }
            }
            .onChange(of: selectedPhoto) { oldValue, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            self.profileUIImage = uiImage
                        }
                    }
                    }
                }
            }
            
    private var personalInfoSection: some View {
        VStack(spacing: 20) {
            Text("Personal Information")
                .font(.title2).bold()
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                InfoTextField(icon: "person.fill", placeholder: "Name", text: $name)
                InfoTextField(icon: "phone.fill", placeholder: "Phone", text: $phone)
                    .keyboardType(.phonePad)
            }
            
            ModernButton(title: "Save Changes", action: saveChanges)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }

    private var passwordSection: some View {
        VStack(spacing: 20) {
            Text("Change Password")
                .font(.title2).bold()
                .foregroundColor(.white)

            VStack(spacing: 15) {
                InfoTextField(icon: "lock.fill", placeholder: "Current Password", text: $currentPassword, isSecure: true)
                InfoTextField(icon: "lock.fill", placeholder: "New Password", text: $newPassword, isSecure: true)
                InfoTextField(icon: "lock.fill", placeholder: "Confirm New Password", text: $confirmNewPassword, isSecure: true)
            }
            
            ModernButton(title: "Change Password", action: changePassword)
                .disabled(newPassword.isEmpty || newPassword != confirmNewPassword)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }

    private var deleteButton: some View {
        Button(action: { showingDeleteConfirmation = true }) {
            Text("Delete Account")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
    
    private func saveChanges() {
        isSaving = true
        Task {
            let success = await authManager.updateUserProfile(name: self.name, phone: self.phone, image: self.profileUIImage)
            if success {
                Task {
                    await authManager.fetchUserProfile() // Refresh user data
                }
                presentationMode.wrappedValue.dismiss()
            }
            isSaving = false
        }
    }

    private func changePassword() {
        isSaving = true
        Task {
            // TODO: Implement password change functionality
            print("Password change requested")
            // For now, just dismiss
            isSaving = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// Custom TextField for this view
struct InfoTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .foregroundColor(Color("PrimaryTextColor")) // Use adaptive text color
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.8)) // Use adaptive background
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

// Custom button for this view
struct ModernButton: View {
    let title: String
    let action: () -> Void
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#3E5A9A"), Color(hex: "#1FA6A2")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(15)
                .opacity(isEnabled ? 1.0 : 0.5)
        }
    }
}

#Preview {
    NavigationView {
        EditProfileView(authManager: AuthenticationManager.shared)
    }
} 