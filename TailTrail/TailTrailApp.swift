//
//  TailTrailApp.swift
//  TailTrail
//
//  Created by Shepard on 30.06.2025.
//

import SwiftUI

@main
struct TailTrailApp: App {
    @StateObject private var postService = PostService()
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var tabBarVisibility = TabBarVisibility()
    @StateObject private var authManager = AuthenticationManager()

    @State private var showIntro: Bool = true // Временно для отладки

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showIntro {
                    IntroView(showIntro: $showIntro)
                } else if !authManager.isAuthenticated {
                    LoginView()
                } else {
                    MainTabView()
                }
            }
            .environmentObject(postService)
            .environmentObject(languageManager)
            .environmentObject(tabBarVisibility)
            .environmentObject(authManager)
        }
    }
}
