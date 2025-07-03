import SwiftUI
import PhotosUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageManager: LanguageManager
    
    // State for location
    @State private var selectedCountry = "USA"
    
    // Hardcoded location data
    private let countries = ["USA", "Kazakhstan", "Turkey", "Russia"]
    
    // Notification States
    @State private var pushNotifications = true
    @State private var emailNotifications = false
    @State private var locationServices = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text("Settings")
                    .font(.largeTitle.bold())
                    .padding(.horizontal)

                // General Section
                SettingsSection(title: "GENERAL") {
                    Toggle("Push Notifications", isOn: $pushNotifications).tint(.green)
                    Divider()
                    Toggle("Email Notifications", isOn: $emailNotifications).tint(.green)
                }

                // Location Section
                SettingsSection(title: "LOCATION") {
                    Toggle("Enable Location Services", isOn: $locationServices).tint(.green)
                    if locationServices {
                        Divider()
                        Picker("Country", selection: $selectedCountry) {
                            ForEach(countries, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // Language Section
                SettingsSection(title: "LANGUAGE") {
                    NavigationLink(destination: LanguageSelectionView()) {
                       HStack {
                            Text("Language")
                            Spacer()
                            Text(languageManager.currentLanguage.uppercased())
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.theme.background)
        .navigationBarHidden(true)
        .overlay(backButton, alignment: .topTrailing)
        .foregroundColor(.black)
    }
    
    private var backButton: some View {
        Button("Done".localized()) {
            presentationMode.wrappedValue.dismiss()
        }
        .fontWeight(.bold)
        .padding()
        .foregroundColor(.black)
    }
}

// MARK: - Reusable Settings Components

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote.bold())
                .foregroundColor(.gray)
                .padding(.leading)
            
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}

struct LanguageSelectionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        List {
            LanguageButton(title: "English", code: "en", selection: $languageManager.currentLanguage)
            LanguageButton(title: "Русский", code: "ru", selection: $languageManager.currentLanguage)
            LanguageButton(title: "Қазақша", code: "kk", selection: $languageManager.currentLanguage)
        }
        .navigationTitle("Select Language")
    }
}

private struct LanguageButton: View {
    let title: String
    let code: String
    @Binding var selection: String
    
    var isSelected: Bool { code == selection }
    
    var body: some View {
        Button(action: { selection = code }) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .font(.headline)
            .foregroundColor(.primary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageManager.shared)
} 