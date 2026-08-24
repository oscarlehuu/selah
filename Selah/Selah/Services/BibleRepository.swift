import Foundation
import GRDB

enum BibleRepositoryError: Error {
    case missingDatabase
}

final class BibleRepository {
    private let dbQueue: DatabaseQueue

    init() throws {
        guard let url = Bundle.main.url(forResource: "kjv", withExtension: "sqlite", subdirectory: "Data")
            ?? Bundle.main.url(forResource: "kjv", withExtension: "sqlite") else {
            throw BibleRepositoryError.missingDatabase
        }
        dbQueue = try DatabaseQueue(path: url.path)
    }

    func verses(bookId: Int, chapter: Int) throws -> [BibleVerse] {
        try dbQueue.read { db in
            let rows = try Row.fetchAll(
                db,
                sql: "SELECT book_id, chapter, number, text FROM verses WHERE book_id = ? AND chapter = ? ORDER BY number",
                arguments: [bookId, chapter]
            )
            return rows.map { row in
                BibleVerse(
                    bookId: row["book_id"],
                    chapter: row["chapter"],
                    number: row["number"],
                    text: row["text"]
                )
            }
        }
    }

    func verseText(bookName: String, chapter: Int, verse: Int) throws -> String? {
        guard let bookId = BibleBookCatalog.bookId(for: bookName) else { return nil }
        return try dbQueue.read { db in
            try String.fetchOne(
                db,
                sql: "SELECT text FROM verses WHERE book_id = ? AND chapter = ? AND number = ?",
                arguments: [bookId, chapter, verse]
            )
        }
    }
}
