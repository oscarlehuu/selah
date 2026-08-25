import SwiftUI

struct JournalEntryDetailView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    let entry: JournalEntryModel
    @State private var plaintext: String?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Unlocking")
                } else if let plaintext {
                    List {
                        Section {
                            Text(plaintext)
                                .font(SelahFont.verse(.body))
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    ContentUnavailableView(
                        "Could not unlock this entry",
                        systemImage: "lock.fill",
                        description: Text("Face ID is required when journal lock is on.")
                    )
                }
            }
            .navigationTitle(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
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
