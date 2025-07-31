import SwiftUI
import PhotosUI

struct UserProfileCard: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var showingSettings = false
    
    let name: String
    let bio: String
    let onEditProfile: () -> Void

    var body: some View {
        ZStack {
            // Background profile.png image
            Image("profile")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 350)
            
            VStack(spacing: 16) {
                // Avatar section
                ZStack(alignment: .bottomTrailing) {
                    if let selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 8)
                    } else if let imageUrl = authManager.currentUser?.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 8)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white.opacity(0.8))
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 8)
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#3E5A9A"))
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .onChange(of: selectedPhotoItem) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                selectedImage = Image(uiImage: uiImage)
                                // Here you would typically call a method to upload the image
                                // authManager.updateProfile(image: uiImage)
                            }
                        }
                    }
                }
                
                // Name and bio
                Text(name)
                    .font(.custom("Poppins-Bold", size: 24))
                    .foregroundColor(.black)
                
                Text(bio)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                // Edit Profile button
                Button(action: onEditProfile) {
                    Text("edit_profile".localized())
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.8), Color.yellow]), startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(20)
                        .shadow(color: .gray.opacity(0.4), radius: 3, y: 2)
                }
            }
            .padding(.top, 60) // Adjust to position content properly on profile.png
        }
    }
}

#if DEBUG
struct UserProfileCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(hex: "FED3A4").ignoresSafeArea()
            UserProfileCard(
                authManager: AuthenticationManager(),
                name: "John Doe",
                bio: "Pet lover from your city!",
                onEditProfile: {}
            )
        }
    }
}
#endif