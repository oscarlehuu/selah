import SwiftUI

/// Full-bleed photographic heroes from mock v4 — Sunday Light, not wireframe lists.
/// `.photoWindow` mirrors `.hero.photo-window`, `.sky` mirrors `.hero.sky.hero-glow`.
struct OnboardingHero<Content: View>: View {
    enum Style {
        case photoWindow
        case photoMorning
        case sky
    }

    let style: Style
    /// `nil` lets the hero expand to fill available space (welcome screen).
    var height: CGFloat?
    /// When true the backdrop fills all available height regardless of content size.
    var fillsAvailable: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .bottom) {
            backdrop
            content()
                .zIndex(2)
            // Bottom veil so overlaid copy stays readable (`.hero::before`) —
            // taller, eased fade so the hero melts into the canvas (no hard edge).
            LinearGradient(
                stops: [
                    .init(color: SelahColors.background.opacity(0), location: 0),
                    .init(color: SelahColors.background.opacity(0.45), location: 0.55),
                    .init(color: SelahColors.background, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .allowsHitTesting(false)
            .zIndex(1)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity, maxHeight: fillsAvailable ? .infinity : nil)
        .clipped()
    }

    @ViewBuilder
    private var backdrop: some View {
        switch style {
        case .photoWindow:
            photo("selah-hero-window")
        case .photoMorning:
            photo("selah-hero-morning")
        case .sky:
            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0xBFD9F5), Color(hex: 0xEAF3FC), Color(hex: 0xFBF0DA)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                glow
            }
        }
    }

    @ViewBuilder
    private func photo(_ name: String) -> some View {
        if let image = Self.loadBundledImage(name, "jpg") {
            GeometryReader { proxy in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
        } else {
            windowFallback
        }
    }

    private var glow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color(hex: 0xFFECBE).opacity(0.95), Color(hex: 0xFFE09B).opacity(0.5), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 170
                )
            )
            .frame(width: 340, height: 340)
            .offset(y: 90)
            .blur(radius: 4)
    }

    /// The heroes ship as loose bundle files (not asset-catalog entries), so load by URL.
    static func loadBundledImage(_ name: String, _ ext: String) -> UIImage? {
        if let url = Bundle.main.url(forResource: name, withExtension: ext),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image
        }
        return UIImage(named: name)
    }

    /// Soft sky placeholder if the bundled photo is missing from the bundle.
    private var windowFallback: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xF7E9C8), Color(hex: 0xFBF4E6)],
                startPoint: .top,
                endPoint: .bottom
            )
            Image(systemName: "sunrise.fill")
                .font(.system(size: 64))
                .foregroundStyle(SelahColors.accent.opacity(0.55))
        }
    }
}

/// Glowing sunrise medallion from mock v4 screen 01 (white disc + halo rings).
struct HeroMedallion: View {
    var systemImage: String = "sunrise.fill"

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 36, weight: .medium))
            .foregroundStyle(SelahColors.accentDeep)
            .frame(width: 76, height: 76)
            .background(Circle().fill(Color.white.opacity(0.55)))
            .overlay(Circle().stroke(Color.white.opacity(0.24), lineWidth: 12))
            .shadow(color: Color(hex: 0x7A5610).opacity(0.14), radius: 13, y: 8)
    }
}

/// Verse pinned near the bottom of a hero (`.hero-verse`).
struct HeroVerse: View {
    let text: String
    let ref: String

    var body: some View {
        VStack(spacing: 7) {
            Text("“\(text)”")
                .font(SelahFont.verse(.callout))
                .foregroundStyle(Color(hex: 0x4A3D28))
                .multilineTextAlignment(.center)
            Text(ref)
                .font(SelahFont.ui(.caption2, weight: .semibold))
                .textCase(.uppercase)
                .kerning(0.8)
                .foregroundStyle(Color(hex: 0x4A3D28).opacity(0.72))
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
