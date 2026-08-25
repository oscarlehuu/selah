import SwiftUI
import UIKit

enum SelahFont {
    static func ui(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        if UIFont(name: "Figtree", size: 17) != nil {
            return .custom("Figtree", size: systemSize(style), relativeTo: style).weight(weight)
        }
        return .system(style, design: .default).weight(weight)
    }

    static func display(_ style: Font.TextStyle = .title) -> Font {
        if UIFont(name: "Newsreader", size: 28) != nil {
            return .custom("Newsreader", size: systemSize(style), relativeTo: style)
        }
        return .system(style, design: .serif)
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
