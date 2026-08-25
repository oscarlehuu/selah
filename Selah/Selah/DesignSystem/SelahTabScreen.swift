import SwiftUI

struct SelahTabScreen<Content: View>: View {
    @ViewBuilder var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .selahCanvas()
                .toolbar(.hidden, for: .navigationBar)
        }
        .background(SelahColors.background.ignoresSafeArea())
    }
}
