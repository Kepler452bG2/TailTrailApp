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
            // Background like FeedView
            Color.clear.ignoresSafeArea()

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
                    Image("backicon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
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
                                .foregroundColor(Color.gray.opacity(0.8))
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
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.black)
            
            VStack(spacing: 15) {
                InfoTextField(icon: "person.fill", placeholder: "Name", text: $name)
                InfoTextField(icon: "phone.fill", placeholder: "Phone", text: $phone)
            }
            
            // Save button with profbutton.png
            Button(action: {
                // TODO: Implement save functionality
                print("Save changes requested")
            }) {
                Text("Save Changes")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
        .background(Color.white.opacity(0.3))
        .cornerRadius(20)
    }
    
    private var passwordSection: some View {
        VStack(spacing: 20) {
            Text("Change Password")
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.black)
            
            VStack(spacing: 15) {
                InfoTextField(icon: "lock.fill", placeholder: "Current Password", text: $currentPassword, isSecure: true)
                InfoTextField(icon: "lock.fill", placeholder: "New Password", text: $newPassword, isSecure: true)
                InfoTextField(icon: "lock.fill", placeholder: "Confirm New Password", text: $confirmNewPassword, isSecure: true)
            }
            
            // Change Password button with profbutton.png
            Button(action: {
                // TODO: Implement password change functionality
                print("Change password requested")
            }) {
                Text("Change Password")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
        .background(Color.white.opacity(0.3))
        .cornerRadius(20)
    }
    
    private var deleteButton: some View {
        Button(action: {
            showingDeleteConfirmation = true
        }) {
            Text("Delete Account")
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
}

// Helper view for text fields
private struct InfoTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#3E5A9A"))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.custom("Poppins-Regular", size: 16))
            } else {
                TextField(placeholder, text: $text)
                    .font(.custom("Poppins-Regular", size: 16))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
} 