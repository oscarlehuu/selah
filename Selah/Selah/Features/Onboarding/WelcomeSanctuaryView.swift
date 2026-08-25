import SwiftUI

struct WelcomeSanctuaryView: View {
    var onBegin: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var markGlow = false

    private let ink = Color(hex: 0x4A3D28)

    var body: some View {
        ZStack {
            sanctuaryBackground
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                mark
                    .padding(.bottom, 14)
                Text(OnboardingCopy.welcomeTitle)
                    .font(SelahFont.display(.largeTitle))
                    .foregroundStyle(ink)
                    .accessibilityAddTraits(.isHeader)
                Text(OnboardingCopy.welcomeSubtitle)
                    .font(SelahFont.ui(.caption, weight: .semibold))
                    .tracking(2.6)
                    .textCase(.uppercase)
                    .foregroundStyle(ink.opacity(0.72))
                    .padding(.top, 10)
                    .accessibilityLabel(OnboardingCopy.welcomeSubtitle)
                Spacer(minLength: 16)
                verseBlock
                    .padding(.bottom, 18)
                Text(OnboardingCopy.welcomeMeaning)
                    .font(SelahFont.ui(.subheadline))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ink.opacity(0.86))
                    .padding(.horizontal, 8)
                Spacer(minLength: 20)
                SelahPrimaryButton(title: OnboardingCopy.welcomeCTA, style: .gold, action: onBegin)
                    .accessibilityIdentifier("onboarding.continue")
                Text(OnboardingCopy.welcomeDurationHint)
                    .font(SelahFont.ui(.caption))
                    .foregroundStyle(ink.opacity(0.62))
                    .padding(.top, 10)
            }
            .padding(.horizontal, 26)
            .safeAreaPadding(.top, 8)
            .safeAreaPadding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("onboarding.welcome.sanctuary")
        .onAppear { breathe() }
    }

    private var sanctuaryBackground: some View {
        ZStack {
            sundayLightFallback
            if let photo = SelahHero.windowImage {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
            }
            LinearGradient(
                colors: [
                    Color(hex: 0xDEEAFC).opacity(0.30),
                    Color(hex: 0xFAF7F2).opacity(0.04),
                    Color(hex: 0xFAF7F2).opacity(0.28)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .allowsHitTesting(false)
    }

    private var sundayLightFallback: some View {
        LinearGradient(
            colors: [
                SelahColors.primarySoft,
                SelahColors.background,
                SelahColors.backgroundWarm
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var mark: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 128, height: 128)
                .scaleEffect(markGlow ? 1.06 : 0.94)
            Circle()
                .fill(Color.white.opacity(0.24))
                .frame(width: 100, height: 100)
            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 76, height: 76)
                .shadow(color: SelahColors.accent.opacity(0.22), radius: 16, y: 8)
            Image(systemName: "sunrise.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(SelahColors.accentDeep)
        }
        .accessibilityIdentifier("onboarding.welcome.mark")
        .accessibilityHidden(true)
    }

    private var verseBlock: some View {
        VStack(spacing: 8) {
            Text("“\(OnboardingCopy.welcomeVerse)”")
                .font(SelahFont.verse(.title3))
                .multilineTextAlignment(.center)
                .foregroundStyle(ink)
            Text(OnboardingCopy.welcomeVerseRef)
                .font(SelahFont.ui(.caption2, weight: .semibold))
                .tracking(1.1)
                .textCase(.uppercase)
                .foregroundStyle(ink.opacity(0.72))
        }
        .accessibilityIdentifier("onboarding.welcome.verse")
        .accessibilityElement(children: .combine)
    }

    private func breathe() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
            markGlow = true
        }
    }
}
