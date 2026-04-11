import Foundation

public enum SearchResultKind: String, Codable, Hashable, Sendable {
    case snippet
    case document
}

public struct SearchResult: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let kind: SearchResultKind
    public let title: String
    public let subtitle: String
    public let tags: [String]
    public let score: Int

    public init(id: UUID, kind: SearchResultKind, title: String, subtitle: String, tags: [String], score: Int) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.tags = tags
        self.score = score
    }
}
