import SwiftUI

enum SelahColors {
    static let primary = Color(hex: 0x5B8DEF)
    static let primaryDeep = Color(hex: 0x3D6FD4)
    static let primarySoft = Color(hex: 0xEAF1FD)
    static let accent = Color(hex: 0xC49A3C)
    static let accentDeep = Color(hex: 0xA67C2E)
    static let accentSoft = Color(hex: 0xFBF5E6)
    static let background = Color(hex: 0xFAF7F2)
    static let backgroundWarm = Color(hex: 0xF5EDE3)
    static let surface = Color.white
    static let text = Color(hex: 0x2C2825)
    static let textMuted = Color(hex: 0x6B6560)
    static let textSoft = Color(hex: 0x9A938C)
    // Mock v4 gold gradient stops (`--gold-hi / --gold / --gold-deep`).
    static let goldHi = Color(hex: 0xEDBE55)
    static let gold = Color(hex: 0xD9A63F)
    static let goldDeep = Color(hex: 0xB98A28)
    // `--border` / `--border-strong`
    static let border = Color(hex: 0x2C2825, alpha: 0.08)
    static let borderStrong = Color(hex: 0x2C2825, alpha: 0.14)

    static let goldGradient = LinearGradient(
        colors: [goldHi, gold, goldDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
