import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var onCreatePost: () -> Void

    private let tabItems: [(String, Int)] = [
        ("house.fill", 0),
        ("magnifyingglass", 1),
        ("message.fill", 2),
        ("mic.fill", 3),
        ("person.fill", 4)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
            
            HStack(alignment: .center) {
                TabBarButton(icon: tabItems[0].0, tag: tabItems[0].1, selection: $selectedTab)
                SearchTabButton(tag: tabItems[1].1, selection: $selectedTab)
                
                Spacer().frame(width: 70)
                
                TabBarButton(icon: tabItems[2].0, tag: tabItems[2].1, selection: $selectedTab)
                TabBarButton(icon: tabItems[3].0, tag: tabItems[3].1, selection: $selectedTab)
                TabBarButton(icon: tabItems[4].0, tag: tabItems[4].1, selection: $selectedTab)
            }
            .frame(height: 70)
            .background(
                Capsule()
                    .fill(Color.white)
                    .overlay(
                        Capsule()
                            .stroke(Color.black, lineWidth: 0.5)
                            .mask(
                                Rectangle()
                                    .frame(height: 35)
                                    .offset(y: -17.5)
                            )
                    )
            )

            Button(action: onCreatePost) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.698, green: 0.878, blue: 0.855))
                        .frame(width: 65, height: 65)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .offset(y: -20) // Опускаем кнопку с лапкой
        }
                .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct TabBarButton: View {
    let icon: String
    let tag: Int
    @Binding var selection: Int

    var isSelected: Bool {
        selection == tag
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selection = tag
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color(red: 0.698, green: 0.878, blue: 0.855))
                            .frame(width: 60, height: 35)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? .black : .black.opacity(0.7))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .frame(width: 60, height: 45)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct SearchTabButton: View {
    let tag: Int
    @Binding var selection: Int

    var isSelected: Bool {
        selection == tag
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selection = tag
            }
        }) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? 
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.698, green: 0.878, blue: 0.855),
                                Color(red: 0.698, green: 0.878, blue: 0.855).opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) : LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .frame(maxWidth: .infinity)
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(0), onCreatePost: {})
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.gray.opacity(0.1))
    }
} 