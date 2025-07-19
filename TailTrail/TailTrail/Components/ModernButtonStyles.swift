import SwiftUI

// Button style with a 3D effect, used on the Landing page
struct ModernLandingButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // The shadow, offset down and right.
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .offset(x: 4, y: 4)

            // The main button content.
            configuration.label
                .font(.headline.bold())
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                )
                // Move the button on press to create a "pushed in" effect
                .offset(x: configuration.isPressed ? 4 : 0, y: configuration.isPressed ? 4 : 0)
        }
        // Animate the entire button style smoothly
        .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Simpler button style for views like Login/Registration
struct SimpleLandingButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.black)
            .padding(.horizontal, 40)
            .padding(.vertical, 15)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
} 