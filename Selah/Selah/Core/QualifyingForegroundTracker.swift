import Foundation
import Observation

@MainActor
@Observable
final class QualifyingForegroundTracker {
    private var accumulatedSeconds: Double = 0
    private var lastActiveTick: Date?
    private var backgroundSince: Date?
    private var qualifiedToday = false
    private var trackingPrayOrTalk = false
    private var isForeground = true

    private let thresholdSeconds: Double = 300
    private let backgroundPauseSeconds: Double = 30

    var onThreshold: (() -> Void)?

    func setPrayOrTalkActive(_ active: Bool) {
        trackingPrayOrTalk = active
        lastActiveTick = active && isForeground ? .now : nil
    }

    func setForeground(_ foreground: Bool) {
        isForeground = foreground
        if foreground {
            backgroundSince = nil
            if trackingPrayOrTalk { lastActiveTick = .now }
        } else {
            backgroundSince = .now
            lastActiveTick = nil
        }
    }

    func tick(now: Date = .now) {
        if let pausedAt = backgroundSince, now.timeIntervalSince(pausedAt) > backgroundPauseSeconds {
            lastActiveTick = now
            backgroundSince = nil
        }
        guard trackingPrayOrTalk, isForeground, !qualifiedToday else { return }
        guard let tickStart = lastActiveTick else {
            lastActiveTick = now
            return
        }
        accumulatedSeconds += now.timeIntervalSince(tickStart)
        lastActiveTick = now
        if accumulatedSeconds >= thresholdSeconds {
            qualifiedToday = true
            onThreshold?()
        }
    }

    func resetForNewDay() {
        accumulatedSeconds = 0
        qualifiedToday = false
        lastActiveTick = trackingPrayOrTalk && isForeground ? .now : nil
    }
}
