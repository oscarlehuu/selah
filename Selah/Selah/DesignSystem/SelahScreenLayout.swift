import SwiftUI

struct DemoModeBanner: View {
    var body: some View {
        Text("Demo")
            .font(SelahFont.ui(.caption2, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

struct SelahComposerBar: View {
    @Binding var text: String
    var isSending: Bool
    var onSend: () -> Void

    var body: some View {
        SelahFooterBar {
            HStack(alignment: .bottom, spacing: 10) {
                TextField("Say it plainly…", text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .font(SelahFont.ui(.body))
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("talk.composer")
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                }
                .disabled(!canSend || isSending)
                .accessibilityLabel("Send")
            }
        }
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
