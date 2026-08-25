import Foundation

enum SelahSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let navbarInline: CGFloat = 16
    static let navbarBottom: CGFloat = 8
    static let navbarMinHeight: CGFloat = 48
    static let pad: CGFloat = 22
    static let lectio: CGFloat = 26
    static let chatHorizontal: CGFloat = 18
    static let chatTop: CGFloat = 6
    static let chatBottom: CGFloat = 12
}

enum SelahNavSlot: Equatable {
    case empty
    case privacy
    case clearSession
    case closeToToday
    case fiveMin
    case settings
    case textSize
    case bookmark
}

struct SelahTabChrome: Equatable {
    var hidesNavbar: Bool
    var left: SelahNavSlot
    var right: SelahNavSlot
    var showsSettings: Bool

    static let today = SelahTabChrome(hidesNavbar: true, left: .empty, right: .settings, showsSettings: true)
    static let talk = SelahTabChrome(hidesNavbar: false, left: .privacy, right: .clearSession, showsSettings: false)
    static let pray = SelahTabChrome(hidesNavbar: false, left: .closeToToday, right: .fiveMin, showsSettings: false)
    static let journey = SelahTabChrome(hidesNavbar: false, left: .empty, right: .settings, showsSettings: true)
    static let read = SelahTabChrome(hidesNavbar: false, left: .textSize, right: .bookmark, showsSettings: false)
}
