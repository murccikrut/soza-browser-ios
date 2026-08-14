import Foundation
import Combine

final class BrowserStore: ObservableObject {
    static let homeURL = URL(string: "https://www.google.com")!

    @Published private(set) var tabs: [BrowserTab]
    @Published var selectedTabID: UUID

    private var tabObservers: [UUID: AnyCancellable] = [:]

    init() {
        let firstTab = BrowserTab()
        self.tabs = [firstTab]
        self.selectedTabID = firstTab.id
        observe(firstTab)
    }

    var currentTab: BrowserTab {
        tabs.first(where: { $0.id == selectedTabID }) ?? tabs[0]
    }

    @discardableResult
    func addTab(url: URL? = homeURL, select: Bool = true) -> BrowserTab {
        let tab = BrowserTab(startURL: url)
        tabs.append(tab)
        observe(tab)
        if select {
            selectedTabID = tab.id
        }
        return tab
    }

    func selectTab(_ tab: BrowserTab) {
        selectedTabID = tab.id
    }

    func closeTab(_ tab: BrowserTab) {
        guard let index = tabs.firstIndex(where: { $0.id == tab.id }) else { return }

        if tabs.count == 1 {
            tabObservers[tab.id] = nil
            let replacement = BrowserTab()
            tabs = [replacement]
            selectedTabID = replacement.id
            observe(replacement)
            return
        }

        let wasSelected = selectedTabID == tab.id
        tabs.remove(at: index)
        tabObservers[tab.id] = nil

        if wasSelected {
            let nextIndex = min(index, tabs.count - 1)
            selectedTabID = tabs[nextIndex].id
        }
    }

    func navigate(_ input: String, in tab: BrowserTab? = nil) {
        let targetTab = tab ?? currentTab
        guard let url = Self.resolveInput(input) else { return }
        targetTab.webView.load(URLRequest(url: url))
        targetTab.urlString = url.absoluteString
    }

    private func observe(_ tab: BrowserTab) {
        tabObservers[tab.id] = tab.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
    }

    static func resolveInput(_ rawInput: String) -> URL? {
        let input = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return homeURL }

        if let directURL = URL(string: input),
           let scheme = directURL.scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            return directURL
        }

        if !input.contains(" "), input.contains(".") {
            return URL(string: "https://\(input)")
        }

        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [URLQueryItem(name: "q", value: input)]
        return components?.url
    }
}
