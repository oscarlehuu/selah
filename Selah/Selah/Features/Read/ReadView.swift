import SwiftUI
import UIKit

struct ReadView: View {
    @Environment(AppEnvironment.self) private var env
    @AppStorage("read.fontScale") private var fontScale = 1.0
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
        NavigationStack {
            ScrollView {
                readerContent
            }
            .scrollIndicators(.hidden)
            .background(SelahColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .safeAreaInset(edge: .top, spacing: 0) { navbar }
            .safeAreaInset(edge: .bottom) { footer }
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

    // MARK: - Navbar

    private var navbar: some View {
        HStack(spacing: 6) {
            HStack(spacing: 2) {
                Button {
                    fontScale = fontScale >= 1.3 ? 1.0 : fontScale + 0.15
                } label: {
                    Text("Aa")
                        .font(SelahFont.ui(.subheadline, weight: .bold))
                        .foregroundStyle(SelahColors.text)
                        .frame(width: 40, height: 40)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Text size")
            }
            .frame(minWidth: 44, alignment: .leading)

            Button {
                showBookPicker = true
            } label: {
                HStack(spacing: 5) {
                    Text(bookTitle)
                        .font(SelahFont.display(.body))
                        .fontWeight(.semibold)
                        .foregroundStyle(SelahColors.text)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(SelahColors.text)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choose chapter")

            HStack(spacing: 2) {
                SelahIconButton(systemImage: "bookmark", label: "Bookmark chapter") {}
            }
            .frame(minWidth: 44, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(minHeight: 48)
        .background(
            SelahColors.background.opacity(0.82)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Reader

    private var readerContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay) {
                Button {
                    syncedToPlan = false
                    syncToPlanDayIfNeeded()
                    loadVerses()
                } label: {
                    SelahChip(
                        text: "Day \(env.planGlobalDay) · \(day.book) \(day.chapter)",
                        systemImage: "calendar",
                        style: .blue
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 18)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(SelahFont.ui(.footnote))
                    .foregroundStyle(.red)
                    .padding(.bottom, 14)
            }

            Text(bookTitle)
                .font(SelahFont.display(.title2))
                .fontWeight(.semibold)
                .foregroundStyle(SelahColors.text)
                .padding(.bottom, 14)

            versesList

            Rectangle()
                .fill(SelahColors.border)
                .frame(height: 1)
                .padding(.top, 22)
                .padding(.bottom, 16)

            Text(markedRead ? "Marked as read. Journey updated." : "Finish the chapter to complete today.")
                .font(SelahFont.ui(.footnote))
                .foregroundStyle(SelahColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 6)
        .padding(.bottom, 24)
    }

    private var versesList: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(verses) { verse in
                VerseRow(
                    verse: verse,
                    isHighlighted: highlighted.contains(verse.number),
                    isSelected: selectedVerse?.id == verse.id,
                    fontScale: fontScale
                ) {
                    selectedVerse = verse
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        SelahFooterBar {
            HStack(spacing: 10) {
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
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(SelahColors.text)
                        .frame(width: 52, height: 52)
                        .background(SelahColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(SelahColors.borderStrong, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Reflect on this chapter")
            }
        }
    }

    // MARK: - Helpers

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

/// Mock v4 `.vs` — flowing verse block with superscript number, gold underline
/// highlight (`data-hl`) and blue selected background.
private struct VerseRow: View {
    let verse: BibleVerse
    let isHighlighted: Bool
    let isSelected: Bool
    let fontScale: Double
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            verseText
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 5)
                .padding(.horizontal, 4)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var verseText: some View {
        Text(numberText + bodyText)
            .lineSpacing(17 * fontScale * 0.7)
            .foregroundStyle(SelahColors.text)
    }

    private var numberText: AttributedString {
        var number = AttributedString("\(verse.number) ")
        number.font = .system(size: 10 * fontScale, weight: .bold)
        number.foregroundColor = SelahColors.primary
        number.baselineOffset = 6
        return number
    }

    private var bodyText: AttributedString {
        var body = AttributedString(verse.text)
        body.font = .system(size: 17 * fontScale)
        return body
    }

    @ViewBuilder
    private var background: some View {
        if isSelected {
            SelahColors.primarySoft
        } else if isHighlighted {
            VStack(spacing: 0) {
                Color.clear
                SelahColors.accent.opacity(0.32)
            }
        } else {
            Color.clear
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
