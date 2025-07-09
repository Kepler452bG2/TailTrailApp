import SwiftUI

struct IntroView: View {
    @Binding var showIntro: Bool
    
    var body: some View {
        ZStack {
            // Background color for the entire screen
            Color(red: 245/255, green: 245/255, blue: 245/255).ignoresSafeArea()
            
            // Main content card
            VStack(spacing: 20) {
                decorativeElements
                
                imageGrid
                Spacer()
                headerText
                descriptionText
                Spacer()
                letsGoButton
            }
            .padding(30)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .padding(15)
        }
    }

    private var decorativeElements: some View {
        ZStack {
            // Top-left lines
            Path { path in
                path.move(to: CGPoint(x: 0, y: 15))
                path.addLine(to: CGPoint(x: 15, y: 0))
                path.move(to: CGPoint(x: 10, y: 25))
                path.addLine(to: CGPoint(x: 25, y: 10))
            }
            .stroke(Color.black, lineWidth: 2.5)
            .frame(width: 30, height: 30)
            .position(x: 40, y: 40)
        }
    }

    private var imageGrid: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                Image("dog1")
                    .resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 180)
                    .clipShape(ThreeRoundedCornersShape(cornerRadius: 25).rotation(.degrees(270)))
                Image("cat2")
                    .resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 130)
                    .clipShape(ThreeRoundedCornersShape(cornerRadius: 25).rotation(.degrees(180)))
            }
            HStack(spacing: 15) {
                Image("dog2")
                    .resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 130)
                    .clipShape(ThreeRoundedCornersShape(cornerRadius: 25))
                Image("dog3")
                    .resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 180)
                    .clipShape(ThreeRoundedCornersShape(cornerRadius: 25).rotation(.degrees(90)))
            }
        }
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: -10) {
            Text("Hello")
                .font(.system(size: 50, weight: .heavy))
                .foregroundColor(.black)
            
            ZStack {
                Text("Human").offset(x: 1, y: 1)
                Text("Human").offset(x: -1, y: -1)
                Text("Human").offset(x: -1, y: 1)
                Text("Human").offset(x: 1, y: -1)
            }
            .font(.system(size: 50, weight: .heavy))
            .foregroundColor(.black)
            .overlay(
                Text("Human")
                    .font(.system(size: 50, weight: .heavy))
                    .foregroundColor(.white)
            )
        }
    }

    private var descriptionText: some View {
        Text("Made with ❤️ for pet families everywhere")
            .font(.title3)
            .foregroundColor(.gray)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var letsGoButton: some View {
        Button(action: {
            showIntro = false
        }) {
            Text("Let's Go")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    IntroView(showIntro: .constant(true))
} 
