import SwiftUI
import UIKit

enum SelahFont {
    // The bundled TTFs register as "Figtree Light" and "Newsreader 16pt" — not bare names.
    private static let uiFamily = "Figtree Light"
    private static let displayFamily = "Newsreader 16pt"

    static func ui(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        if UIFont(name: uiFamily, size: 17) != nil {
            return .custom(uiFamily, size: systemSize(style), relativeTo: style).weight(weight)
        }
        return .system(style, design: .default).weight(weight)
    }

    static func display(_ style: Font.TextStyle = .title) -> Font {
        if UIFont(name: displayFamily, size: 28) != nil {
            return .custom(displayFamily, size: systemSize(style), relativeTo: style)
        }
        return .system(style, design: .serif)
    }

    /// Fixed-size display font (e.g. the big "1 in 5" stat, welcome wordmark).
    static func display(fixedSize size: CGFloat) -> Font {
        if UIFont(name: displayFamily, size: 28) != nil {
            return .custom(displayFamily, size: size)
        }
        return .system(size: size, design: .serif)
    }

    static func verse(_ style: Font.TextStyle = .title3) -> Font {
        display(style).italic()
    }

    private static func systemSize(_ style: Font.TextStyle) -> CGFloat {
        UIFont.preferredFont(forTextStyle: style.uiTextStyle).pointSize
    }
}

private extension Font.TextStyle {
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        @unknown default: .body
        }
    }
}
