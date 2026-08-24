import SwiftUI

struct JournalEntryDetailView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    let entry: JournalEntryModel
    @State private var plaintext: String?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                SundayLightBackground()
                if isLoading {
                    ProgressView()
                } else if let plaintext {
                    ScrollView {
                        Text(plaintext)
                            .font(SelahFont.verse(18))
                            .foregroundStyle(SelahColors.text)
                            .padding(24)
                    }
                } else {
                    Text("Could not unlock this entry.")
                        .font(SelahFont.figtree(16))
                        .foregroundStyle(SelahColors.textMuted)
                }
            }
            .navigationTitle(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task { await loadEntry() }
        }
    }

    private func loadEntry() async {
        if env.settings?.requireFaceIDForJournal == true {
            let ok = await BiometricGate.authenticate(reason: "Unlock your journal")
            guard ok else { isLoading = false; return }
        }
        plaintext = try? env.decryptJournalEntry(entry)
        isLoading = false
    }
}

extension JournalEntryModel: Identifiable {}
