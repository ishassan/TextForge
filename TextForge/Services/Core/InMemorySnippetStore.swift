import Foundation

public actor InMemorySnippetStore: SnippetStoring {
    private var snippets: [UUID: Snippet]

    public init(snippets: [Snippet] = []) {
        self.snippets = Dictionary(uniqueKeysWithValues: snippets.map { ($0.id, $0) })
    }

    public func allSnippets() async -> [Snippet] {
        sort(snippets.values)
    }

    public func recentSnippets(matching query: String?, tag: String?) async -> [Snippet] {
        let normalizedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedTag = tag?.lowercased()

        return sort(snippets.values).filter { snippet in
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

    public func save(_ snippet: Snippet) async {
        var mutable = snippet
        mutable.refreshDerivedFields()
        snippets[mutable.id] = mutable
    }

    public func delete(id: UUID) async {
        snippets.removeValue(forKey: id)
    }

    public func togglePinned(id: UUID) async {
        guard var snippet = snippets[id] else { return }
        snippet.isPinned.toggle()
        snippet.refreshDerivedFields()
        snippets[id] = snippet
    }

    public func toggleFavorite(id: UUID) async {
        guard var snippet = snippets[id] else { return }
        snippet.isFavorite.toggle()
        snippet.refreshDerivedFields()
        snippets[id] = snippet
    }

    private func sort<S: Sequence>(_ snippets: S) -> [Snippet] where S.Element == Snippet {
        snippets.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            }
            return $0.updatedAt > $1.updatedAt
        }
    }
}
