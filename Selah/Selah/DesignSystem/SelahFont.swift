import SwiftUI

enum SelahFont {
    static func figtree(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Figtree", size: size).weight(weight)
    }

    static func newsreader(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Newsreader", size: size).weight(weight)
    }

    static func verse(_ size: CGFloat = 20) -> Font {
        newsreader(size, weight: .medium).italic()
    }
}
