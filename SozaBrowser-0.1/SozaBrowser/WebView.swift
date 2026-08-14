import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @ObservedObject var tab: BrowserTab

    func makeCoordinator() -> Coordinator {
        Coordinator(tab: tab)
    }

    func makeUIView(context: Context) -> WKWebView {
        tab.webView.navigationDelegate = context.coordinator
        tab.webView.uiDelegate = context.coordinator
        context.coordinator.refreshState(from: tab.webView)
        return tab.webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.tab = tab
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var tab: BrowserTab

        init(tab: BrowserTab) {
            self.tab = tab
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            refreshState(from: webView)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            refreshState(from: webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            refreshState(from: webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            refreshState(from: webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            refreshState(from: webView)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil,
               let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }

        func refreshState(from webView: WKWebView) {
            DispatchQueue.main.async {
                self.tab.title = webView.title?.isEmpty == false ? webView.title! : "Новая вкладка"
                self.tab.urlString = webView.url?.absoluteString ?? self.tab.urlString
                self.tab.canGoBack = webView.canGoBack
                self.tab.canGoForward = webView.canGoForward
                self.tab.isLoading = webView.isLoading
            }
        }
    }
}
