import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var postService: PostService
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    @StateObject private var createPostViewModel: CreatePostViewModel
    
    @State private var selectedTab: Int = 0
    @State private var isCreatePostViewPresented = false
    
    init(postService: PostService) {
        _createPostViewModel = StateObject(wrappedValue: CreatePostViewModel(postService: postService))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Using a Group to contain the switched views
            tabContent(for: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Show custom tab bar only if it's not hidden
            if !tabBarVisibility.isHidden {
                CustomTabBar(selectedTab: $selectedTab) {
                    isCreatePostViewPresented.toggle()
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $isCreatePostViewPresented) {
            // Provide all necessary environment objects to the sheet
            CreatePostView(postService: postService)
                .environmentObject(createPostViewModel)
                .environmentObject(postService)
                .environmentObject(authManager)
                .environmentObject(languageManager)
                .environmentObject(tabBarVisibility)
        }
    }

    // A ViewBuilder function to handle the tab switching logic
    @ViewBuilder
    private func tabContent(for tab: Int) -> some View {
        switch tab {
        case 0:
            FeedView()
        case 1:
            MapView()
        case 2:
            MessagesView()
        case 3:
            AllCasesListView()
        case 4:
            ProfileView()
        default:
            FeedView()
        }
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock instances for the preview
        let authManager = AuthenticationManager()
        let postService = PostService(authManager: authManager)
        
        // To make the preview work, we need to simulate an authenticated state
        authManager.isLoggedIn = true

        return MainTabView(postService: postService)
            .environmentObject(authManager)
            .environmentObject(postService)
            .environmentObject(LanguageManager.shared)
            .environmentObject(TabBarVisibility())
    }
}
#endif 