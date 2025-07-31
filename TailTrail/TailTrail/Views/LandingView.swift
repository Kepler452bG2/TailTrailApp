import SwiftUI

struct LandingView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Full-screen background, aligned to keep the dog's face in view.
                GeometryReader { geo in
                    Image("pet")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .trailing)
                        .clipped()
                }
                .edgesIgnoringSafeArea(.all)

                // 2. Subtle gradient from the bottom for text readability
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: UIScreen.main.bounds.height / 2)
                }
                .edgesIgnoringSafeArea(.all)

                // 3. All content is now centered and pushed to the bottom.
                VStack {
                    Spacer()

                    // Made with asset
                    Image("made")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300)
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                    // PetsAsset below made
                    Image("PetsAsset")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 200)
                        .padding(.horizontal)
                        .padding(.bottom, 30)

                    VStack(spacing: 15) {
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                        }
                        .buttonStyle(SimpleLandingButtonStyle(backgroundColor: Color(hex: "#98FB98")))

                        NavigationLink(destination: RegistrationView()) {
                            Text("Create Account")
                        }
                        .buttonStyle(SimpleLandingButtonStyle(backgroundColor: Color(hex: "#FFD700")))
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    LandingView()
} 