import Foundation

enum Config {
    static var apiBaseURL: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String else {
            print("❌ ERROR: Could not find key 'API_BASE_URL' in Info.plist. Make sure it's there and connected to the build configuration.")
            return ""
        }
        guard !urlString.isEmpty, urlString != "$(API_BASE_URL)" else {
             print("❌ ERROR: 'API_BASE_URL' is not being replaced at build time. Check your Xcode project's build configurations are set to use the Debug.xcconfig/Release.xcconfig files.")
             return ""
        }
        print("✅ API Base URL loaded: \(urlString)")
        return urlString
    }()
} 