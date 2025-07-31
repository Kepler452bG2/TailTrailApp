import SwiftUI

struct HelperCircleView: View {
    let helper: Helper

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: helper.avatarName)
                    .font(.system(size: 50))
                    .foregroundColor(Color.theme.primaryText)
                    .frame(width: 70, height: 70)
                    .background(Color.theme.cardBackground)
                    .clipShape(Circle())

                if helper.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .background(Color.theme.background.clipShape(Circle()))
                        .offset(x: 5, y: 5)
                }
            }
            
            Text(helper.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.primaryText)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", helper.rating))
                    .foregroundColor(Color.theme.secondaryText)
            }
            .font(.caption)
        }
    }
}

#Preview {
    HelperCircleView(
        helper: Helper(
            id: UUID(),
            name: "Sample Helper",
            avatarName: "person.fill",
            rating: 4.5,
            bio: "Sample bio",
            isVerified: true
        )
    )
} 