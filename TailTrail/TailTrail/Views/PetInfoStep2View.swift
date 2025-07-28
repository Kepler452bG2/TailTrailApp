import SwiftUI
import PhotosUI

struct PetInfoStep2View: View {
    @EnvironmentObject var viewModel: CreatePostViewModel

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
                        PhotosPicker(
                            selection: $viewModel.selectedPhotoItems,
                            maxSelectionCount: 5,
                            matching: .images
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 100, height: 100)
                        }
                        
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
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