import Foundation

public protocol ClipboardMonitoring: Sendable {
    func captureIfNeeded(
        currentChangeCount: Int,
        settings: AppSettings,
        stringProvider: @escaping @Sendable () -> String?
    ) async -> Snippet?
}

public protocol DocumentAccessing: Sendable {
    func loadDocument(id: UUID) async throws -> TextDocument
    func saveDocument(_ document: TextDocument) async throws
    func exportHTML(for document: TextDocument) async throws -> Data
    func exportPDF(for document: TextDocument) async throws -> Data
}

public protocol SearchIndexing: Sendable {
    func upsert(snippet: Snippet) async
    func upsert(document: TextDocument) async
    func delete(id: UUID, kind: SearchResultKind) async
    func search(query: String) async -> [SearchResult]
}

public protocol KnowledgeParsing: Sendable {
    func parse(documentID: UUID, title: String, body: String, corpus: [TextDocument]) -> DocumentKnowledge
    func rankRelatedDocuments(for document: TextDocument, in corpus: [TextDocument]) -> [UUID]
}

public protocol SnippetStoring: Sendable {
    func allSnippets() async -> [Snippet]
    func recentSnippets(matching query: String?, tag: String?) async -> [Snippet]
    func save(_ snippet: Snippet) async
    func delete(id: UUID) async
    func togglePinned(id: UUID) async
    func toggleFavorite(id: UUID) async
}

public protocol WorkflowExecuting: Sendable {
    func execute(workflow: Workflow, input: String, context: ActionExecutionContext) throws -> WorkflowExecutionResult
}
