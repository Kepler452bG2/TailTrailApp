import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @State private var selectedTab = 0
    @State private var showCreatePostSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content view switcher
            Group {
                switch selectedTab {
                case 0: FeedView()
                case 1: MapView()
                case 2: MessagesView(selectedTab: $selectedTab)
                case 3: ProfileView()
                default: FeedView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            if !tabBarVisibility.isHidden {
                customTabBar
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showCreatePostSheet) {
            CreatePostView()
        }
    }

    private var customTabBar: some View {
        HStack {
            TabBarButton(icon: "list.bullet", tag: 0, selection: $selectedTab)
            Spacer()
            TabBarButton(icon: "map", tag: 1, selection: $selectedTab)
            
            Spacer().frame(width: 80) // Placeholder for the elevated button
            
            TabBarButton(icon: "message", tag: 2, selection: $selectedTab)
            Spacer()
            TabBarButton(icon: "person", tag: 3, selection: $selectedTab)
        }
        .padding(.horizontal, 30)
        .frame(height: 70)
        .background(Color.orange)
        .clipShape(Capsule())
        .overlay(
            newPostButton.offset(y: -25)
        )
        .padding(.horizontal)
        .shadow(radius: 10)
    }

    private var newPostButton: some View {
        Button(action: {
            showCreatePostSheet = true
        }) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .padding(24)
                .background(Color(red: 255/255, green: 196/255, blue: 0/255))
                .clipShape(Circle())
                .shadow(radius: 5, y: 3)
        }
    }
}

private struct TabBarButton: View {
    let icon: String
    let tag: Int
    @Binding var selection: Int
    
    var isSelected: Bool { selection == tag }
    
    var body: some View {
        Button(action: { selection = tag }) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 255/255, green: 196/255, blue: 0/255))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 2))
                }
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.black)
            }
            .frame(width: 60, height: 40)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(PostService())
        .environmentObject(LanguageManager.shared)
        .environmentObject(TabBarVisibility())
} 