import SwiftUI
import UIKit

struct ReadView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var selectedBookId = 19
    @State private var chapter = 23
    @State private var verses: [BibleVerse] = []
    @State private var errorMessage: String?
    @State private var syncedToPlan = false
    @State private var highlighted: Set<Int> = []
    @State private var selectedVerse: BibleVerse?
    @State private var showBookPicker = false
    @State private var markedRead = false

    var body: some View {
        SelahTabScreen {
            VStack(spacing: 0) {
                SelahCompactHeader(title: bookTitle) {
                    Button("Aa") { showBookPicker = true }
                        .font(SelahFont.ui(.body, weight: .bold))
                        .frame(minWidth: 44, minHeight: 44)
                        .accessibilityLabel("Text size")
                        .accessibilityIdentifier("read.textSize")
                } right: {
                    SelahHeaderIconButton(
                        systemName: "bookmark",
                        label: "Bookmark chapter",
                        identifier: "read.bookmark"
                    ) {
                        try? env.saveJournalEntry(plaintext: bookTitle)
                    }
                }
                List {
                if let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay) {
                    Section {
                        LabeledContent("Plan day \(env.planGlobalDay)", value: "\(day.book) \(day.chapter)")
                        Button("Jump to plan") {
                            syncedToPlan = false
                            syncToPlanDayIfNeeded()
                            loadVerses()
                        }
                    }
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red) }
                }
                Section {
                    ForEach(verses) { verse in
                        Button {
                            selectedVerse = verse
                        } label: {
                            Text(attributedVerse(verse))
                                .font(SelahFont.ui(.body))
                                .foregroundStyle(.primary)
                                .strikethrough(false)
                        }
                    }
                } header: {
                    Text(bookTitle)
                } footer: {
                    Text(markedRead ? "Marked as read. Journey updated." : "Finish the chapter to complete today.")
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .bottom) {
                SelahFooterBar {
                    HStack(spacing: 8) {
                        SelahPrimaryButton(
                            title: markedRead ? "Read today" : "Mark as read",
                            style: markedRead ? .secondary : .primary
                        ) {
                            env.markPlanDayComplete(globalDay: env.planGlobalDay)
                            markedRead = true
                            AnalyticsService.track("plan_day_complete")
                        }
                        .disabled(markedRead)
                        Button {
                            env.openTalkReflect(reference: bookTitle)
                        } label: {
                            Image(systemName: "bubble.left")
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("Reflect on this chapter")
                    }
                }
            }
            .sheet(isPresented: $showBookPicker) {
                NavigationStack {
                    bookPicker
                        .navigationTitle("Choose chapter")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { showBookPicker = false }
                            }
                        }
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $selectedVerse) { verse in
                VerseActionSheet(
                    verse: verse,
                    bookTitle: bookTitle,
                    isHighlighted: highlighted.contains(verse.number),
                    onHighlight: {
                        if highlighted.contains(verse.number) { highlighted.remove(verse.number) }
                        else { highlighted.insert(verse.number) }
                    },
                    onReflect: {
                        env.openTalkReflect(reference: "\(bookTitle):\(verse.number)")
                    },
                    onSave: {
                        try? env.saveJournalEntry(plaintext: "\(bookTitle):\(verse.number) \(verse.text)")
                    }
                )
            }
            .onAppear {
                syncToPlanDayIfNeeded()
                loadVerses()
                AnalyticsService.track("read_open")
            }
            .onChange(of: selectedBookId) { _, _ in loadVerses() }
            .onChange(of: chapter) { _, _ in loadVerses() }
            }
        }
    }

    private var bookTitle: String {
        "\(BibleBookCatalog.name(for: selectedBookId)) \(chapter)"
    }

    private var bookPicker: some View {
        Form {
            Picker("Book", selection: $selectedBookId) {
                ForEach(BibleBookCatalog.allBooks, id: \.id) { book in
                    Text(book.name).tag(book.id)
                }
            }
            Stepper("Chapter \(chapter)", value: $chapter, in: 1...150)
        }
    }

    private func attributedVerse(_ verse: BibleVerse) -> String {
        let mark = highlighted.contains(verse.number) ? " ★" : ""
        return "\(verse.number)  \(verse.text)\(mark)"
    }

    private func syncToPlanDayIfNeeded() {
        guard !syncedToPlan else { return }
        guard let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay),
              let bookId = BibleBookCatalog.bookId(for: day.book) else { return }
        selectedBookId = bookId
        chapter = day.chapter
        syncedToPlan = true
    }

    private func loadVerses() {
        do {
            verses = try env.bibleRepository.verses(bookId: selectedBookId, chapter: chapter)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct VerseActionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let verse: BibleVerse
    let bookTitle: String
    let isHighlighted: Bool
    let onHighlight: () -> Void
    let onReflect: () -> Void
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("“\(verse.text)”")
                        .font(SelahFont.verse(.body))
                }
                Section {
                    Button(isHighlighted ? "Remove highlight" : "Highlight", action: { onHighlight(); dismiss() })
                    Button("Reflect on this") { onReflect(); dismiss() }
                    Button("Copy verse") {
                        UIPasteboard.general.string = "\(bookTitle):\(verse.number) \(verse.text)"
                        dismiss()
                    }
                    Button("Save to journal") { onSave(); dismiss() }
                }
            }
            .navigationTitle("\(bookTitle):\(verse.number)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
