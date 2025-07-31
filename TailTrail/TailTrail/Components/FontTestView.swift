import SwiftUI

struct FontTestView: View {
    @State private var availableFonts: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Font Test - Poppins")
                    .font(TypographyStyles.h1)
                    .foregroundColor(NewColorPalette.textPrimary)
                
                // Test Poppins fonts
                VStack(alignment: .leading, spacing: 16) {
                    Text("Poppins Bold (H1)")
                        .font(TypographyStyles.h1)
                        .foregroundColor(NewColorPalette.textPrimary)
                    
                    Text("Poppins SemiBold (Subhead)")
                        .font(TypographyStyles.subhead1)
                        .foregroundColor(NewColorPalette.textSecondary)
                    
                    Text("Poppins Regular (Body)")
                        .font(TypographyStyles.body1)
                        .foregroundColor(NewColorPalette.textPrimary)
                }
                
                // Fallback fonts
                VStack(alignment: .leading, spacing: 16) {
                    Text("System Fonts (Fallback)")
                        .font(TypographyStyles.h3)
                        .foregroundColor(NewColorPalette.darkGrey)
                    
                    Text("System Bold")
                        .font(TypographyStyles.h1Fallback)
                        .foregroundColor(NewColorPalette.textPrimary)
                    
                    Text("System SemiBold")
                        .font(TypographyStyles.subhead1Fallback)
                        .foregroundColor(NewColorPalette.textSecondary)
                    
                    Text("System Regular")
                        .font(TypographyStyles.body1Fallback)
                        .foregroundColor(NewColorPalette.textPrimary)
                }
                
                // Available fonts list
                VStack(alignment: .leading, spacing: 12) {
                    Text("Available Fonts")
                        .font(TypographyStyles.h4)
                        .foregroundColor(NewColorPalette.darkGrey)
                    
                    ForEach(availableFonts, id: \.self) { font in
                        Text(font)
                            .font(TypographyStyles.body2)
                            .foregroundColor(NewColorPalette.textLight)
                    }
                }
            }
            .padding()
        }
        .background(NewColorPalette.backgroundLight)
        .onAppear {
            loadAvailableFonts()
        }
    }
    
    private func loadAvailableFonts() {
        var fonts: [String] = []
        
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            if family.contains("Poppins") {
                fonts.append("Family: \(family)")
                for name in names {
                    fonts.append("  - \(name)")
                }
            }
        }
        
        if fonts.isEmpty {
            fonts.append("Poppins fonts not found")
            fonts.append("Check if fonts are added to project and Info.plist")
        }
        
        availableFonts = fonts
    }
}

#Preview {
    FontTestView()
} 