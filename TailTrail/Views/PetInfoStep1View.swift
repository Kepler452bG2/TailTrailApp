import SwiftUI

struct PetInfoStep1View: View {
    @EnvironmentObject var viewModel: CreatePostViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Let's start with your pet's basic info")
                    .font(.headline)
                    .foregroundColor(.theme.secondaryText)
                
                // Name & Breed
                TextField("Pet name", text: $viewModel.petName)
                    .textFieldStyle(CustomTextFieldStyle())
                
                HStack {
                    TextField("Breed", text: $viewModel.breed)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    TextField("Color", text: $viewModel.color)
                        .textFieldStyle(CustomTextFieldStyle())

                    Toggle("Mixed breed", isOn: $viewModel.isMixedBreed)
                        .labelsHidden()
                        .tint(Color.theme.accent)
                }
                
                // Age Slider
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age: \(String(format: "%.1f", viewModel.age)) years")
                    Slider(value: $viewModel.age, in: 0...15, step: 0.5)
                        .tint(Color.theme.accent)
                }

                // Gender
                CustomPicker(title: "Gender", selection: $viewModel.gender)
                
                // Spayed/Neutered
                CustomPicker(title: "Spayed/neutered", selection: $viewModel.spayedStatus)
                
                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight")
                    WeightPicker(selection: $viewModel.weight)
                }

                // Continue Button
                Button(action: { viewModel.goToNextStep() }) {
                    Image(systemName: "arrow.right")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .tint(Color.theme.accent)
            }
            .padding()
        }
        .foregroundColor(Color.theme.primaryText)
    }
}

// MARK: - Reusable Components

private struct CustomPicker<T: RawRepresentable & Hashable & CaseIterable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
            HStack {
                ForEach(Array(T.allCases), id: \.self) { value in
                    Button(action: { selection = value }) {
                        Text(value.rawValue)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selection == value ? Color.theme.accent.opacity(0.3) : Color.theme.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selection == value ? Color.theme.accent : Color.clear, lineWidth: 2)
                            )
                    }
                }
            }
        }
    }
}

private struct WeightPicker: View {
    @Binding var selection: PetWeight

    var body: some View {
        HStack {
            ForEach(PetWeight.allCases, id: \.self) { weight in
                Button(action: { selection = weight }) {
                    VStack {
                        Image(systemName: "dog.fill") // Placeholder icon
                            .font(.title)
                        Text(weight.rawValue)
                            .font(.caption)
                        Text(weight.subtitle)
                            .font(.caption2)
                            .foregroundColor(.theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selection == weight ? Color.theme.accent.opacity(0.3) : Color.theme.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selection == weight ? Color.theme.accent : Color.clear, lineWidth: 2)
                    )
                }
            }
        }
    }
}


#Preview {
    PetInfoStep1View()
        .environmentObject(CreatePostViewModel())
        .preferredColorScheme(.dark)
} 