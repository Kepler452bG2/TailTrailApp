import SwiftUI

// Complete Design System from Figma
struct DesignSystem {
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let darkBlack = Color(hex: "#0D0D0D")
        static let black = Color(hex: "#1E1E1E")
        static let lightPurple = Color(hex: "#FEFEFE")
        static let lightTeal = Color(hex: "#E8F4F8")
        
        // Secondary Colors
        static let darkGrey = Color(hex: "#313131")
        static let grey = Color(hex: "#B6B6B7")
        static let subtleGrey = Color(hex: "#F0F0F1")
        static let white = Color(hex: "#FEFEFE")
        
        // Additional Colors
        static let lightOrange = Color(hex: "#FFE8D6")
        static let lightLavender = Color(hex: "#F0E6FF")
        
        // Semantic Colors
        static let primary = darkBlack
        static let secondary = black
        static let accent = lightTeal
        static let background = subtleGrey
        static let surface = white
        static let textPrimary = darkBlack
        static let textSecondary = darkGrey
        static let textLight = grey
    }
    
    // MARK: - Typography
    struct Typography {
        // Headings (H1-H8)
        static let h1 = Font.custom("Poppins-Bold", size: 42)
        static let h2 = Font.custom("Poppins-Bold", size: 40)
        static let h3 = Font.custom("Poppins-Bold", size: 36)
        static let h4 = Font.custom("Poppins-Bold", size: 32)
        static let h5 = Font.custom("Poppins-Bold", size: 24)
        static let h6 = Font.custom("Poppins-Bold", size: 20)
        static let h7 = Font.custom("Poppins-Bold", size: 18)
        static let h8 = Font.custom("Poppins-Bold", size: 14)
        
        // Subheads (Subhead 1-4)
        static let subhead1 = Font.custom("Poppins-SemiBold", size: 16)
        static let subhead2 = Font.custom("Poppins-SemiBold", size: 14)
        static let subhead3 = Font.custom("Poppins-SemiBold", size: 12)
        static let subhead4 = Font.custom("Poppins-SemiBold", size: 10)
        
        // Body (Body 1-3)
        static let body1 = Font.custom("Poppins-Regular", size: 16)
        static let body2 = Font.custom("Poppins-Regular", size: 14)
        static let body3 = Font.custom("Poppins-Regular", size: 12)
        
        // Fallback fonts
        static let h1Fallback = Font.system(size: 42, weight: .bold, design: .default)
        static let h2Fallback = Font.system(size: 40, weight: .bold, design: .default)
        static let h3Fallback = Font.system(size: 36, weight: .bold, design: .default)
        static let h4Fallback = Font.system(size: 32, weight: .bold, design: .default)
        static let h5Fallback = Font.system(size: 24, weight: .bold, design: .default)
        static let h6Fallback = Font.system(size: 20, weight: .bold, design: .default)
        static let h7Fallback = Font.system(size: 18, weight: .bold, design: .default)
        static let h8Fallback = Font.system(size: 14, weight: .bold, design: .default)
        
        static let subhead1Fallback = Font.system(size: 16, weight: .semibold, design: .default)
        static let subhead2Fallback = Font.system(size: 14, weight: .semibold, design: .default)
        static let subhead3Fallback = Font.system(size: 12, weight: .semibold, design: .default)
        static let subhead4Fallback = Font.system(size: 10, weight: .semibold, design: .default)
        
        static let body1Fallback = Font.system(size: 16, weight: .regular, design: .default)
        static let body2Fallback = Font.system(size: 14, weight: .regular, design: .default)
        static let body3Fallback = Font.system(size: 12, weight: .regular, design: .default)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 24
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.15)
        static let large = Color.black.opacity(0.2)
    }
}

#Preview {
    Text("Design System")
        .font(DesignSystem.Typography.h1)
        .foregroundColor(DesignSystem.Colors.primary)
} 