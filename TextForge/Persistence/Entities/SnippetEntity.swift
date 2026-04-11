import Foundation
import SwiftData

@Model
final class SnippetEntity {
    @Attribute(.unique) var id: UUID
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    var isFavorite: Bool
    var tagsData: Data
    var sourceRawValue: String
    var preview: String
    var plainText: String

    init(snippet: Snippet) {
        self.id = snippet.id
        self.content = snippet.content
        self.createdAt = snippet.createdAt
        self.updatedAt = snippet.updatedAt
        self.isPinned = snippet.isPinned
        self.isFavorite = snippet.isFavorite
        self.tagsData = (try? JSONEncoder().encode(snippet.tags)) ?? Data()
        self.sourceRawValue = snippet.source.rawValue
        self.preview = snippet.preview
        self.plainText = snippet.plainText
    }

    var tags: [String] {
        (try? JSONDecoder().decode([String].self, from: tagsData)) ?? []
    }

    func update(from snippet: Snippet) {
        content = snippet.content
        createdAt = snippet.createdAt
        updatedAt = snippet.updatedAt
        isPinned = snippet.isPinned
        isFavorite = snippet.isFavorite
        tagsData = (try? JSONEncoder().encode(snippet.tags)) ?? Data()
        sourceRawValue = snippet.source.rawValue
        preview = snippet.preview
        plainText = snippet.plainText
    }

    func toDomain() -> Snippet {
        Snippet(
            id: id,
            content: content,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isPinned: isPinned,
            isFavorite: isFavorite,
            tags: tags,
            source: SnippetSource(rawValue: sourceRawValue) ?? .manual,
            preview: preview,
            plainText: plainText
        )
    }
}
