import SwiftUI
import PhotosUI

struct NewEditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Bindings to receive data from the parent view
    @Binding var name: String
    @Binding var bio: String
    @Binding var phone: String
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Profile Picture Editor
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        if let selectedImage {
                            selectedImage
                                .resizable().aspectRatio(contentMode: .fill)
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
                            .offset(x: -10, y: -10)
                    }
                }
                
                // Text Fields in a card
                VStack(spacing: 16) {
                    InfoRow(icon: "person.text.rectangle", title: "Nickname", text: $name)
                    Divider()
                    InfoRow(icon: "text.bubble", title: "Bio", text: $bio)
                    Divider()
                    InfoRow(icon: "phone", title: "Contact Phone", text: $phone)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.1), radius: 5)
                
                Spacer()
            }
            .padding()
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("Save Changes") {
                presentationMode.wrappedValue.dismiss()
            }
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
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
    
    private var headerView: some View {
        ZStack {
            // Centered Title
            ZStack {
                // Outlined Text effect
                ZStack {
                    Text("Edit Profile").offset(x: 1, y: 1)
                    Text("Edit Profile").offset(x: -1, y: -1)
                    Text("Edit Profile").offset(x: -1, y: 1)
                    Text("Edit Profile").offset(x: 1, y: -1)
                }
                .font(.largeTitle.bold())
                .foregroundColor(.black)
                
                Text("Edit Profile")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
            }

            // Buttons aligned to edges
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2.bold())
                }
                Spacer()
                Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.body.bold())
                .foregroundColor(.orange)
            }
        }
        .padding(.horizontal)
        .foregroundColor(.black)
    }
}

private struct InfoRow: View {
    let icon: String
    let title: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                TextField("", text: $text)
            }
        }
    }
}

#Preview {
    NavigationView {
        NewEditProfileView(name: .constant("Asellyzh"), bio: .constant("Pet Lover"), phone: .constant("555-1234"))
    }
} 