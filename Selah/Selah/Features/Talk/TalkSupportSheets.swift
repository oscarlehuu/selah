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
                    Text("Your conversation text, prayers, journal entries, and companion responses are processed on this iPhone using Apple Intelligence. Selah does not send this content to any third-party AI service and has no cloud AI fallback.")
                    Text("Generated replies require iOS 26 or later on a compatible iPhone with Apple Intelligence enabled and its model downloaded. When unavailable, Selah shows an availability message.")
                }
                Section("Analytics and subscriptions") {
                    Text("PostHog receives limited onboarding and purchase funnel events with a random app identifier. Mood, quiz answers, prayer text, journal entries, and crisis signals are excluded. RevenueCat and Apple handle subscription status and purchases. These services do not provide the companion AI.")
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
