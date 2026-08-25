import SwiftUI

struct CrisisResourcesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("You deserve real support right now.")
                        .font(SelahFont.display(.title3))
                }
                Section("Hotlines") {
                    Text("US: Call or text 988")
                    Text("Australia: Lifeline 13 11 14")
                    Text("UK & Ireland: Samaritans 116 123")
                    Text("Emergency: local emergency number")
                }
            }
            .navigationTitle("Crisis resources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct PrivacyInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("How privacy works") {
                    Text("Talk, journal, and prayer stay on this iPhone. The companion uses Apple Intelligence on-device when available. Nothing is uploaded to Selah.")
                }
                Section {
                    Text(OnboardingCopy.companionDisclaimer)
                }
            }
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
