import SwiftUI
import SwiftData

struct JourneyJournalSection: View {
    let entries: [JournalEntryModel]
    var onSelect: (JournalEntryModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(JourneyCopy.journalSection)
                    .font(SelahFont.display(.title3))
                Spacer()
                Label(JourneyCopy.encrypted, systemImage: "lock.fill")
                    .font(SelahFont.ui(.caption, weight: .semibold))
                    .foregroundStyle(SelahColors.textMuted)
            }
            if entries.isEmpty {
                emptyState
            } else {
                VStack(spacing: 8) {
                    ForEach(entries.prefix(12)) { entry in
                        Button {
                            onSelect(entry)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.previewHint.isEmpty ? "Journal entry" : entry.previewHint)
                                    .foregroundStyle(SelahColors.text)
                                Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(SelahFont.ui(.caption))
                                    .foregroundStyle(SelahColors.textMuted)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(SelahColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "pencil")
                .font(.title2)
                .foregroundStyle(SelahColors.accent)
            Text(JourneyCopy.emptyJournalTitle)
                .font(SelahFont.display(.title3))
            Text(JourneyCopy.emptyJournalBody)
                .font(SelahFont.ui(.subheadline))
                .foregroundStyle(SelahColors.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(SelahColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
