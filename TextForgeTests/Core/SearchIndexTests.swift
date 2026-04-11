import XCTest
@testable import TextForgeCore

final class SearchIndexTests: XCTestCase {
    func testTitleRankingBeatsBodyRanking() async {
        let search = LocalSearchIndexService()

        let bodyOnly = TextDocument(
            title: "General Notes",
            filename: "general.md",
            storageKind: .library(relativePath: "general.md"),
            knowledge: DocumentKnowledge(derivedKeywords: ["parsing"]),
            body: "Some parsing details live here"
        )
        let titleMatch = TextDocument(
            title: "Parsing Guide",
            filename: "parsing-guide.md",
            storageKind: .library(relativePath: "parsing-guide.md"),
            knowledge: DocumentKnowledge(derivedKeywords: []),
            body: "Reference text"
        )

        await search.upsert(document: bodyOnly)
        await search.upsert(document: titleMatch)

        let results = await search.search(query: "parsing")
        XCTAssertEqual(results.first?.id, titleMatch.id)
    }

    func testMixedResultsAndTagMatches() async {
        let search = LocalSearchIndexService()

        let snippet = Snippet(content: "Clipboard token", tags: ["auth"], source: .clipboard)
        let doc = TextDocument(
            title: "Authentication",
            filename: "authentication.md",
            storageKind: .library(relativePath: "authentication.md"),
            tags: ["security"],
            knowledge: DocumentKnowledge(tags: ["auth"], derivedKeywords: ["oauth"]),
            body: "Token flow"
        )

        await search.upsert(snippet: snippet)
        await search.upsert(document: doc)

        let results = await search.search(query: "auth")
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(Set(results.map(\.kind)), Set([.snippet, .document]))
    }
}
