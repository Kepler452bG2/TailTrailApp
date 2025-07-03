import SwiftUI

// A refined, neat "wobbly" shape for the paper announcement effect
struct WobblyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 25
        let wobble: CGFloat = 4

        // Start from top-left, moving down to start the curve
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))

        // Top edge with a slight dip
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius), 
                          control: CGPoint(x: rect.midX, y: rect.minY - wobble))

        // Right edge with a slight bulge
        path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY), 
                          control: CGPoint(x: rect.maxX + wobble, y: rect.midY))

        // Bottom edge with a slight dip
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius), 
                          control: CGPoint(x: rect.midX, y: rect.maxY + wobble))
        
        // Left edge with a slight bulge
        path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY), 
                          control: CGPoint(x: rect.minX - wobble, y: rect.midY))
        
        // Close the path by connecting back to the start point
        path.closeSubpath()
        
        return path
    }
} 