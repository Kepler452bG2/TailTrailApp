import SwiftUI

struct BottomWavyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0)) // Top-left
        path.addLine(to: CGPoint(x: rect.width, y: 0)) // Top-right
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.height), control: CGPoint(x: rect.width / 2, y: rect.height + 40))
        path.closeSubpath()
        return path
    }
} 