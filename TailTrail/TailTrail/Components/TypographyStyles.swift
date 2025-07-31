import SwiftUI

// Typography styles from Figma design system using Poppins font
struct TypographyStyles {
    // Heading styles (H1-H8)
    static let h1 = Font.custom("Poppins-Bold", size: 42)
    static let h2 = Font.custom("Poppins-Bold", size: 40)
    static let h3 = Font.custom("Poppins-Bold", size: 36)
    static let h4 = Font.custom("Poppins-Bold", size: 32)
    static let h5 = Font.custom("Poppins-Bold", size: 24)
    static let h6 = Font.custom("Poppins-Bold", size: 20)
    static let h7 = Font.custom("Poppins-Bold", size: 18)
    static let h8 = Font.custom("Poppins-Bold", size: 14)
    
    // Subhead styles (Subhead 1-4)
    static let subhead1 = Font.custom("Poppins-SemiBold", size: 16)
    static let subhead2 = Font.custom("Poppins-SemiBold", size: 14)
    static let subhead3 = Font.custom("Poppins-SemiBold", size: 12)
    static let subhead4 = Font.custom("Poppins-SemiBold", size: 10)
    
    // Body styles (Body 1-3)
    static let body1 = Font.custom("Poppins-Regular", size: 16)
    static let body2 = Font.custom("Poppins-Regular", size: 14)
    static let body3 = Font.custom("Poppins-Regular", size: 12)
    
    // Fallback to system font if Poppins is not available
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

// Text style modifiers
struct TextStyles {
    static func heading1(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.h1)
            .foregroundColor(NewColorPalette.textPrimary)
    }
    
    static func heading2(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.h2)
            .foregroundColor(NewColorPalette.textPrimary)
    }
    
    static func heading3(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.h3)
            .foregroundColor(NewColorPalette.textPrimary)
    }
    
    static func heading4(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.h4)
            .foregroundColor(NewColorPalette.textPrimary)
    }
    
    static func heading5(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.h5)
            .foregroundColor(NewColorPalette.textPrimary)
    }
    
    static func heading6(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.h6)
            .foregroundColor(NewColorPalette.textPrimary)
    }
    
    static func subhead1(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.subhead1)
            .foregroundColor(NewColorPalette.textSecondary)
    }
    
    static func subhead2(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.subhead2)
            .foregroundColor(NewColorPalette.textSecondary)
    }
    
    static func body1(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.body1)
            .foregroundColor(NewColorPalette.textPrimary)
    }
    
    static func body2(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.body2)
            .foregroundColor(NewColorPalette.textPrimary)
    }
    
    static func body3(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.body3)
            .foregroundColor(NewColorPalette.textLight)
    }
    
    static func subhead4(_ text: String) -> some View {
        Text(text)
            .font(TypographyStyles.subhead4)
            .foregroundColor(NewColorPalette.textLight)
    }
}

// Typography examples view
struct TypographyExamples: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Typography System")
                    .font(TypographyStyles.h1)
                    .foregroundColor(NewColorPalette.darkBlack)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Headings")
                        .font(TypographyStyles.h3)
                        .foregroundColor(NewColorPalette.darkGrey)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ag H1 - 42/50").font(TypographyStyles.h1)
                        Text("Ag H2 - 40/40").font(TypographyStyles.h2)
                        Text("Ag H3 - 36/40").font(TypographyStyles.h3)
                        Text("Ag H4 - 32/Auto").font(TypographyStyles.h4)
                        Text("Ag H5 - 24/Auto").font(TypographyStyles.h5)
                        Text("Ag H6 - 20/Auto").font(TypographyStyles.h6)
                        Text("Ag H7 - 18/Auto").font(TypographyStyles.h7)
                        Text("Ag H8 - 14/Auto").font(TypographyStyles.h8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Subheads")
                        .font(TypographyStyles.h3)
                        .foregroundColor(NewColorPalette.darkGrey)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ag Subhead 1 - 16/Auto").font(TypographyStyles.subhead1)
                        Text("Ag Subhead 2 - 14/Auto").font(TypographyStyles.subhead2)
                        Text("Ag Subhead 3 - 12/18").font(TypographyStyles.subhead3)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Body Text")
                        .font(TypographyStyles.h3)
                        .foregroundColor(NewColorPalette.darkGrey)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Body 1 - 16px").font(TypographyStyles.body1)
                        Text("Body 2 - 14px").font(TypographyStyles.body2)
                        Text("Body 3 - 12px").font(TypographyStyles.body3)
                        Text("Subhead 4 - 10px").font(TypographyStyles.subhead4)
                    }
                }
            }
            .padding()
        }
        .background(NewColorPalette.backgroundLight)
    }
}

#Preview {
    TypographyExamples()
} 