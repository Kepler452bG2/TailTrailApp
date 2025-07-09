import SwiftUI
import PhotosUI

struct UserProfileCard: View {
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var showingSettings = false
    
    // State to hold the profile data
    @State private var name = "Ameliani"
    @State private var bio = "Pet lover"
    @State private var phone = "+1 (555) 123-4567"

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                if let selectedImage {
                    selectedImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.gray.opacity(0.3))
                }
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: "camera.circle.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }
            .onChange(of: selectedPhotoItem) {
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = Image(uiImage: uiImage)
                    }
                }
            }
            
            Text(name)
                .font(.largeTitle.bold())
            
            Text(bio)
                .font(.headline)
                .foregroundColor(.gray)
            
            NavigationLink(destination: NewEditProfileView(name: $name, bio: $bio, phone: $phone)) {
                Text("Edit Profile")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .clipShape(Capsule())
            }
        }
        .padding(30)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.black, lineWidth: 2)
        )
        .padding()
    }
}

#Preview {
    UserProfileCard()
        .background(Color.gray)
} 