import SwiftUI
import WebKit

struct PrivacyPolicyView: View {
    private let urlString: String = "https://kepler452bg2.github.io/tailtrail-support/"

    var body: some View {
        WebView(urlString: urlString)
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        PrivacyPolicyView()
        }
    }
} 