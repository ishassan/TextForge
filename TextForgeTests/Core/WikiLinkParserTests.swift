import Foundation
import XCTest
@testable import TextForgeCore

final class WikiLinkParserTests: XCTestCase {
    func testWikilinkNormalizationAndHeadingExtraction() {
        let knowledge = KnowledgeGraphService().parse(
            documentID: UUID(),
            title: "Daily Notes",
            body: """
            # Inbox
            See [[Project Alpha]] and [[project_alpha|Alias]].
            Track #ios and #swift.
            ## Later
            """,
            corpus: []
        )

        XCTAssertEqual(knowledge.headings.count, 2)
        XCTAssertEqual(knowledge.wikilinks, ["project alpha"])
        XCTAssertEqual(Set(knowledge.tags), Set(["ios", "swift"]))
    }

    func testBacklinkGraphAndRelatedRanking() {
        let service = KnowledgeGraphService()

        let alphaID = UUID()
        var alpha = TextDocument(
            id: alphaID,
            title: "Project Alpha",
            filename: "project-alpha.md",
            storageKind: .library(relativePath: "project-alpha.md"),
            tags: ["swift"],
            body: "# Project Alpha"
        )
        alpha.knowledge = service.parse(documentID: alpha.id, title: alpha.title, body: alpha.body, corpus: [])

        let betaID = UUID()
        var beta = TextDocument(
            id: betaID,
            title: "Sprint Notes",
            filename: "sprint-notes.md",
            storageKind: .library(relativePath: "sprint-notes.md"),
            tags: ["swift", "planning"],
            body: "Link [[Project Alpha]] #swift"
        )
        beta.knowledge = service.parse(documentID: beta.id, title: beta.title, body: beta.body, corpus: [alpha])

        let gammaID = UUID()
        var gamma = TextDocument(
            id: gammaID,
            title: "Other",
            filename: "other.md",
            storageKind: .library(relativePath: "other.md"),
            tags: ["planning"],
            body: "No direct link but related via #swift"
        )
        gamma.knowledge = service.parse(documentID: gamma.id, title: gamma.title, body: gamma.body, corpus: [alpha, beta])

        let refreshedAlpha = service.parse(documentID: alpha.id, title: alpha.title, body: alpha.body, corpus: [beta, gamma])
        XCTAssertEqual(refreshedAlpha.backlinks, [betaID])

        let related = service.rankRelatedDocuments(for: alpha, in: [beta, gamma])
        XCTAssertEqual(related.first, betaID)
        XCTAssertTrue(related.contains(gammaID))
    }
}
