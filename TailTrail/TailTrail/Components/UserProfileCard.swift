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
        VStack {
            ZStack(alignment: .bottomTrailing) {
                if let selectedImage {
                    selectedImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else if let imageUrl = authManager.currentUser?.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
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
            
            Text(name)
                .font(.largeTitle.bold())
            
            Text(bio)
                .font(.headline)
                .foregroundColor(.gray)
            
            Button(action: onEditProfile) {
                Text("Edit Profile")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#if DEBUG
struct UserProfileCard_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthenticationManager()
        // Manually set a user for previewing purposes
        authManager.currentUser = User(id: UUID().uuidString, name: "Jane Doe", email: "jane.doe@example.com", phone: "123-456-7890", createdAt: "2023-01-01T12:00:00Z", imageUrl: nil)

        return UserProfileCard(
            authManager: authManager,
            name: "Jane Doe",
            bio: "Loves dogs and hiking.",
            onEditProfile: {}
        )
        .padding()
        .background(Color.gray.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
#endif