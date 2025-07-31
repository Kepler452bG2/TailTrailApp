import SwiftUI
import PhotosUI

struct PetInfoStep2View: View {
    @EnvironmentObject var viewModel: CreatePostViewModel
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showActionSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                FormField(title: "Description", placeholder: "e.g., Very friendly, wearing a red collar", text: $viewModel.description)
                
                // Location section
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.postType == .lost ? "Last Seen Location" : "Found Location")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.orange)
                        Text(viewModel.locationName.isEmpty ? "Getting current location..." : viewModel.locationName)
                            .foregroundColor(viewModel.locationName.isEmpty ? .gray : .primary)
                        Spacer()
                        Button(action: {
                            viewModel.showLocationPicker = true
                        }) {
                            Text("Change")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                FormField(title: "Contact Phone", placeholder: "Your phone number for contact", text: $viewModel.contactPhone)
                    .keyboardType(.phonePad)

                Text("Photos (up to 5)")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // Add Photo Button
                        Button(action: {
                            showActionSheet = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                VStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                    Text("Add Photo")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .frame(width: 100, height: 100)
                        }
                        
                        // Display selected images
                        ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                // Delete button
                                Button(action: {
                                    viewModel.selectedImages.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                }
                                .offset(x: 5, y: -5)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $viewModel.showLocationPicker) {
            LocationPickerView(
                selectedLocation: $viewModel.selectedLocation,
                locationName: $viewModel.locationName
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: Binding(
                get: { nil },
                set: { newImage in
                    if let image = newImage {
                        viewModel.selectedImages.append(image)
                    }
                }
            ), sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: Binding(
                get: { nil },
                set: { newImage in
                    if let image = newImage {
                        viewModel.selectedImages.append(image)
                    }
                }
            ), sourceType: .camera)
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Add Photo"),
                message: Text("Choose how you want to add a photo"),
                buttons: [
                    .default(Text("Take Photo")) {
                        showCamera = true
                    },
                    .default(Text("Choose from Library")) {
                        showImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
    }
}

// Re-using the same FormField from Step 1 for consistency.
private struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            TextField(placeholder, text: $text)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct PetInfoStep2View_Previews: PreviewProvider {
    static var previews: some View {
        let auth = AuthenticationManager()
        let service = PostService(authManager: auth)
        PetInfoStep2View()
            .environmentObject(CreatePostViewModel(postService: service))
    }
} 