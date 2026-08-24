import Foundation

enum BibleBookCatalog {
    private static let orderedNames: [String] = [
        "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
        "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
        "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra",
        "Nehemiah", "Esther", "Job", "Psalms", "Proverbs",
        "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations",
        "Ezekiel", "Daniel", "Hosea", "Joel", "Amos",
        "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
        "Zephaniah", "Haggai", "Zechariah", "Malachi",
        "Matthew", "Mark", "Luke", "John", "Acts",
        "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians",
        "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy",
        "2 Timothy", "Titus", "Philemon", "Hebrews", "James",
        "1 Peter", "2 Peter", "1 John", "2 John", "3 John",
        "Jude", "Revelation"
    ]

    static var allBooks: [(id: Int, name: String)] {
        orderedNames.enumerated().map { ($0.offset + 1, $0.element) }
    }

    static func name(for bookId: Int) -> String {
        guard bookId >= 1, bookId <= orderedNames.count else { return "Book \(bookId)" }
        return orderedNames[bookId - 1]
    }

    static func bookId(for name: String) -> Int? {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let aliases = ["psalm": "psalms", "song of songs": "song of solomon"]
        let lookup = aliases[normalized] ?? normalized
        for (index, book) in orderedNames.enumerated() where book.lowercased() == lookup {
            return index + 1
        }
        return nil
    }
}

struct BibleVerse: Identifiable, Equatable {
    let bookId: Int
    let chapter: Int
    let number: Int
    let text: String

    var id: String { "\(bookId)-\(chapter)-\(number)" }
    var reference: String { "\(BibleBookCatalog.name(for: bookId)) \(chapter):\(number)" }
}
