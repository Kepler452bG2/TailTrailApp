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

extension UIColor {
    convenience init(hex: String) {
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
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}

// PetJoy Color Palette
struct PetJoyColors {
    // Primary Colors
    static let primaryBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let primaryBlueLight = Color(red: 0.3, green: 0.7, blue: 1.0)
    static let primaryBlueDark = Color(red: 0.1, green: 0.5, blue: 0.9)
    
    // Background Colors
    static let backgroundLight = Color(red: 0.98, green: 0.98, blue: 1.0)
    static let backgroundWhite = Color.white
    static let backgroundGray = Color(red: 0.95, green: 0.97, blue: 1.0)
    
    // Text Colors
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)
    static let textLight = Color(red: 0.6, green: 0.6, blue: 0.6)
    
    // Status Colors
    static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warningOrange = Color(red: 1.0, green: 0.5, blue: 0.3)
    static let errorRed = Color(red: 0.9, green: 0.3, blue: 0.3)
    
    // Shadow Colors
    static let shadowLight = Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.1)
    static let shadowMedium = Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.2)
    static let shadowDark = Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.3)
    
    // New Color Palette from Image
    static let darkBlack = Color(hex: "#0D0D0D")
    static let black = Color(hex: "#1E1E1E")
    static let lightPurple = Color(hex: "#FEFEFE") // Very light, almost white
    static let lightTeal = Color(hex: "#E8F4F8") // Light teal/mint green (estimated from image)
}

// Complete Color Palette from Figma Design System
struct NewColorPalette {
    // Primary Colors
    static let darkBlack = Color(hex: "#0D0D0D")
    static let black = Color(hex: "#1E1E1E")
    static let lightPurple = Color(hex: "#FEFEFE") // Very light, almost white
    static let lightTeal = Color(hex: "#E8F4F8") // Light teal/mint green (estimated from visual)
    
    // Secondary Colors
    static let darkGrey = Color(hex: "#313131")
    static let grey = Color(hex: "#B6B6B7")
    static let subtleGrey = Color(hex: "#F0F0F1")
    static let white = Color(hex: "#FEFEFE")
    
    // Additional colors from visual (estimated hex codes based on appearance)
    static let lightOrange = Color(hex: "#FFE8D6") // Light orange/peach
    static let lightLavender = Color(hex: "#F0E6FF") // Light lavender/purple
    
    // Convenience methods for different use cases
    static let primaryBackground = darkBlack
    static let secondaryBackground = black
    static let accentLight = lightPurple
    static let accentTeal = lightTeal
    static let textPrimary = darkBlack
    static let textSecondary = darkGrey
    static let textLight = grey
    static let backgroundLight = subtleGrey
    static let cardBackground = white
}


// --- Create these colors in your Asset Catalog ---
// 1. Name: BackgroundColor -> #0D0E26 (Dark Navy Blue)
// 2. Name: CardBackgroundColor -> #202143 (Slightly Lighter Navy)
// 3. Name: PrimaryTextColor -> #FFFFFF (White) 