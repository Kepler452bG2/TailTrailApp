import SwiftUI

struct PetInfoStep1View: View {
    @EnvironmentObject var viewModel: CreatePostViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                FormField(title: "Pet's Name", placeholder: "e.g., Bobby", text: $viewModel.petName)

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

struct PetInfoStep1View_Previews: PreviewProvider {
    static var previews: some View {
        let auth = AuthenticationManager()
        let service = PostService(authManager: auth)
        PetInfoStep1View()
            .environmentObject(CreatePostViewModel(postService: service))
    }
} 