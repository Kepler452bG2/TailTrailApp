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
            VStack {
                // Step indicator
                HStack {
                    Text("Step \(viewModel.currentStep) of 2")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)

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
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isStep1Valid() ? Color.orange : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
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
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
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