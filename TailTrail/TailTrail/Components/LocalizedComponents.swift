import SwiftUI

struct OfflineBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.red)
            Text("you_are_offline".localized())
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("error".localized())
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("retry".localized()) {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// LocalizedText component that automatically updates when language changes
struct LocalizedText: View {
    let key: String
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        Text(languageManager.localizedString(forKey: key))
            .onReceive(languageManager.$currentLanguage) { _ in
                // This will trigger a view update when language changes
            }
    }
}

// LocalizedButton component
struct LocalizedButton: View {
    let key: String
    let action: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        Button(action: action) {
            Text(languageManager.localizedString(forKey: key))
        }
        .onReceive(languageManager.$currentLanguage) { _ in
            // This will trigger a view update when language changes
        }
    }
}

// ViewModifier for automatic language updates
struct LocalizedViewModifier: ViewModifier {
    @EnvironmentObject var languageManager: LanguageManager
    
    func body(content: Content) -> some View {
        content
            .onReceive(languageManager.$currentLanguage) { _ in
                // Force view update when language changes
            }
    }
}

extension View {
    func localized() -> some View {
        modifier(LocalizedViewModifier())
    }
} 