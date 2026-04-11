import Foundation

public struct KnowledgeGraphService: KnowledgeParsing {
    public init() {}

    public func parse(documentID: UUID, title: String, body: String, corpus: [TextDocument]) -> DocumentKnowledge {
        let headings = extractHeadings(from: body)
        let tags = extractTags(from: body)
        let wikilinks = extractWikilinks(from: body)
        let keywords = deriveKeywords(title: title, body: body, tags: tags, headings: headings)
        let document = TextDocument(id: documentID, title: title, filename: title, storageKind: .library(relativePath: ""), tags: tags, knowledge: .empty, body: body)
        let related = rankRelatedDocuments(for: document, in: corpus)
        let backlinks = corpus
            .filter { $0.knowledge.wikilinks.contains(Self.normalizedWikiTarget(for: title)) }
            .map(\.id)

        return DocumentKnowledge(
            headings: headings,
            tags: tags,
            wikilinks: wikilinks,
            backlinks: backlinks,
            relatedNotes: related,
            derivedKeywords: keywords
        )
    }

    public func rankRelatedDocuments(for document: TextDocument, in corpus: [TextDocument]) -> [UUID] {
        let documentTarget = Self.normalizedWikiTarget(for: document.title)
        let documentTags = Set((document.tags + document.knowledge.tags).map { $0.lowercased() })
        let documentKeywords = Set(document.knowledge.derivedKeywords.map { $0.lowercased() })

        return corpus
            .filter { $0.id != document.id }
            .map { candidate -> (UUID, Int) in
                var score = 0

                if candidate.knowledge.wikilinks.contains(documentTarget) {
                    score += 100
                }
                if document.knowledge.wikilinks.contains(candidate.normalizedWikiTarget) {
                    score += 90
                }

                let candidateTags = Set((candidate.tags + candidate.knowledge.tags).map { $0.lowercased() })
                score += documentTags.intersection(candidateTags).count * 15

                let candidateKeywords = Set(candidate.knowledge.derivedKeywords.map { $0.lowercased() })
                score += documentKeywords.intersection(candidateKeywords).count * 5

                return (candidate.id, score)
            }
            .filter { $0.1 > 0 }
            .sorted {
                if $0.1 != $1.1 { return $0.1 > $1.1 }
                return $0.0.uuidString < $1.0.uuidString
            }
            .map(\.0)
    }

    public static func normalizedWikiTarget(for raw: String) -> String {
        raw
            .lowercased()
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractHeadings(from body: String) -> [DocumentHeading] {
        body.enumerateLines()
            .enumerated()
            .compactMap { index, line in
                guard let match = line.range(of: #"^(#{1,6})\s+(.+)$"#, options: .regularExpression) else {
                    return nil
                }
                let value = String(line[match])
                let hashes = value.prefix { $0 == "#" }
                let title = String(value.drop(while: { $0 == "#" || $0 == " " }))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return DocumentHeading(level: hashes.count, title: title, line: index + 1)
            }
    }

    private func extractTags(from body: String) -> [String] {
        let regex = try? NSRegularExpression(pattern: #"(?<!\w)#([A-Za-z0-9_\-]+)"#)
        let range = NSRange(body.startIndex..<body.endIndex, in: body)
        let matches = regex?.matches(in: body, range: range) ?? []

        return Array(
            Set(
                matches.compactMap {
                    Range($0.range(at: 1), in: body).map { body[$0].lowercased() }
                }
            )
        )
        .sorted()
    }

    private func extractWikilinks(from body: String) -> [String] {
        let regex = try? NSRegularExpression(pattern: #"\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]"#)
        let range = NSRange(body.startIndex..<body.endIndex, in: body)
        let matches = regex?.matches(in: body, range: range) ?? []

        return Array(
            Set(
                matches.compactMap {
                    guard let range = Range($0.range(at: 1), in: body) else { return nil }
                    return Self.normalizedWikiTarget(for: String(body[range]))
                }
            )
        )
        .sorted()
    }

    private func deriveKeywords(title: String, body: String, tags: [String], headings: [DocumentHeading]) -> [String] {
        let titleTerms = tokenize(title)
        let headingTerms = headings.flatMap { tokenize($0.title) }
        let bodyTerms = tokenize(body).filter { $0.count >= 4 }

        return Array(Set(titleTerms + headingTerms + bodyTerms + tags)).sorted()
    }

    private func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 3 }
    }
}

private extension String {
    func enumerateLines() -> [String] {
        var result: [String] = []
        enumerateLines { line, _ in
            result.append(line)
        }
        return result
    }
}
