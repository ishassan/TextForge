import Foundation

public struct SnippetTag: Hashable, Codable, Sendable, Identifiable {
    public var id: String { name }
    public let name: String

    public init(name: String) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public enum SnippetSource: String, Codable, CaseIterable, Sendable {
    case manual
    case clipboard
    case imported
}

public struct Snippet: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var content: String
    public var createdAt: Date
    public var updatedAt: Date
    public var isPinned: Bool
    public var isFavorite: Bool
    public var tags: [String]
    public var source: SnippetSource
    public var preview: String
    public var plainText: String

    public init(
        id: UUID = UUID(),
        content: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isPinned: Bool = false,
        isFavorite: Bool = false,
        tags: [String] = [],
        source: SnippetSource = .manual,
        preview: String? = nil,
        plainText: String? = nil
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
        self.isFavorite = isFavorite
        self.tags = tags
        self.source = source
        self.plainText = plainText ?? Self.makePlainText(from: content)
        self.preview = preview ?? Self.makePreview(from: self.plainText)
    }

    public mutating func refreshDerivedFields(now: Date = .now) {
        updatedAt = now
        plainText = Self.makePlainText(from: content)
        preview = Self.makePreview(from: plainText)
    }

    public static func makePlainText(from content: String) -> String {
        content
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public static func makePreview(from plainText: String, limit: Int = 120) -> String {
        guard plainText.count > limit else { return plainText }
        return String(plainText.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }
}
