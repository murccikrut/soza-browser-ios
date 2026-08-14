import SwiftUI

struct BrowserView: View {
    @EnvironmentObject private var store: BrowserStore

    @State private var addressText = ""
    @State private var showTabs = false
    @FocusState private var addressFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            addressBar

            if store.currentTab.isLoading {
                ProgressView()
                    .progressViewStyle(.linear)
                    .frame(height: 2)
            }

            WebView(tab: store.currentTab)
                .id(store.selectedTabID)
                .ignoresSafeArea(.keyboard, edges: .bottom)

            Divider()
            bottomToolbar
        }
        .background(Color(uiColor: .systemBackground))
        .onAppear {
            addressText = store.currentTab.urlString
        }
        .onChange(of: store.selectedTabID) { _ in
            addressText = store.currentTab.urlString
        }
        .onChange(of: store.currentTab.urlString) { newValue in
            if !addressFocused {
                addressText = newValue
            }
        }
        .sheet(isPresented: $showTabs) {
            TabsView(isPresented: $showTabs)
                .environmentObject(store)
        }
    }

    private var addressBar: some View {
        HStack(spacing: 10) {
            Image(systemName: isSecurePage ? "lock.fill" : "globe")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField("Поиск или адрес", text: $addressText)
                .keyboardType(.webSearch)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .focused($addressFocused)
                .submitLabel(.go)
                .onSubmit {
                    store.navigate(addressText)
                    addressFocused = false
                }

            if addressFocused && !addressText.isEmpty {
                Button {
                    addressText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    if store.currentTab.isLoading {
                        store.currentTab.webView.stopLoading()
                    } else {
                        store.currentTab.webView.reload()
                    }
                } label: {
                    Image(systemName: store.currentTab.isLoading ? "xmark" : "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var bottomToolbar: some View {
        HStack {
            toolbarButton("chevron.left", enabled: store.currentTab.canGoBack) {
                store.currentTab.webView.goBack()
            }

            Spacer()

            toolbarButton("chevron.right", enabled: store.currentTab.canGoForward) {
                store.currentTab.webView.goForward()
            }

            Spacer()

            toolbarButton("plus", enabled: true) {
                store.addTab()
            }

            Spacer()

            Button {
                showTabs = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 1.6)
                        .frame(width: 25, height: 25)
                    Text("\(store.tabs.count)")
                        .font(.system(size: 11, weight: .semibold))
                }
                .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            Menu {
                Button {
                    store.currentTab.webView.reload()
                } label: {
                    Label("Обновить", systemImage: "arrow.clockwise")
                }

                Button {
                    store.navigate(BrowserStore.homeURL.absoluteString)
                } label: {
                    Label("Домой", systemImage: "house")
                }

                Divider()

                Text("Soza Browser 0.1")
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 44, height: 44)
            }
        }
        .font(.system(size: 19, weight: .medium))
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .padding(.bottom, 6)
        .background(.ultraThinMaterial)
    }

    private var isSecurePage: Bool {
        guard let url = URL(string: store.currentTab.urlString) else { return false }
        return url.scheme?.lowercased() == "https"
    }

    @ViewBuilder
    private func toolbarButton(_ systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.3)
    }
}
