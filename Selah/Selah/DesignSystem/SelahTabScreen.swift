import SwiftUI

struct SelahTabScreen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .selahCanvas()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .toolbarBackground(SelahColors.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .background(SelahColors.background.ignoresSafeArea())
    }
}
