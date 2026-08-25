import Foundation

struct CompanionTurn: Equatable, Sendable {
    enum Source: String, Equatable, Sendable {
        case onDevice
        case unavailable
        case failed
    }

    var source: Source
    var reply: String
    var scriptureReference: String?
    var scriptureText: String?
    var followUps: [String]

    static func unavailable(_ message: String) -> CompanionTurn {
        CompanionTurn(source: .unavailable, reply: message, scriptureReference: nil, scriptureText: nil, followUps: [])
    }

    static func failed(_ message: String) -> CompanionTurn {
        CompanionTurn(source: .failed, reply: message, scriptureReference: nil, scriptureText: nil, followUps: [])
    }

    var persistedText: String {
        if let scriptureReference, let scriptureText {
            return "\(reply)\n\n\(scriptureReference) — \(scriptureText)"
        }
        if let scriptureReference {
            return "\(reply)\n\n\(scriptureReference)"
        }
        return reply
    }
}

struct TalkLine: Equatable, Sendable, Identifiable {
    enum Role: String, Equatable, Sendable {
        case sys, user, assistant
    }

    var id = UUID()
    var role: Role
    var text: String
    var scriptureReference: String?
    var scriptureText: String?

    var persistedText: String {
        if let scriptureReference, let scriptureText {
            return "\(text)\n\n\(scriptureReference) — \(scriptureText)"
        }
        if let scriptureReference {
            return "\(text)\n\n\(scriptureReference)"
        }
        return text
    }
}

struct PrayerDraftContext: Equatable, Sendable {
    var reflectionWord: String
    var verse: String
    var mood: String?

    var summary: String {
        var bits: [String] = []
        let verseText = verse.trimmingCharacters(in: .whitespacesAndNewlines)
        let word = reflectionWord.trimmingCharacters(in: .whitespacesAndNewlines)
        if !verseText.isEmpty { bits.append("verse: \(verseText)") }
        if !word.isEmpty { bits.append("word that stood out: \(word)") }
        if let mood, !mood.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bits.append("mood: \(mood)")
        }
        return bits.isEmpty ? "a quiet Lectio moment with no extra words yet" : bits.joined(separator: "; ")
    }
}

enum CompanionTurnParser {
    private static let keys = ["REPLY", "SCRIPTURE_TEXT", "SCRIPTURE", "FOLLOWUPS", "PRAYER"]

    static func parseTalk(_ raw: String, source: CompanionTurn.Source) -> CompanionTurn {
        let fields = labeledFields(in: raw)
        let reply = fields["REPLY"] ?? strippingLabels(from: raw)
        let followUps = fields["FOLLOWUPS"]?
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []
        return CompanionTurn(
            source: source,
            reply: reply.trimmingCharacters(in: .whitespacesAndNewlines),
            scriptureReference: emptyToNil(fields["SCRIPTURE"]),
            scriptureText: emptyToNil(fields["SCRIPTURE_TEXT"]),
            followUps: followUps
        )
    }

    static func parsePrayer(_ raw: String, source: CompanionTurn.Source) -> CompanionTurn {
        let fields = labeledFields(in: raw)
        let reply = fields["PRAYER"] ?? strippingLabels(from: raw)
        return CompanionTurn(
            source: source,
            reply: reply.trimmingCharacters(in: .whitespacesAndNewlines),
            scriptureReference: emptyToNil(fields["SCRIPTURE"]),
            scriptureText: emptyToNil(fields["SCRIPTURE_TEXT"]),
            followUps: []
        )
    }

    private static func labeledFields(in raw: String) -> [String: String] {
        var result: [String: String] = [:]
        var current: String?
        var buffer: [String] = []

        func flush() {
            guard let current else { return }
            result[current] = buffer.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            buffer = []
        }

        for line in raw.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if let key = keys.first(where: { trimmed.uppercased().hasPrefix($0 + ":") }) {
                flush()
                current = key
                let rest = String(trimmed.dropFirst(key.count + 1)).trimmingCharacters(in: .whitespaces)
                buffer = rest.isEmpty ? [] : [rest]
            } else if current != nil {
                buffer.append(line)
            }
        }
        flush()
        return result
    }

    private static func strippingLabels(from raw: String) -> String {
        raw.components(separatedBy: .newlines)
            .filter { line in
                let upper = line.trimmingCharacters(in: .whitespaces).uppercased()
                return keys.contains { upper.hasPrefix($0 + ":") } == false
            }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func emptyToNil(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }
}
