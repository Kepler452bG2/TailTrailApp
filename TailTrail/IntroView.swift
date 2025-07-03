import SwiftUI

struct IntroView: View {
    @Binding var hasCompletedIntro: Bool

    var body: some View {
        VStack {
            Spacer()
            // Logo and wordmark
            Image(systemName: "pawprint.fill") // Placeholder logo
                .font(.system(size: 80))
                .padding(.bottom, 10)
            Text("TailTrail")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            // Slogan
            Text("Follow the Trail. Find Your Pet.")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
            
            // Get Started Button
            Button(action: {
                withAnimation {
                    hasCompletedIntro = true
                }
            }) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
} 