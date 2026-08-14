import SwiftUI

struct TabsView: View {
    @EnvironmentObject private var store: BrowserStore
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.tabs) { tab in
                        tabCard(tab)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Вкладки")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Готово") {
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.addTab()
                        isPresented = false
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func tabCard(_ tab: BrowserTab) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "globe")
                    .foregroundStyle(.secondary)

                Text(tab.title)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                Button {
                    store.closeTab(tab)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Text(displayURL(tab.urlString))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
                .frame(height: 120)
                .overlay {
                    VStack(spacing: 7) {
                        Image(systemName: "safari")
                            .font(.system(size: 28))
                        Text(tab.title)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.secondary)
                    .padding()
                }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay {
            if tab.id == store.selectedTabID {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.primary.opacity(0.25), lineWidth: 1)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            store.selectTab(tab)
            isPresented = false
        }
    }

    private func displayURL(_ value: String) -> String {
        guard let url = URL(string: value), let host = url.host else {
            return value.isEmpty ? "Новая вкладка" : value
        }
        return host
    }
}
