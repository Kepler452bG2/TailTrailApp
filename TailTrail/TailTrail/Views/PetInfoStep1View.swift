import SwiftUI

struct PetInfoStep1View: View {
    @EnvironmentObject var viewModel: CreatePostViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Post Type Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("What happened?")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        PostTypeButton(
                            title: "I Lost My Pet",
                            icon: "exclamationmark.triangle.fill",
                            isSelected: viewModel.postType == .lost,
                            color: .red
                        ) {
                            viewModel.postType = .lost
                        }
                        
                        PostTypeButton(
                            title: "I Found a Pet",
                            icon: "heart.fill",
                            isSelected: viewModel.postType == .found,
                            color: .green
                        ) {
                            viewModel.postType = .found
                        }
                    }
                }
                
                FormField(title: "Pet's Name", placeholder: viewModel.postType == .lost ? "e.g., Bobby" : "e.g., Unknown", text: $viewModel.petName)

                Text("Species").font(.headline)
                Picker("Species", selection: $viewModel.selectedSpecies) {
                    ForEach(PetSpecies.allCases) { species in
                        Text(species.rawValue.capitalized).tag(species)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())


                FormField(title: "Breed", placeholder: "e.g., Golden Retriever", text: $viewModel.petBreed)
                FormField(title: "Color", placeholder: "e.g., Golden", text: $viewModel.petColor)

                HStack(spacing: 15) {
                    FormField(title: "Age (years)", placeholder: "e.g., 5", text: $viewModel.petAge)
                        .keyboardType(.numberPad)
                    FormField(title: "Weight (kg)", placeholder: "e.g., 15", text: $viewModel.petWeight)
                        .keyboardType(.decimalPad)
                }

                Text("Gender").font(.headline)
                Picker("Gender", selection: $viewModel.selectedGender) {
                    ForEach(PetGender.allCases, id: \.self) { gender in
                        Text(gender.rawValue.capitalized).tag(gender)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()
        }
        .background(Color(.systemGray6)) // Match container background
    }
}

// A reusable view for text input fields
private struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(ModernTextFieldStyle())
        }
    }
}

// Post type selection button
private struct PostTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PetInfoStep1View_Previews: PreviewProvider {
    static var previews: some View {
        let auth = AuthenticationManager()
        let service = PostService(authManager: auth)
        PetInfoStep1View()
            .environmentObject(CreatePostViewModel(postService: service))
    }
} 