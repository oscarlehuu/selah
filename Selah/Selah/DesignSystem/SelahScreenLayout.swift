import SwiftUI

enum SelahLayout {
    static let tabBarScrollMargin: CGFloat = 56
    static let flowScrollMargin: CGFloat = 24
}

struct SelahPinnedBottomBar<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background {
                SelahColors.background.opacity(0.96)
                    .ignoresSafeArea(edges: .bottom)
            }
    }
}

struct SelahFlowScreen<Content: View>: View {
    private let content: Content
    private let bottom: AnyView?

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.bottom = nil
    }

    init<B: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottom: () -> B
    ) {
        self.content = content()
        self.bottom = AnyView(bottom())
    }

    var body: some View {
        ZStack {
            SundayLightBackground()
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let bottom {
                bottom
            }
        }
    }
}

extension View {
    func selahTabScrollContent() -> some View {
        contentMargins(.bottom, SelahLayout.tabBarScrollMargin, for: .scrollContent)
    }

    func selahFlowScrollContent() -> some View {
        contentMargins(.bottom, SelahLayout.flowScrollMargin, for: .scrollContent)
    }

    func selahTabContentFrame() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
