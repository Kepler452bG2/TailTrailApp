import SwiftUI
import AVKit

struct WelcomeView: View {
    @Binding var showWelcomeScreen: Bool

    var body: some View {
        ZStack {
            // Video player for the background, filling the screen
            VideoPlayerView()
                .edgesIgnoringSafeArea(.all)

            // Main content
            VStack {
                Spacer()
                
                // Centered text
                Text("Hello Human.")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 5)

                Text("Welcome to TailTrail")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(radius: 5)
                
                Spacer()
                
                // Simple "Get Started" button at the bottom
                Button(action: {
                    withAnimation {
                        showWelcomeScreen = false
                    }
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 50)
            }
        }
    }
}

private struct VideoPlayerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        guard let path = Bundle.main.path(forResource: "cat1", ofType: "mp4") else {
            print("Error: cat1.mp4 not found. Please add it to your project.")
            return UIView()
        }
        
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        
        let playerView = PlayerUIView(playerLayer: playerLayer)
        
        player.isMuted = true
        player.play()
        
        // This sets up the looping.
        context.coordinator.player = player
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        return playerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        var player: AVPlayer?

        @objc func playerDidFinishPlaying(note: NSNotification) {
            player?.seek(to: .zero)
            player?.play()
        }
    }
}

// A helper view to manage the player layer's frame
private class PlayerUIView: UIView {
    private let playerLayer: AVPlayerLayer
    
    init(playerLayer: AVPlayerLayer) {
        self.playerLayer = playerLayer
        super.init(frame: .zero)
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
} 