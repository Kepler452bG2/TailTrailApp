import SwiftUI

struct ThreeRoundedCornersShape: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Начинаем с верхнего левого угла
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        // Верхний левый скругленный угол
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        // Верхняя грань
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        // Верхний правый скругленный угол
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        // Правая грань до острого угла
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Нижняя грань до скругленного угла
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        // Нижний левый скругленный угол
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        // Левая грань
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        path.closeSubpath()
        return path
    }
} 
 
 
 
 
 