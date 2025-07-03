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
}


// --- Create these colors in your Asset Catalog ---
// 1. Name: BackgroundColor -> #0D0E26 (Dark Navy Blue)
// 2. Name: CardBackgroundColor -> #202143 (Slightly Lighter Navy)
// 3. Name: PrimaryTextColor -> #FFFFFF (White) 