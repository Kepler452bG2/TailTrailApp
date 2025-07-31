import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    let languages = [
        ("en", "English", "🇺🇸"),
        ("ru", "Русский", "🇷🇺"),
        ("kk", "Қазақша", "🇰🇿")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("backicon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    LocalizedText(key: "language")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.white)
                
                // Language options
                VStack(spacing: 0) {
                    ForEach(languages, id: \.0) { language in
                        Button(action: {
                            // Immediately change language
                            languageManager.currentLanguage = language.0
                            
                            // Dismiss after a short delay to show the change
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                dismiss()
                            }
                        }) {
                            HStack {
                                Text(language.2)
                                    .font(.system(size: 24))
                                
                                Text(language.1)
                                    .font(.custom("Poppins-Regular", size: 17))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                if languageManager.currentLanguage == language.0 {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.blue)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if language.0 != languages.last?.0 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Info text
                LocalizedText(key: "language_change_instant")
                    .font(.custom("Poppins-Regular", size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                
                Spacer()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LanguageSelectionView()
        .environmentObject(LanguageManager.shared)
} 