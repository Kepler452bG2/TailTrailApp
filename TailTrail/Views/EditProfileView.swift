import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var postService: PostService
    
    // User profile state
    @State private var email: String = ""
    @State private var phone: String = ""
    
    // Image picker state
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    
    // My Posts state
    @State private var myPosts: [Post] = []

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#FF6B6B").ignoresSafeArea()
            
            ScrollView {
                VStack {
                    profileHeader
                    
                    formCard
                        .offset(y: -30)

                    myPostsSection
                        .padding(.horizontal)
                }
            }
        }
        .navigationBarHidden(true)
        .overlay(backButton, alignment: .topLeading)
        .onAppear {
            // Initialize state from authManager here
            self.email = authManager.currentUser?.email ?? ""
            self.phone = authManager.currentUser?.phone ?? ""
            
            Task {
                if let userId = authManager.currentUser?.id {
                    myPosts = await postService.fetchPosts(forUserId: userId)
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                VStack {
                    if let profileImage {
                        profileImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiImage)
                    }
                }
            }
            
            Text(authManager.currentUser?.email ?? "User Email")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Spacer().frame(height: 20)
        }
        .padding()
    }

    private var formCard: some View {
        VStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Email", text: $email)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Button("Save Changes") {
                // TODO: Implement save logic
                print("Saving changes...")
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }

    private var myPostsSection: some View {
        VStack(alignment: .leading) {
            Text("My Posts")
                .font(.title2.bold())
                .padding(.bottom, 5)

            if myPosts.isEmpty {
                Text("You haven't posted anything yet.")
                    .foregroundColor(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(myPosts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PetCardView(post: post)
                        }
                    }
                }
            }
        }
    }

    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding()
        }
    }
}

// Update the preview to pass the authManager
#Preview {
    EditProfileView()
        .environmentObject(PostService(authManager: AuthenticationManager()))
        .environmentObject(AuthenticationManager())
} 