import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor") // Will keep using the default AccentColor for now
    let background = Color("BackgroundColor")
    let cardBackground = Color("CardBackgroundColor")
    let primaryText = Color("PrimaryTextColor")
    let secondaryText = Color("SecondaryTextColor")
    
    // Custom TabBar Colors from the user's palette
    let tabBarBackground = Color(hex: "#FFA500") // Saturated Orange
    let tabBarSelected = Color(hex: "#FFC300")   // Warm Yellow
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


// --- Create these colors in your Asset Catalog ---
// 1. Name: BackgroundColor -> #0D0E26 (Dark Navy Blue)
// 2. Name: CardBackgroundColor -> #202143 (Slightly Lighter Navy)
// 3. Name: PrimaryTextColor -> #FFFFFF (White) 