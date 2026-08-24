import SwiftUI

struct DemoModeBanner: View {
    var body: some View {
        Text("Demo · screenshots")
            .font(SelahFont.figtree(11, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(SelahColors.accentSoft)
            .foregroundStyle(SelahColors.accentDeep)
            .clipShape(Capsule())
    }
}

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
            ZStack {
                SundayLightBackground()
                content
                    .selahTabContentFrame()
            }
            .navigationTitle(env.isDemoMode ? "" : title)
            .navigationBarTitleDisplayMode(env.isDemoMode ? .inline : .large)
            .toolbar {
                if env.isDemoMode {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 4) {
                            DemoModeBanner()
                            Text(title)
                                .font(SelahFont.newsreader(20, weight: .semibold))
                                .foregroundStyle(SelahColors.text)
                        }
                    }
                }
            }
            .toolbarBackground(SelahColors.background.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct SelahComposerBar: View {
    @Binding var text: String
    var isSending: Bool
    var onSend: () -> Void

    var body: some View {
        SelahPinnedBottomBar {
            HStack(alignment: .bottom, spacing: 10) {
                TextField("Share what's on your heart…", text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .font(SelahFont.figtree(16))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(SelahColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(SelahColors.text.opacity(0.1))
                    )

                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(canSend ? SelahColors.primaryDeep : SelahColors.textSoft)
                }
                .disabled(!canSend || isSending)
            }
        }
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
