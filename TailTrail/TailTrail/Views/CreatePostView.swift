import SwiftUI

struct CreatePostView: View {
    @StateObject private var viewModel: CreatePostViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // We need to get the PostService from the environment to pass it to the viewModel
    init(postService: PostService) {
        _viewModel = StateObject(wrappedValue: CreatePostViewModel(postService: postService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                VStack(spacing: 4) {
                    HStack {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(Color(hex: "#3E5A9A"))
                        Spacer()
                    }
                    HStack {
                        Text("New Post")
                            .font(.largeTitle.bold())
                            .foregroundColor(Color(hex: "#3E5A9A"))
                        Spacer()
                    }
                    HStack {
                        Text("Step \(viewModel.currentStep) of 2")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)


                if viewModel.currentStep == 1 {
                    PetInfoStep1View()
                        .environmentObject(viewModel)
                } else {
                    PetInfoStep2View()
                        .environmentObject(viewModel)
                }
                
                Spacer()
                
                // Navigation Buttons
                HStack {
                    if viewModel.currentStep > 1 {
                        Button("Back") {
                            viewModel.goToPreviousStep()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    if viewModel.currentStep == 1 {
                        Button("Next") {
                            viewModel.goToNextStep()
                        }
                        .buttonStyle(ModernButtonStyle(
                            backgroundColor: viewModel.isStep1Valid() ? Color(hex: "#3E5A9A") : .gray,
                            foregroundColor: .white,
                            isDisabled: !viewModel.isStep1Valid()
                        ))
                        .disabled(!viewModel.isStep1Valid())
                    } else {
                        Button(action: {
                            Task {
                                await viewModel.publishPost()
                                if !viewModel.shouldShowAlert {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.5))
                                    .cornerRadius(12)
                            } else {
                                Text("Publish")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6)) // Set background for the whole view
            .navigationBarHidden(true) // Hide the default navigation bar
            .alert(isPresented: $viewModel.shouldShowAlert) {
                Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct CreatePostView_Previews: PreviewProvider {
    static var previews: some View {
        let auth = AuthenticationManager()
        let service = PostService(authManager: auth)
        CreatePostView(postService: service)
    }
} 