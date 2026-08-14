import SwiftUI

@main
struct SozaApp: App {
    @StateObject private var browserStore = BrowserStore()

    var body: some Scene {
        WindowGroup {
            BrowserView()
                .environmentObject(browserStore)
        }
    }
}
