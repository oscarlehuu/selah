import Foundation

struct VerseOfTheDayEntry: Decodable {
    let book: String
    let chapter: Int
    let verse: Int
}

struct VerseOfTheDayFile: Decodable {
    let anchorDate: String
    let verses: [VerseOfTheDayEntry]
}

struct VerseOfTheDay: Equatable {
    let reference: String
    let text: String
}

final class VerseOfTheDayService {
    private let entries: [VerseOfTheDayEntry]
    private let bible: BibleRepository

    init(bible: BibleRepository) throws {
        self.bible = bible
        guard let url = Bundle.main.url(forResource: "verse-of-the-day", withExtension: "json", subdirectory: "Data")
            ?? Bundle.main.url(forResource: "verse-of-the-day", withExtension: "json") else {
            entries = []
            return
        }
        let file = try JSONDecoder().decode(VerseOfTheDayFile.self, from: Data(contentsOf: url))
        entries = file.verses
    }

    func verse(for date: Date = .now, calendar: Calendar = .current) throws -> VerseOfTheDay? {
        guard !entries.isEmpty else { return nil }
        let anchor = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? date
        let dayOffset = calendar.dateComponents([.day], from: anchor, to: date).day ?? 0
        let index = ((dayOffset % entries.count) + entries.count) % entries.count
        let entry = entries[index]
        guard let text = try bible.verseText(bookName: entry.book, chapter: entry.chapter, verse: entry.verse) else {
            return nil
        }
        return VerseOfTheDay(reference: "\(entry.book) \(entry.chapter):\(entry.verse)", text: text)
    }
}
