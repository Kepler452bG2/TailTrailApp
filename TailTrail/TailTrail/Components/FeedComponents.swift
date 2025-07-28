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
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SegmentedControlButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(isSelected ? .bold : .medium)
                
                Text("\(count)")
                    .font(.caption.bold())
                    .padding(6)
                    .background(isSelected ? Color.white.opacity(0.3) : Color.black.opacity(0.1))
                    .clipShape(Circle())
            }
            .foregroundColor(isSelected ? .white : .black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? Color(red: 255/255, green: 196/255, blue: 0/255) : Color.clear)
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SimplePetCardView: View {
    let color: Color
    let count: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "pawprint.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                )
            
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("pets".localized())
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 100, height: 120)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 