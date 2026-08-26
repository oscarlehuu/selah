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
        // Mock v4 `.btn` — 52pt min height, 16pt radius, custom fills (not borderedProminent).
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading { ProgressView().tint(.white) }
                Text(title)
                    .font(SelahFont.ui(.body, weight: .semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(foreground)
            .background(backgroundFill)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(style == .secondary ? SelahColors.borderStrong : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .shadow(
            color: shadowColor,
            radius: style == .gold ? 14 : (style == .primary ? 10 : 0),
            y: style == .gold ? 6 : (style == .primary ? 4 : 0)
        )
    }

    @ViewBuilder
    private var backgroundFill: some View {
        switch style {
        // `.btn-gold` — linear-gradient(160deg, gold-hi, gold 46%, gold-deep).
        case .gold: SelahColors.goldGradient
        case .primary: SelahColors.primaryDeep
        case .secondary: SelahColors.surface
        }
    }

    private var foreground: Color {
        style == .secondary ? SelahColors.text : .white
    }

    private var shadowColor: Color {
        switch style {
        case .gold: Color(hex: 0xB98A28).opacity(0.34)
        case .primary: Color(hex: 0x3D6FD4).opacity(0.28)
        case .secondary: .clear
        }
    }
}

/// Mock v4 `.card` — white surface, hairline border, 16pt radius, soft shadow.
struct SelahCardModifier: ViewModifier {
    var padding: CGFloat = 15
    var radius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SelahColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(SelahColors.border, lineWidth: 1)
            )
            .shadow(color: Color(hex: 0x2C2825).opacity(0.06), radius: 4, y: 2)
    }
}

extension View {
    func selahCard(padding: CGFloat = 15, radius: CGFloat = 16) -> some View {
        modifier(SelahCardModifier(padding: padding, radius: radius))
    }
}

/// Mock v4 `.chip` / `.chip-gold` / `.chip-blue`.
struct SelahChip: View {
    enum Style { case neutral, gold, blue }

    let text: String
    var systemImage: String?
    var style: Style = .neutral

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage).font(.system(size: 12, weight: .semibold))
            }
            Text(text).font(SelahFont.ui(.footnote, weight: .semibold))
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 32)
        .foregroundStyle(foreground)
        .background(Capsule().fill(background))
        .overlay(Capsule().stroke(border, lineWidth: 1))
    }

    private var foreground: Color {
        switch style {
        case .neutral: SelahColors.textMuted
        case .gold: SelahColors.accentDeep
        case .blue: SelahColors.primaryDeep
        }
    }

    private var background: Color {
        switch style {
        case .neutral: SelahColors.surface
        case .gold: SelahColors.accentSoft
        case .blue: SelahColors.primarySoft
        }
    }

    private var border: Color {
        switch style {
        case .neutral: SelahColors.border
        case .gold: SelahColors.accent.opacity(0.28)
        case .blue: SelahColors.primary.opacity(0.22)
        }
    }
}

/// Mock v4 `.section-head` — display-font heading with optional trailing link.
struct SelahSectionHead: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(SelahFont.display(.headline))
                .foregroundStyle(SelahColors.text)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(SelahFont.ui(.footnote, weight: .semibold))
                    .foregroundStyle(SelahColors.primaryDeep)
            }
        }
        .padding(.top, 26)
        .padding(.bottom, 11)
    }
}

/// Mock v4 `.pw-bullets li` / row icon tile — rounded square icon chip.
struct SelahIconTile: View {
    let systemImage: String
    var size: CGFloat = 34
    var radius: CGFloat = 10
    var style: SelahChip.Style = .gold

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.44, weight: .semibold))
            .foregroundStyle(style == .blue ? SelahColors.primaryDeep : SelahColors.accentDeep)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(style == .blue ? SelahColors.primarySoft : SelahColors.accentSoft)
            )
    }
}

struct SelahFooterBar<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 10) {
            content
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        // Mock v4 `.ob-foot` — transparent over canvas with a soft upward fade.
        .background(
            LinearGradient(
                colors: [SelahColors.background.opacity(0), SelahColors.background.opacity(0.62), SelahColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
        )
    }
}

struct FootVerseCaption: View {
    let text: String
    let ref: String

    var body: some View {
        // Mock v4 `.foot-verse` — italic serif line, ref in small bold gold caps.
        VStack(spacing: 2) {
            Text("“\(text)”")
                .font(SelahFont.verse(.footnote))
                .foregroundStyle(SelahColors.textMuted)
                .multilineTextAlignment(.center)
            Text(ref)
                .font(SelahFont.ui(.caption2, weight: .bold))
                .textCase(.uppercase)
                .kerning(0.6)
                .foregroundStyle(SelahColors.accentDeep)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

/// Chat bubbles for the Talk screen — user (right, deep blue) vs Selah (left, white card),
/// matching the mock v4 `.msg.me` / `.msg.ai` styles.
struct TalkBubble: View {
    let text: String
    let isUser: Bool

    var body: some View {
        Text(text)
            .font(SelahFont.ui(.body))
            .foregroundStyle(isUser ? Color.white : SelahColors.text)
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .frame(maxWidth: 310, alignment: .leading)
            .background(bubbleShape.fill(bubbleColor))
            .overlay(bubbleShape.stroke(borderColor, lineWidth: isUser ? 0 : 1))
            .shadow(color: .black.opacity(isUser ? 0 : 0.05), radius: 6, y: 1)
    }

    // Mock v4 `.msg` — asymmetric corners: tail corner tightened to 6pt.
    private var bubbleShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 19,
            bottomLeadingRadius: isUser ? 19 : 6,
            bottomTrailingRadius: isUser ? 6 : 19,
            topTrailingRadius: 19,
            style: .continuous
        )
    }

    private var bubbleColor: Color {
        isUser ? SelahColors.primaryDeep : SelahColors.surface
    }

    private var borderColor: Color {
        isUser ? .clear : Color(hex: 0xE8E2D8)
    }
}
