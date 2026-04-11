import Foundation

public enum DocumentStorageKind: Hashable, Codable, Sendable {
    case library(relativePath: String)
    case externalBookmark(bookmarkData: Data)
}

public struct TextDocument: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var title: String
    public var filename: String
    public var storageKind: DocumentStorageKind
    public var createdAt: Date
    public var updatedAt: Date
    public var lastOpenedAt: Date?
    public var isOpen: Bool
    public var tags: [String]
    public var knowledge: DocumentKnowledge
    public var body: String

    public init(
        id: UUID = UUID(),
        title: String,
        filename: String,
        storageKind: DocumentStorageKind,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        lastOpenedAt: Date? = nil,
        isOpen: Bool = false,
        tags: [String] = [],
        knowledge: DocumentKnowledge = .empty,
        body: String = ""
    ) {
        self.id = id
        self.title = title
        self.filename = filename
        self.storageKind = storageKind
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastOpenedAt = lastOpenedAt
        self.isOpen = isOpen
        self.tags = tags
        self.knowledge = knowledge
        self.body = body
    }

    public var normalizedWikiTarget: String {
        KnowledgeGraphService.normalizedWikiTarget(for: title)
    }
}
