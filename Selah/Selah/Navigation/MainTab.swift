import Foundation

enum MainTab: String, Hashable, CaseIterable {
    case today, read, talk, pray, journey

    var title: String {
        switch self {
        case .today: "Today"
        case .read: "Read"
        case .talk: "Talk"
        case .pray: "Pray"
        case .journey: "Journey"
        }
    }

    var symbol: String {
        switch self {
        case .today: "sun.max.fill"
        case .read: "book.fill"
        case .talk: "bubble.left.and.bubble.right.fill"
        case .pray: "hands.sparkles.fill"
        case .journey: "figure.walk"
        }
    }

    var isPrayOrTalk: Bool { self == .pray || self == .talk }
}
