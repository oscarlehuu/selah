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

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = canvasUIColor
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
        SelahFooterBar {
            HStack(alignment: .bottom, spacing: 10) {
                TextField("Say it plainly…", text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .font(SelahFont.ui(.body))
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("talk.composer")
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                }
                .disabled(!canSend || isSending)
                .accessibilityLabel("Send")
                .accessibilityIdentifier("talk.send")
            }
        }
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
