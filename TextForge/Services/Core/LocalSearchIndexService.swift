import Foundation

public actor LocalSearchIndexService: SearchIndexing {
    private struct IndexedRecord: Sendable {
        let id: UUID
        let kind: SearchResultKind
        let title: String
        let subtitle: String
        let tags: [String]
        let titleTerms: Set<String>
        let bodyTerms: Set<String>
        let keywords: Set<String>
    }

    private var records: [UUID: IndexedRecord] = [:]

    public init() {}

    public func upsert(snippet: Snippet) async {
        let record = IndexedRecord(
            id: snippet.id,
            kind: .snippet,
            title: snippet.preview.isEmpty ? "Snippet" : snippet.preview,
            subtitle: snippet.plainText,
            tags: snippet.tags,
            titleTerms: Self.tokenize(snippet.preview),
            bodyTerms: Self.tokenize(snippet.plainText),
            keywords: Set(snippet.tags.map { $0.lowercased() })
        )
        records[record.id] = record
    }

    public func upsert(document: TextDocument) async {
        let record = IndexedRecord(
            id: document.id,
            kind: .document,
            title: document.title,
            subtitle: document.body,
            tags: Array(Set(document.tags + document.knowledge.tags)),
            titleTerms: Self.tokenize(document.title),
            bodyTerms: Self.tokenize(document.body),
            keywords: Set(document.knowledge.derivedKeywords + document.knowledge.wikilinks + document.tags + document.knowledge.tags)
        )
        records[record.id] = record
    }

    public func delete(id: UUID, kind _: SearchResultKind) async {
        records.removeValue(forKey: id)
    }

    public func search(query: String) async -> [SearchResult] {
        let terms = Self.tokenize(query)
        guard terms.isEmpty == false else { return [] }

        return records.values.compactMap { record in
            let score = score(for: terms, record: record)
            guard score > 0 else { return nil }
            return SearchResult(
                id: record.id,
                kind: record.kind,
                title: record.title,
                subtitle: record.subtitle,
                tags: record.tags,
                score: score
            )
        }
        .sorted {
            if $0.score != $1.score { return $0.score > $1.score }
            return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    private func score(for terms: Set<String>, record: IndexedRecord) -> Int {
        var score = 0

        for term in terms {
            if record.titleTerms.contains(term) {
                score += 30
            }
            if record.bodyTerms.contains(term) {
                score += 10
            }
            if record.keywords.contains(term) {
                score += 20
            }
        }

        return score
    }

    private static func tokenize(_ text: String) -> Set<String> {
        Set(
            text.lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { $0.count >= 2 }
        )
    }
}
