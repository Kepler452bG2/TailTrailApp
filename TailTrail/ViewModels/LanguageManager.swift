import SwiftUI
import Foundation
import Combine

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: String = "en" {
        didSet {
            print("🔄 Language changed from '\(oldValue)' to '\(currentLanguage)'")
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            updateAppLanguage()
            // Force UI update
            objectWillChange.send()
        }
    }
    
    // Cache for language bundles
    private var languageBundles: [String: Bundle] = [:]
    
    public init() {
        loadLanguage()
        preloadLanguageBundles()
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
    
    private func preloadLanguageBundles() {
        let supportedLanguages = ["en", "ru", "kk"]
        for language in supportedLanguages {
            if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                languageBundles[language] = bundle
            }
        }
    }
    
    private func updateAppLanguage() {
        // Update the app's language immediately
        UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Force UI update by posting notification
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        
        // Force view refresh
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    func localizedString(forKey key: String) -> String {
        // Use cached bundle if available
        if let bundle = languageBundles[currentLanguage] {
            let result = bundle.localizedString(forKey: key, value: nil, table: nil)
            print("🌍 Localized '\(key)' to '\(result)' for language: \(currentLanguage)")
            return result
        }
        
        // Fallback to direct bundle loading
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            print("❌ Language bundle not found for: \(currentLanguage)")
            return NSLocalizedString(key, comment: "")
        }
        
        let result = bundle.localizedString(forKey: key, value: nil, table: nil)
        print("🌍 Localized '\(key)' to '\(result)' for language: \(currentLanguage)")
        return result
    }
    
    func getSystemLanguage() -> String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    func isSystemLanguageSupported() -> Bool {
        let systemLanguage = getSystemLanguage()
        let supportedLanguages = ["en", "ru", "kk"]
        return supportedLanguages.contains(systemLanguage)
    }
    
    func getLanguageDisplayName(for code: String) -> String {
        switch code {
        case "en": return "English"
        case "ru": return "Русский"
        case "kk": return "Қазақша"
        default: return "English"
        }
    }
}

extension String {
    func localized() -> String {
        return LanguageManager.shared.localizedString(forKey: self)
    }
} 