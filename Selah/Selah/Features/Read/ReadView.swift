import SwiftUI

struct ReadView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var selectedBookId = 19
    @State private var chapter = 23
    @State private var verses: [BibleVerse] = []
    @State private var errorMessage: String?
    @State private var syncedToPlan = false

    var body: some View {
        SelahTabScreen("Read") {
            VStack(spacing: 0) {
                planBanner
                pickerRow
                if let errorMessage {
                    Text(errorMessage)
                        .font(SelahFont.figtree(14))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                }
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(verses) { verse in
                            Text("\(verse.number). \(verse.text)")
                                .font(SelahFont.figtree(17))
                                .foregroundStyle(SelahColors.text)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                .selahTabScrollContent()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                SelahPinnedBottomBar {
                    SelahPrimaryButton(title: "Mark today complete") {
                        env.markPlanDayComplete(globalDay: env.planGlobalDay)
                        AnalyticsService.track("plan_day_complete")
                    }
                }
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

    private var planBanner: some View {
        let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay)
        return Group {
            if let day {
                HStack {
                    Text("Plan day \(env.planGlobalDay): \(day.book) \(day.chapter)")
                        .font(SelahFont.figtree(14))
                        .foregroundStyle(SelahColors.textMuted)
                    Spacer()
                    Button("Jump to plan") {
                        syncedToPlan = false
                        syncToPlanDayIfNeeded()
                        loadVerses()
                    }
                    .font(SelahFont.figtree(13, weight: .semibold))
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
            }
        }
    }

    private var pickerRow: some View {
        HStack {
            Picker("Book", selection: $selectedBookId) {
                ForEach(BibleBookCatalog.allBooks, id: \.id) { book in
                    Text(book.name).tag(book.id)
                }
            }
            .labelsHidden()
            Stepper("Ch \(chapter)", value: $chapter, in: 1...150)
                .font(SelahFont.figtree(14))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
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
