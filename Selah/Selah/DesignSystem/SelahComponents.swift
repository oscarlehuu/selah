import SwiftUI

extension SelahColors {
    static let goldHi = Color(hex: 0xEDBE55)
    static let gold = Color(hex: 0xD9A63F)
    static let goldDeep = Color(hex: 0xB98A28)
}

struct SundayLightBackground: View {
    var body: some View {
        LinearGradient(
            colors: [SelahColors.background, SelahColors.backgroundWarm, SelahColors.primarySoft.opacity(0.35)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

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
                if isLoading {
                    ProgressView().tint(.white)
                }
                Text(title)
                    .font(SelahFont.figtree(17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: shadowColor, radius: 8, y: 4)
        }
        .disabled(isLoading)
    }

    private var foreground: Color {
        style == .secondary ? SelahColors.text : .white
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            SelahColors.primaryDeep
        case .gold:
            LinearGradient(colors: [SelahColors.goldHi, SelahColors.gold, SelahColors.goldDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .secondary:
            SelahColors.backgroundWarm
        }
    }

    private var shadowColor: Color {
        style == .gold ? SelahColors.goldDeep.opacity(0.35) : SelahColors.primaryDeep.opacity(0.25)
    }
}

struct SelahCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .background(SelahColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(SelahColors.text.opacity(0.08))
            )
            .shadow(color: SelahColors.text.opacity(0.06), radius: 8, y: 2)
    }
}

struct HeroImageView: View {
    let name: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    SelahColors.primarySoft,
                    SelahColors.backgroundWarm,
                    SelahColors.gold.opacity(0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            if let uiImage = heroUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
            LinearGradient(
                colors: [Color.white.opacity(0.15), SelahColors.background.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .clipped()
    }

    private var heroUIImage: UIImage? {
        if let image = UIImage(named: name) { return image }
        if let image = UIImage(named: "\(name).jpg") { return image }
        if let url = Bundle.main.url(forResource: name, withExtension: "jpg"),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
}
