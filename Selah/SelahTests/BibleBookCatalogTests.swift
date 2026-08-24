import XCTest
@testable import Selah

final class BibleBookCatalogTests: XCTestCase {
    func testContainsSixtySixBooks() {
        XCTAssertEqual(BibleBookCatalog.allBooks.count, 66)
        XCTAssertEqual(BibleBookCatalog.name(for: 1), "Genesis")
        XCTAssertEqual(BibleBookCatalog.name(for: 19), "Psalms")
        XCTAssertEqual(BibleBookCatalog.name(for: 40), "Matthew")
        XCTAssertEqual(BibleBookCatalog.name(for: 66), "Revelation")
    }

    func testBookIdLookupIsCaseInsensitive() {
        XCTAssertEqual(BibleBookCatalog.bookId(for: "psalms"), 19)
        XCTAssertEqual(BibleBookCatalog.bookId(for: "Psalm"), 19)
        XCTAssertEqual(BibleBookCatalog.bookId(for: "1 John"), 62)
        XCTAssertNil(BibleBookCatalog.bookId(for: "NotABook"))
    }

    func testUnknownBookIdHasSafeLabel() {
        XCTAssertEqual(BibleBookCatalog.name(for: 0), "Book 0")
        XCTAssertEqual(BibleBookCatalog.name(for: 99), "Book 99")
    }
}
