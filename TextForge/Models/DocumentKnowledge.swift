import Foundation

public struct DocumentHeading: Hashable, Codable, Sendable {
    public let level: Int
    public let title: String
    public let line: Int

    public init(level: Int, title: String, line: Int) {
        self.level = level
        self.title = title
        self.line = line
    }
}

public struct DocumentKnowledge: Hashable, Codable, Sendable {
    public var headings: [DocumentHeading]
    public var tags: [String]
    public var wikilinks: [String]
    public var backlinks: [UUID]
    public var relatedNotes: [UUID]
    public var derivedKeywords: [String]

    public init(
        headings: [DocumentHeading] = [],
        tags: [String] = [],
        wikilinks: [String] = [],
        backlinks: [UUID] = [],
        relatedNotes: [UUID] = [],
        derivedKeywords: [String] = []
    ) {
        self.headings = headings
        self.tags = tags
        self.wikilinks = wikilinks
        self.backlinks = backlinks
        self.relatedNotes = relatedNotes
        self.derivedKeywords = derivedKeywords
    }

    public static let empty = DocumentKnowledge()
}
