import SwiftUI

struct SelahPrimaryButton: View {
    let title: String
    var style: Style = .primary
    var isLoading: Bool = false
    private let action: () -> Void

    init(title: String, style: Style = .primary, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    enum Style { case primary, gold, secondary }

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading { ProgressView() }
                Text(title)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .controlSize(.large)
        .tint(tint)
        .disabled(isLoading)
    }

    private var tint: Color {
        switch style {
        case .primary: SelahColors.primaryDeep
        case .gold: SelahColors.accent
        case .secondary: SelahColors.textMuted
        }
    }
}

struct SelahFooterBar<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 10) {
            content
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(.bar)
    }
}

struct FootVerseCaption: View {
    let text: String
    let ref: String

    var body: some View {
        VStack(spacing: 4) {
            Text("“\(text)”")
                .font(SelahFont.verse(.footnote))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text(ref)
                .font(SelahFont.ui(.caption2, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
