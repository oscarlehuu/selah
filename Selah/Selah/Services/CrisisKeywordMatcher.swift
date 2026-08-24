import Foundation

final class CrisisKeywordMatcher {
    private let keywords: [String]

    init(keywords: [String]? = nil) {
        if let keywords {
            self.keywords = keywords.map { $0.lowercased() }
            return
        }
        if let url = Bundle.main.url(forResource: "crisis-keywords-en", withExtension: "txt", subdirectory: "Data")
            ?? Bundle.main.url(forResource: "crisis-keywords-en", withExtension: "txt")
            ?? Bundle.main.url(forResource: "crisis-keywords-en", withExtension: "txt", subdirectory: "Data"),
           let text = try? String(contentsOf: url, encoding: .utf8) {
            self.keywords = text
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                .filter { !$0.isEmpty }
        } else {
            self.keywords = ["suicide", "kill myself", "end my life", "self-harm"]
        }
    }

    func containsCrisisLanguage(_ text: String) -> Bool {
        let lower = text.lowercased()
        return keywords.contains { lower.contains($0) }
    }
}
