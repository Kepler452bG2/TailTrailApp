import SwiftUI
import WebKit

struct GIFView: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Находим URL нашего GIF-файла в проекте
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif") else {
            webView.load(URLRequest(url: URL(string:"about:blank")!))
            return webView
        }
        
        // Загружаем GIF и делаем фон прозрачным
        do {
            let data = try Data(contentsOf: url)
            webView.load(
                data,
                mimeType: "image/gif",
                characterEncodingName: "UTF-8",
                baseURL: url.deletingLastPathComponent()
            )
            webView.scrollView.isScrollEnabled = false
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
        } catch {
            // Если не смогли загрузить, ничего не делаем
        }
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Эта функция нужна для протокола, но нам она не требуется
        uiView.reload()
    }
}

#Preview {
    // Замените "your-gif-name" на имя вашего файла без .gif
    GIFView("your-gif-name")
        .frame(width: 200, height: 200)
} 