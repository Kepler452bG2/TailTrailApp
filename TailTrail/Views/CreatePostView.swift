import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @StateObject private var viewModel = CreatePostViewModel()
    @EnvironmentObject private var postService: PostService
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.theme.background.ignoresSafeArea()

                VStack {
                    if viewModel.currentStep == 1 {
                        PetInfoStep1View()
                    } else {
                        PetInfoStep2View()
                    }
                }
                .environmentObject(viewModel)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.currentStep == 1 ? "Tell us about your pet" : "Complete \(viewModel.petName)'s profile")
                        .font(.headline)
                        .foregroundColor(.theme.primaryText)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.currentStep > 1 {
                        Button(action: { viewModel.goToPreviousStep() }) {
                            Image(systemName: "arrow.left")
                        }
                    }
                }
            }
            .tint(Color.theme.accent)
        }
    }
}

#Preview {
    CreatePostView()
        .preferredColorScheme(.dark)
        .environmentObject(PostService())
} 