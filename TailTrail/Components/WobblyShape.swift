import SwiftUI

// A refined, neat "wobbly" shape for the paper announcement effect
struct WobblyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 40.0
        let wobbleAmount: CGFloat = 6.0
        let segments = 20

        // Move to the starting point for the top edge
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        
        // Draw top edge with rounded corners
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: .radians(Double.pi), endAngle: .radians(Double.pi * 1.5), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: .radians(Double.pi * 1.5), endAngle: .radians(Double.pi * 2), clockwise: false)
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        
        // Bottom right corner
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: .radians(0), endAngle: .radians(Double.pi * 0.5), clockwise: false)

        // Wobbly bottom edge
        let segmentWidth = (rect.width - 2 * cornerRadius) / CGFloat(segments)
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
        
        for i in (0..<segments).reversed() {
            let xPos = rect.minX + cornerRadius + (CGFloat(i) * segmentWidth)
            let yPos = rect.maxY + CGFloat.random(in: -wobbleAmount...wobbleAmount)
            path.addLine(to: CGPoint(x: xPos, y: yPos))
        }

        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        
        // Bottom left corner
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: .radians(Double.pi * 0.5), endAngle: .radians(Double.pi), clockwise: false)

        // Close path
        path.closeSubpath()
        
        return path
    }
} 