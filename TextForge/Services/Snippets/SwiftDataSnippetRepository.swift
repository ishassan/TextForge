import Foundation
import SwiftData

@MainActor
final class SwiftDataSnippetRepository: SnippetStoring {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func allSnippets() async -> [Snippet] {
        fetchAll()
    }

    func recentSnippets(matching query: String?, tag: String?) async -> [Snippet] {
        let normalizedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedTag = tag?.lowercased()

        return fetchAll().filter { snippet in
            let matchesQuery: Bool
            if let normalizedQuery, normalizedQuery.isEmpty == false {
                matchesQuery =
                    snippet.content.lowercased().contains(normalizedQuery) ||
                    snippet.preview.lowercased().contains(normalizedQuery) ||
                    snippet.tags.contains(where: { $0.lowercased().contains(normalizedQuery) })
            } else {
                matchesQuery = true
            }

            let matchesTag: Bool
            if let normalizedTag {
                matchesTag = snippet.tags.contains(where: { $0.lowercased() == normalizedTag })
            } else {
                matchesTag = true
            }

            return matchesQuery && matchesTag
        }
    }

    func save(_ snippet: Snippet) async {
        let descriptor = FetchDescriptor<SnippetEntity>(predicate: #Predicate { $0.id == snippet.id })
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.update(from: snippet)
        } else {
            modelContext.insert(SnippetEntity(snippet: snippet))
        }

        try? modelContext.save()
    }

    func delete(id: UUID) async {
        let descriptor = FetchDescriptor<SnippetEntity>(predicate: #Predicate { $0.id == id })
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try? modelContext.save()
        }
    }

    func togglePinned(id: UUID) async {
        guard let entity = fetchEntity(id: id) else { return }
        entity.isPinned.toggle()
        entity.updatedAt = .now
        try? modelContext.save()
    }

    func toggleFavorite(id: UUID) async {
        guard let entity = fetchEntity(id: id) else { return }
        entity.isFavorite.toggle()
        entity.updatedAt = .now
        try? modelContext.save()
    }

    private func fetchAll() -> [Snippet] {
        let descriptor = FetchDescriptor<SnippetEntity>()
        let entities: [SnippetEntity] = (try? modelContext.fetch(descriptor)) ?? []

        return entities
            .map { $0.toDomain() }
            .sorted {
                if $0.isPinned != $1.isPinned {
                    return $0.isPinned && !$1.isPinned
                }
                return $0.updatedAt > $1.updatedAt
            }
    }

    private func fetchEntity(id: UUID) -> SnippetEntity? {
        let descriptor = FetchDescriptor<SnippetEntity>(predicate: #Predicate { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }
}
