import Foundation
import SwiftData

enum ModelContainerFactory {
    @MainActor
    static func makeSharedContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([
            SnippetEntity.self,
            TextDocumentEntity.self,
            AppSettingsEntity.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }
}
