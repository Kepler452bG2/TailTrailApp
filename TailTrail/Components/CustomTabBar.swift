import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var onCreatePost: () -> Void

    private let tabItems: [(String, Int)] = [
        ("list.bullet", 0),
        ("map.fill", 1),
        ("message.fill", 2),
        ("person.fill", 4)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            HStack(alignment: .center) {
                TabBarButton(icon: tabItems[0].0, tag: tabItems[0].1, selection: $selectedTab)
                TabBarButton(icon: tabItems[1].0, tag: tabItems[1].1, selection: $selectedTab)
                
                Spacer().frame(width: 60)
                
                TabBarButton(icon: tabItems[2].0, tag: tabItems[2].1, selection: $selectedTab)
                TabBarButton(icon: tabItems[3].0, tag: tabItems[3].1, selection: $selectedTab)
            }
            .padding(.horizontal)
            .frame(height: 65)
            .background(Color.theme.tabBarBackground)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

            Button(action: onCreatePost) {
                ZStack {
                    Circle()
                        .fill(Color.theme.tabBarSelected)
                        .frame(width: 68, height: 68)
                        .shadow(radius: 4)
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .offset(y: -32)
        }
        .frame(height: 100)
        .padding(.horizontal)
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
            withAnimation(.spring()) {
                selection = tag
            }
        }) {
            VStack {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color.theme.tabBarSelected)
                            .frame(width: 60, height: 40)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: isSelected ? .bold : .regular))
                        .foregroundColor(.black)
                }
                .frame(width: 70, height: 50)
            }
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