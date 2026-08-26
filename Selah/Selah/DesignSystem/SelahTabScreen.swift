import SwiftUI

/// Mock v4 `.navbar` — blurred bar, centered display-font title, 44pt side slots.
/// Replaces the native large-title navigation chrome the mock does not have.
struct SelahNavBar<Leading: View, Trailing: View>: View {
    let title: String
    @ViewBuilder var leading: Leading
    @ViewBuilder var trailing: Trailing

    init(
        _ title: String,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 2) { leading }
                .frame(minWidth: 44, alignment: .leading)
            Text(title)
                .font(SelahFont.display(.body))
                .fontWeight(.semibold)
                .foregroundStyle(SelahColors.text)
                .frame(maxWidth: .infinity)
            HStack(spacing: 2) { trailing }
                .frame(minWidth: 44, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(minHeight: 48)
        .background(
            SelahColors.background.opacity(0.82)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
        )
    }
}

/// Mock v4 `.icon-btn` — 40pt round icon button in the navbar.
struct SelahIconButton: View {
    let systemImage: String
    var label: String
    var identifier: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(SelahColors.text)
                .frame(width: 40, height: 40)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier ?? "")
    }
}

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
                .navigationBarHidden(true)
                .safeAreaInset(edge: .top, spacing: 0) {
                    SelahNavBar(title)
                }
        }
        .background(SelahColors.background.ignoresSafeArea())
    }
}
