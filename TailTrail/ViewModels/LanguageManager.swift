import SwiftUI
import Foundation
import Combine

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: String = "en" {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            updateAppLanguage()
        }
    }
    
    public init() {
        loadLanguage()
    }

    func loadLanguage() {
        // Check if user has manually selected a language
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            self.currentLanguage = savedLanguage
        } else {
            // Use system language if supported, otherwise default to English
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            let supportedLanguages = ["en", "ru", "kk"]
            
            if supportedLanguages.contains(systemLanguage) {
                self.currentLanguage = systemLanguage
            } else {
                self.currentLanguage = "en"
            }
        }
        
        updateAppLanguage()
    }
    
    private func updateAppLanguage() {
        // Update the app's language immediately
        UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    func localizedString(forKey key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
    
    func getSystemLanguage() -> String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    func isSystemLanguageSupported() -> Bool {
        let systemLanguage = getSystemLanguage()
        let supportedLanguages = ["en", "ru", "kk"]
        return supportedLanguages.contains(systemLanguage)
    }
}

extension String {
    func localized() -> String {
        return LanguageManager.shared.localizedString(forKey: self)
    }
} 