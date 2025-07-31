import SwiftUI

struct NewColorExamples: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("New Color Palette Examples")
                .font(.title.bold())
                .foregroundColor(NewColorPalette.darkBlack)
            
            // Primary Colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Primary Colors")
                    .font(.headline)
                    .foregroundColor(NewColorPalette.darkBlack)
                
                VStack(spacing: 12) {
                    ColorSwatch(color: NewColorPalette.darkBlack, name: "Dark Black", hex: "#0D0D0D")
                    ColorSwatch(color: NewColorPalette.black, name: "Black", hex: "#1E1E1E")
                    ColorSwatch(color: NewColorPalette.lightPurple, name: "Light Purple", hex: "#FEFEFE")
                    ColorSwatch(color: NewColorPalette.lightTeal, name: "Light Teal", hex: "#E8F4F8")
                }
            }
            
            // Secondary Colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Secondary Colors")
                    .font(.headline)
                    .foregroundColor(NewColorPalette.darkBlack)
                
                VStack(spacing: 12) {
                    ColorSwatch(color: NewColorPalette.darkGrey, name: "Dark Grey", hex: "#313131")
                    ColorSwatch(color: NewColorPalette.grey, name: "Grey", hex: "#B6B6B7")
                    ColorSwatch(color: NewColorPalette.subtleGrey, name: "Subtle Grey", hex: "#F0F0F1")
                    ColorSwatch(color: NewColorPalette.white, name: "White", hex: "#FEFEFE")
                }
            }
            
            // Additional Colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Additional Colors")
                    .font(.headline)
                    .foregroundColor(NewColorPalette.darkBlack)
                
                VStack(spacing: 12) {
                    ColorSwatch(color: NewColorPalette.lightOrange, name: "Light Orange", hex: "#FFE8D6")
                    ColorSwatch(color: NewColorPalette.lightLavender, name: "Light Lavender", hex: "#F0E6FF")
                }
            }
            
            // Usage examples
            VStack(spacing: 12) {
                Text("Usage Examples")
                    .font(.headline)
                    .foregroundColor(NewColorPalette.darkBlack)
                
                // Background example
                RoundedRectangle(cornerRadius: 12)
                    .fill(NewColorPalette.primaryBackground)
                    .frame(height: 60)
                    .overlay(
                        Text("Primary Background")
                            .foregroundColor(NewColorPalette.accentLight)
                            .font(.headline)
                    )
                
                // Card example
                RoundedRectangle(cornerRadius: 12)
                    .fill(NewColorPalette.secondaryBackground)
                    .frame(height: 60)
                    .overlay(
                        Text("Secondary Background")
                            .foregroundColor(NewColorPalette.accentLight)
                            .font(.headline)
                    )
                
                // Accent example
                RoundedRectangle(cornerRadius: 12)
                    .fill(NewColorPalette.accentTeal)
                    .frame(height: 60)
                    .overlay(
                        Text("Accent Color")
                            .foregroundColor(NewColorPalette.darkBlack)
                            .font(.headline)
                    )
            }
        }
        .padding()
        .background(NewColorPalette.accentLight)
    }
}

struct ColorSwatch: View {
    let color: Color
    let name: String
    let hex: String
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(NewColorPalette.black.opacity(0.2), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(NewColorPalette.darkBlack)
                
                Text(hex)
                    .font(.caption)
                    .foregroundColor(NewColorPalette.black)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: NewColorPalette.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NewColorExamples()
} 