import SwiftUI

struct SpeciesFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(minWidth: 80, maxWidth: 100)
                .background(
                    isSelected ? 
                    AnyShapeStyle(Color.black) : 
                    AnyShapeStyle(Color(red: 0.996, green: 0.827, blue: 0.643)) // #FED3A4
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.black.opacity(0.3) : Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SegmentedControlButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(isSelected ? .bold : .medium)
                
                Text("\(count)")
                    .font(.caption.bold())
                    .padding(6)
                    .background(
                        isSelected ? 
                        Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.2) : 
                        Color.gray.opacity(0.15)
                    )
                    .clipShape(Circle())
            }
            .foregroundColor(isSelected ? Color(red: 0.2, green: 0.6, blue: 1.0) : Color(red: 0.4, green: 0.4, blue: 0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                isSelected ? 
                AnyShapeStyle(Color.white) : 
                AnyShapeStyle(Color.clear)
            )
            .clipShape(Capsule())
            .shadow(color: isSelected ? Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.2) : .clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SimplePetCardView: View {
    let color: Color
    let count: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "pawprint.fill")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
            
            Text("pets".localized())
                .font(.caption)
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
        }
        .frame(width: 100, height: 120)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.1), radius: 8, x: 0, y: 4)
    }
} 