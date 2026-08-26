import SwiftUI
import UIKit

enum SelahAppearance {
    static let canvasUIColor = UIColor(red: 250 / 255, green: 247 / 255, blue: 242 / 255, alpha: 1)

    @MainActor
    static func apply() {
        UIWindow.appearance().backgroundColor = canvasUIColor
        UITableView.appearance().backgroundColor = canvasUIColor
        UICollectionView.appearance().backgroundColor = canvasUIColor

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = canvasUIColor
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav

        // Mock v4 `.tabbar` — translucent blur `rgba(250,247,242,.78)` + hairline top border.
        let tab = UITabBarAppearance()
        tab.configureWithDefaultBackground()
        tab.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        tab.backgroundColor = canvasUIColor.withAlphaComponent(0.78)
        tab.shadowColor = UIColor(red: 44 / 255, green: 40 / 255, blue: 37 / 255, alpha: 0.08)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }
}

extension View {
    func selahCanvas() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(SelahColors.background)
    }

    func selahRootChrome() -> some View {
        self
            .preferredColorScheme(.light)
            .background(SelahColors.background.ignoresSafeArea())
    }
}

struct SelahComposerBar: View {
    @Binding var text: String
    var isSending: Bool
    var onSend: () -> Void

    var body: some View {
        // Mock v4 `.composer` — pill field + 34pt circular deep-blue send button.
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Say it plainly…", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .font(SelahFont.ui(.body))
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .frame(minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.82))
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(SelahColors.borderStrong, lineWidth: 1)
                )
                .accessibilityIdentifier("talk.composer")
            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(SelahColors.primaryDeep))
            }
            .buttonStyle(.plain)
            .disabled(!canSend || isSending)
            .opacity(!canSend || isSending ? 0.5 : 1)
            .padding(.bottom, 5)
            .accessibilityLabel("Send")
            .accessibilityIdentifier("talk.send")
        }
        .padding(.horizontal, 14)
        .padding(.top, 9)
        .padding(.bottom, 10)
        .background(
            SelahColors.background.opacity(0.9)
                .background(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    SelahColors.border.frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
