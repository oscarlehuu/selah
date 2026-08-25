import SwiftUI

enum TalkMode: String, CaseIterable, Identifiable, Hashable {
    case heart, reflect, release

    var id: String { rawValue }

    var title: String {
        switch self {
        case .heart: "Heart"
        case .reflect: "Reflect"
        case .release: "Release"
        }
    }

    var systemPrompt: String {
        switch self {
        case .heart: "Heart · say anything. Nothing leaves this phone."
        case .reflect: "Reflect · sit with Scripture and let it read you."
        case .release: "Release · bring it to God and set it down. Not a confessional. A place to be honest."
        }
    }

    var openingLine: String {
        switch self {
        case .heart: "I’m here. What’s sitting on you tonight?"
        case .reflect: "Let’s stay with one verse. What line has been following you around this week?"
        case .release: "You can say it plainly here. What do you want to put down?"
        }
    }

    var suggestions: [String] {
        switch self {
        case .heart: ["I’m exhausted", "I feel far from God", "Something good happened"]
        case .reflect: ["Psalm 46:10", "What does “be still” mean?", "Help me slow down"]
        case .release: ["I keep doing the same thing", "I’m angry", "I need to forgive someone"]
        }
    }

    var promptHint: String {
        switch self {
        case .heart: "Respond warmly to what the user shared from the heart."
        case .reflect: "Help the user reflect on Scripture and God's presence."
        case .release: "Respond with grace as the user releases guilt or heaviness."
        }
    }
}
