import Foundation
import Observation

@Observable
@MainActor
final class LectioPrayEngine {
    var turn: CompanionTurn?
    var isGenerating = false

    private let companion: any CompanionGenerating
    private var lastContext: PrayerDraftContext?

    init(companion: any CompanionGenerating = OnDeviceCompanion()) {
        self.companion = companion
    }

    func draft(_ context: PrayerDraftContext) async -> CompanionTurn {
        lastContext = context
        guard companion.isAvailable else {
            let unavailable = CompanionTurn.unavailable(CompanionTextService.unavailableMessage)
            turn = unavailable
            return unavailable
        }
        isGenerating = true
        let result = await companion.prayerDraft(context: context)
        turn = result
        isGenerating = false
        return result
    }

    func anotherPrayer() async -> CompanionTurn? {
        guard let lastContext else { return nil }
        return await draft(lastContext)
    }

    func reset() {
        turn = nil
        lastContext = nil
        isGenerating = false
    }
}
