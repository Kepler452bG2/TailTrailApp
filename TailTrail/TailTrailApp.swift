//
//  TailTrailApp.swift
//  TailTrail
//
//  Created by Shepard on 30.06.2025.
//

import SwiftUI
import GoogleSignIn

@main
struct TailTrailApp: App {
    @StateObject private var authManager: AuthenticationManager
    @StateObject private var postService: PostService
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var tabBarVisibility = TabBarVisibility()
    
    init() {
        let authManager = AuthenticationManager()
        _authManager = StateObject(wrappedValue: authManager)
        _postService = StateObject(wrappedValue: PostService(authManager: authManager))
    }

    @State private var showIntro: Bool = true // Временно для отладки

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showIntro {
                    IntroView(showIntro: $showIntro)
                } else if !authManager.isUserAuthenticated {
                    LoginView()
                } else {
                    MainTabView(postService: postService)
                }
            }
            .onOpenURL { url in
                // Handle the URL that the Google Sign-In SDK sends back to your app.
                GIDSignIn.sharedInstance.handle(url)
            }
            .environmentObject(postService)
            .environmentObject(languageManager)
            .environmentObject(tabBarVisibility)
            .environmentObject(authManager)
        }
    }
}
