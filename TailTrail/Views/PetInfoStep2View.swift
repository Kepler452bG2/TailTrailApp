import SwiftUI
import PhotosUI

struct PetInfoStep2View: View {
    @EnvironmentObject var viewModel: CreatePostViewModel
    @State private var showingPhoneAlert = false
    
    let columns = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Complete 's profile")
                .font(.title2.bold())
            
            Text("Almost there! Add a description and some photos.")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Description TextEditor
            TextEditor(text: $viewModel.description)
                .frame(height: 100)
                .padding(8)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))

            // Photo Picker
            PhotosPicker(
                selection: $viewModel.selectedPhotoItems,
                maxSelectionCount: 5,
                matching: .images
            ) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Photos (up to 5)")
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .foregroundColor(.black)
            
            // Selected Photos Preview
            if !viewModel.selectedImages.isEmpty {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.selectedImages, id: \.self) { uiImage in
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            // Action Buttons
            actionButton(icon: "location.fill", text: "Use Current Location") {
                // Action for location
            }
            
            actionButton(icon: "person.badge.plus", text: "Add Trusted Contacts", showsChevron: true) {
                showingPhoneAlert = true
            }

            Spacer()

            // Complete Button
            Button(action: { /* Finalize post creation */ }) {
                Text("Complete")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.theme.background.ignoresSafeArea())
        .foregroundColor(.black)
        .alert("Add Contact Phone", isPresented: $showingPhoneAlert) {
            TextField("Phone Number", text: $viewModel.contactPhone)
                .keyboardType(.phonePad)
            Button("OK", action: {})
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    private func actionButton(icon: String, text: String, showsChevron: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(text)
                if showsChevron {
                    Spacer()
                    Image(systemName: "chevron.right")
                } else {
                    Spacer()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .foregroundColor(.black)
        }
    }
}

#Preview {
    CreatePostView()
} 