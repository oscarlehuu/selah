import SwiftUI

struct SelahTabScreen<Content: View>: View {
    @Environment(AppEnvironment.self) private var env
    let title: String
    @ViewBuilder var content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    if env.isDemoMode {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Demo")
                                .font(SelahFont.ui(.caption, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("Demo mode")
                        }
                    }
                }
        }
    }
}
