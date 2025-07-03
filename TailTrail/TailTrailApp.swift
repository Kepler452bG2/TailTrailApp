//
//  TailTrailApp.swift
//  TailTrail
//
//  Created by Shepard on 30.06.2025.
//

import SwiftUI

@main
struct TailTrailApp: App {
    @AppStorage("hasCompletedIntro") private var hasCompletedIntro: Bool = false
    @StateObject private var postService = PostService()
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var tabBarVisibility = TabBarVisibility()

    var body: some Scene {
        WindowGroup {
            if hasCompletedIntro {
                MainTabView()
                    .environmentObject(postService)
                    .environmentObject(languageManager)
                    .environmentObject(tabBarVisibility)
                    .id(languageManager.currentLanguage)
            } else {
                IntroView(hasCompletedIntro: $hasCompletedIntro)
            }
        }
        .environmentObject(postService)
        .environmentObject(languageManager)
    }
}
