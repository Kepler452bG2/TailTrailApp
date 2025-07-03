import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // State for user profile data
    @State private var name = "Ameliani"
    @State private var status = "Pet lover"
    @State private var email = "freelancer@example.com"
    @State private var phone = "+1 (555) 555-5555"
    
    // State for photo picker
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: Image?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Picture
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        if let selectedImage {
                            selectedImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 150))
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        
                        Image(systemName: "pencil.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                            .background(Color.white.clipShape(Circle()))
                    }
                }
                
                // Text Fields
                VStack(alignment: .leading, spacing: 16) {
                    Text("Name")
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("Status")
                    TextField("Status", text: $status)
                        .textFieldStyle(.roundedBorder)

                    Text("Email")
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                    
                    Text("Phone")
                    TextField("Phone", text: $phone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("Save") {
                presentationMode.wrappedValue.dismiss()
            }
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding()
        }
        .onChange(of: selectedPhotoItem) {
            Task {
                if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
    }
} 