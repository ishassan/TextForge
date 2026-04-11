import Foundation
import TextForgeCore

@main
struct TextForgeCoreSmoke {
    static func main() async throws {
        try actionPipelineCheck()
        try await searchCheck()
        try await snippetStoreCheck()
        try knowledgeGraphCheck()
        print("TextForgeCore smoke checks passed.")
    }

    private static func actionPipelineCheck() throws {
        let workflow = Workflow(
            name: "Normalize",
            steps: [
                WorkflowStep(kind: .trimWhitespace),
                WorkflowStep(kind: .uppercase),
                WorkflowStep(kind: .uniqueLines)
            ]
        )

        let result = try WorkflowEngine().execute(
            workflow: workflow,
            input: "  alpha \n beta\nalpha  ",
            context: .pastedText
        )

        guard result.output == "ALPHA\nBETA" else {
            throw SmokeError.failed("Workflow pipeline output mismatch")
        }
    }

    private static func searchCheck() async throws {
        let search = LocalSearchIndexService()
        let snippet = Snippet(content: "Clipboard token", tags: ["auth"], source: .clipboard)
        let document = TextDocument(
            title: "Authentication",
            filename: "authentication.md",
            storageKind: .library(relativePath: "authentication.md"),
            knowledge: DocumentKnowledge(tags: ["auth"], derivedKeywords: ["oauth"]),
            body: "Token flow"
        )

        await search.upsert(snippet: snippet)
        await search.upsert(document: document)

        let results = await search.search(query: "auth")
        guard results.count == 2 else {
            throw SmokeError.failed("Search results were incomplete")
        }
    }

    private static func snippetStoreCheck() async throws {
        let older = Snippet(
            content: "alpha",
            createdAt: Date(timeIntervalSince1970: 10),
            updatedAt: Date(timeIntervalSince1970: 10),
            tags: ["ios"]
        )
        let newer = Snippet(
            content: "beta",
            createdAt: Date(timeIntervalSince1970: 20),
            updatedAt: Date(timeIntervalSince1970: 20),
            tags: ["swift"]
        )

        let store = InMemorySnippetStore(snippets: [older, newer])
        await store.togglePinned(id: older.id)
        let ordered = await store.allSnippets()

        guard ordered.first?.id == older.id else {
            throw SmokeError.failed("Pinned ordering failed")
        }
    }

    private static func knowledgeGraphCheck() throws {
        let service = KnowledgeGraphService()
        let knowledge = service.parse(
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

        guard knowledge.headings.count == 2 else {
            throw SmokeError.failed("Heading extraction failed")
        }
        guard knowledge.wikilinks == ["project alpha"] else {
            throw SmokeError.failed("Wikilink normalization failed")
        }
    }
}

private enum SmokeError: Error {
    case failed(String)
}
