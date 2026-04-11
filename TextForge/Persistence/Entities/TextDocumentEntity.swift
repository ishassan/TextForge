import Foundation
import SwiftData

@Model
final class TextDocumentEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var filename: String
    var storageKindData: Data
    var createdAt: Date
    var updatedAt: Date
    var lastOpenedAt: Date?
    var isOpen: Bool
    var tagsData: Data
    var knowledgeData: Data
    var body: String

    init(document: TextDocument) {
        self.id = document.id
        self.title = document.title
        self.filename = document.filename
        self.storageKindData = (try? JSONEncoder().encode(document.storageKind)) ?? Data()
        self.createdAt = document.createdAt
        self.updatedAt = document.updatedAt
        self.lastOpenedAt = document.lastOpenedAt
        self.isOpen = document.isOpen
        self.tagsData = (try? JSONEncoder().encode(document.tags)) ?? Data()
        self.knowledgeData = (try? JSONEncoder().encode(document.knowledge)) ?? Data()
        self.body = document.body
    }

    func toDomain() -> TextDocument {
        TextDocument(
            id: id,
            title: title,
            filename: filename,
            storageKind: (try? JSONDecoder().decode(DocumentStorageKind.self, from: storageKindData)) ?? .library(relativePath: filename),
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastOpenedAt: lastOpenedAt,
            isOpen: isOpen,
            tags: (try? JSONDecoder().decode([String].self, from: tagsData)) ?? [],
            knowledge: (try? JSONDecoder().decode(DocumentKnowledge.self, from: knowledgeData)) ?? .empty,
            body: body
        )
    }
}
