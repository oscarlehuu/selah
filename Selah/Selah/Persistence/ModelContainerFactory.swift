import Foundation
import SwiftData

enum ModelContainerFactory {
    static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([
            StreakStateModel.self,
            PlanProgressModel.self,
            JournalEntryModel.self,
            TalkSessionModel.self,
            TalkMessageModel.self,
            AppSettingsModel.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: inMemory ? .none : .automatic
        )
        return try ModelContainer(for: schema, configurations: [config])
    }
}
