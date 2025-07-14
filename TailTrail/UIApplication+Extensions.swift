import SwiftUI

extension UIApplication {
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible
            .filter { $0.activationState == .foregroundActive }
            // Keep only the scenes of type UIWindowScene
            .first(where: { $0 is UIWindowScene })
            // Get the UIWindowScene
            .flatMap({ $0 as? UIWindowScene })?
            // Get the key window
            .windows
            .first(where: \.isKeyWindow)
    }
} 