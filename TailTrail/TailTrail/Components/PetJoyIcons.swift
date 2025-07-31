import SwiftUI

// MARK: - PetJoy Style Icons using SF Symbols

struct PetJoyIcons {
    // Navigation Icons
    static let home = "house.fill"
    static let search = "magnifyingglass"
    static let profile = "person.fill"
    static let notifications = "bell.fill"
    static let messages = "message.fill"
    static let map = "map.fill"
    
    // Pet Related Icons
    static let paw = "pawprint.fill"
    static let dog = "dog.fill"
    static let cat = "cat.fill"
    static let bird = "bird.fill"
    static let heart = "heart.fill"
    static let location = "mappin.circle.fill"
    static let camera = "camera.fill"
    
    // Action Icons
    static let plus = "plus.circle.fill"
    static let edit = "pencil.circle.fill"
    static let delete = "trash.circle.fill"
    static let share = "square.and.arrow.up"
    static let favorite = "heart.circle.fill"
    static let settings = "gearshape.fill"
    
    // Status Icons
    static let lost = "exclamationmark.triangle.fill"
    static let found = "checkmark.circle.fill"
    static let warning = "exclamationmark.circle.fill"
    static let success = "checkmark.seal.fill"
    
    // UI Icons
    static let chevronRight = "chevron.right"
    static let chevronLeft = "chevron.left"
    static let chevronDown = "chevron.down"
    static let chevronUp = "chevron.up"
    static let close = "xmark.circle.fill"
    static let back = "arrow.left.circle.fill"
    
    // Pet Categories
    static let allPets = "pawprint.circle.fill"
    static let other = "questionmark.circle.fill"
}

// MARK: - PetJoy Icon View

struct PetJoyIcon: View {
    let iconName: String
    let size: CGFloat
    let color: Color
    
    init(_ iconName: String, size: CGFloat = 24, color: Color = PetJoyColors.primaryBlue) {
        self.iconName = iconName
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size, weight: .medium))
            .foregroundColor(color)
    }
}

// MARK: - Predefined PetJoy Icons

struct PetJoyIconButton: View {
    let iconName: String
    let size: CGFloat
    let color: Color
    let action: () -> Void
    
    init(_ iconName: String, size: CGFloat = 24, color: Color = PetJoyColors.primaryBlue, action: @escaping () -> Void) {
        self.iconName = iconName
        self.size = size
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(PetJoyColors.backgroundGray)
                    .frame(width: size + 20, height: size + 20)
                
                PetJoyIcon(iconName, size: size, color: color)
            }
        }
    }
} 