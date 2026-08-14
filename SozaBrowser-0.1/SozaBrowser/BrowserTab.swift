import Foundation
import Combine
import WebKit

final class BrowserTab: ObservableObject, Identifiable {
    let id = UUID()
    let webView: WKWebView

    @Published var title: String = "Новая вкладка"
    @Published var urlString: String = ""
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = false

    init(startURL: URL? = BrowserStore.homeURL) {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.allowsBackForwardNavigationGestures = true

        if let startURL {
            self.webView.load(URLRequest(url: startURL))
            self.urlString = startURL.absoluteString
        }
    }
}
