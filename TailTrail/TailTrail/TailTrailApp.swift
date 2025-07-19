import SwiftUI
import Kingfisher

@main
struct TailTrailApp: App {
    @StateObject private var authManager: AuthenticationManager
    @StateObject private var postService: PostService
    @StateObject private var languageManager: LanguageManager
    @StateObject private var tabBarVisibility = TabBarVisibility()

    init() {
        let authManagerInstance = AuthenticationManager()
        _authManager = StateObject(wrappedValue: authManagerInstance)
        _postService = StateObject(wrappedValue: PostService(authManager: authManagerInstance))
        _languageManager = StateObject(wrappedValue: LanguageManager())
        
        configureKingfisher()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoggedIn {
                    MainTabView(postService: postService)
                } else {
                    LandingView()
                }
            }
            .environmentObject(authManager)
            .environmentObject(postService)
            .environmentObject(languageManager)
            .environmentObject(tabBarVisibility)
            .onAppear {
                languageManager.loadLanguage()
            }
        }
    }

    private func configureKingfisher() {
        let processor = DownsamplingImageProcessor(size: CGSize(width: 400, height: 400))
        KingfisherManager.shared.defaultOptions = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ]
    }
} 
