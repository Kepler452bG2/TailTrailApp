import SwiftUI

// MARK: - PetJoy Style Components

struct PetJoyCard: View {
    let content: AnyView
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init<Content: View>(
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.content = AnyView(content())
    }
    
    var body: some View {
        content
            .background(PetJoyColors.backgroundWhite)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: PetJoyColors.shadowLight, radius: shadowRadius, x: 0, y: 4)
    }
}

struct PetJoyButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : PetJoyColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(minWidth: 80, maxWidth: 100)
                .background(
                    isSelected ? 
                    AnyShapeStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                PetJoyColors.primaryBlue,
                                PetJoyColors.primaryBlueLight
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    ) : 
                    AnyShapeStyle(PetJoyColors.backgroundWhite)
                )
                .cornerRadius(20)
                .shadow(
                    color: isSelected ? PetJoyColors.shadowMedium : PetJoyColors.shadowLight,
                    radius: 4, x: 0, y: 2
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PetJoySearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(PetJoyColors.textLight)
                .font(.system(size: 18))
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
                .foregroundColor(PetJoyColors.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(PetJoyColors.backgroundWhite)
        .cornerRadius(16)
        .shadow(color: PetJoyColors.shadowLight, radius: 12, x: 0, y: 6)
    }
}

// PetJoyIconButton moved to PetJoyIcons.swift

struct PetJoyStatusBadge: View {
    let status: String
    let isLost: Bool
    
    var body: some View {
        Text(status)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isLost ? 
                        [PetJoyColors.errorRed, PetJoyColors.warningOrange] :
                        [PetJoyColors.successGreen, PetJoyColors.primaryBlue]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
    }
} 