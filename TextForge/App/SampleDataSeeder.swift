import Foundation

@MainActor
enum SampleDataSeeder {
    static func seedIfNeeded(repository: SnippetStoring) async {
        let existing = await repository.allSnippets()
        guard existing.isEmpty else { return }

        for snippet in AppSampleData.snippets() {
            await repository.save(snippet)
        }
    }
}
