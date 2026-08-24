import Foundation

struct ReadingPlanFile: Decodable {
    let theme: String
    let themeLabel: String
    let desireKey: String
    let weeks: [ReadingPlanWeek]
}

struct ReadingPlanWeek: Decodable {
    let week: Int
    let weekTitle: String
    let days: [ReadingPlanDay]
}

struct ReadingPlanDay: Decodable, Identifiable {
    let dayIndex: Int
    let globalDay: Int
    let label: String
    let book: String
    let chapter: Int
    let focus: String
    let minutes: Int
    let reflectionPrompt: String

    var id: Int { globalDay }
}

struct ReadingPlanTheme: Identifiable {
    let key: String
    let label: String
    let days: [ReadingPlanDay]
    var id: String { key }

    func day(globalDay: Int) -> ReadingPlanDay? {
        days.first { $0.globalDay == globalDay }
    }

    func weekDays(week: Int) -> [ReadingPlanDay] {
        let start = (week - 1) * 7 + 1
        return days.filter { $0.globalDay >= start && $0.globalDay <= start + 6 }
    }
}

enum ReadingPlanRepositoryError: Error { case missingFile(String) }

final class ReadingPlanRepository {
    private let themes: [String: ReadingPlanTheme]

    init() throws {
        var loaded: [String: ReadingPlanTheme] = [:]
        for key in ["peace", "consistency", "freedom", "scripture"] {
            guard let url = Bundle.main.url(forResource: key, withExtension: "json", subdirectory: "Data/reading-plans")
                ?? Bundle.main.url(forResource: key, withExtension: "json", subdirectory: "reading-plans")
                ?? Bundle.main.url(forResource: key, withExtension: "json") else {
                throw ReadingPlanRepositoryError.missingFile(key)
            }
            let file = try JSONDecoder().decode(ReadingPlanFile.self, from: Data(contentsOf: url))
            let days = file.weeks.flatMap(\.days).sorted { $0.globalDay < $1.globalDay }
            loaded[file.theme] = ReadingPlanTheme(key: file.theme, label: file.themeLabel, days: days)
        }
        themes = loaded
    }

    func theme(for key: String) -> ReadingPlanTheme? { themes[key] }

    func theme(from desire: OnboardingDesire) -> ReadingPlanTheme? {
        themes[desire.planKey]
    }
}
