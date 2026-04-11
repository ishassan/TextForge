import Foundation
import SwiftData
import UIKit

@MainActor
final class AppCoordinator: ObservableObject {
    let snippetRepository: SnippetStoring
    let clipboardMonitor: ClipboardMonitoring
    let searchIndex: SearchIndexing
    let knowledgeService: KnowledgeParsing
    let workflowEngine: WorkflowExecuting
    let documentService: DocumentAccessing
    private let modelContext: ModelContext

    @Published var settings: AppSettings
    @Published var documents: [TextDocument]
    @Published var workflows: [Workflow]
    @Published var selectedDocument: TextDocument?
    @Published var selectedSnippet: Snippet?
    @Published var currentActionInput: String
    @Published var currentActionOutput: String
    @Published var isSearchPresented = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.snippetRepository = SwiftDataSnippetRepository(modelContext: modelContext)
        self.clipboardMonitor = ClipboardMonitoringService()
        self.searchIndex = LocalSearchIndexService()
        self.knowledgeService = KnowledgeGraphService()
        self.workflowEngine = WorkflowEngine()
        self.documentService = LocalDocumentService()

        if let settingsEntity = try? modelContext.fetch(FetchDescriptor<AppSettingsEntity>()).first {
            self.settings = settingsEntity.toDomain()
        } else {
            let defaults = AppSettings()
            let entity = AppSettingsEntity(settings: defaults)
            modelContext.insert(entity)
            try? modelContext.save()
            self.settings = defaults
        }

        let seededDocuments = AppSampleData.documents(using: knowledgeService)
        self.documents = seededDocuments
        self.workflows = AppSampleData.workflows()
        self.selectedDocument = seededDocuments.first
        self.currentActionInput = seededDocuments.first?.body ?? ""
        self.currentActionOutput = ""
    }

    func bootstrap() async {
        await SampleDataSeeder.seedIfNeeded(repository: snippetRepository)
        await reindexAll()
    }

    func saveSettings() {
        guard let entity = try? modelContext.fetch(FetchDescriptor<AppSettingsEntity>()).first else { return }
        entity.update(from: settings)
        try? modelContext.save()
    }

    func saveDocument(_ document: TextDocument) async {
        guard let index = documents.firstIndex(where: { $0.id == document.id }) else { return }

        var updated = document
        updated.updatedAt = .now
        updated.lastOpenedAt = .now
        updated.knowledge = knowledgeService.parse(
            documentID: updated.id,
            title: updated.title,
            body: updated.body,
            corpus: documents.filter { $0.id != updated.id }
        )

        documents[index] = updated
        selectedDocument = updated
        currentActionInput = updated.body
        try? await documentService.saveDocument(updated)
        await reindexAll()
    }

    func select(document: TextDocument) {
        selectedDocument = document
        currentActionInput = document.body
    }

    func applySelectedSnippet(_ snippet: Snippet) {
        selectedSnippet = snippet
        currentActionInput = snippet.content
    }

    func duplicateWorkflow(_ workflow: Workflow) {
        let duplicate = Workflow(name: "\(workflow.name) Copy", steps: workflow.steps)
        workflows.append(duplicate)
    }

    func deleteWorkflow(_ workflow: Workflow) {
        workflows.removeAll { $0.id == workflow.id }
    }

    func addWorkflow(named name: String) {
        workflows.append(Workflow(name: name, steps: [WorkflowStep(kind: .trimWhitespace)]))
    }

    func run(workflow: Workflow, input: String, context: ActionExecutionContext) {
        do {
            currentActionOutput = try workflowEngine.execute(
                workflow: workflow,
                input: input,
                context: context
            ).output
        } catch {
            currentActionOutput = error.localizedDescription
        }
    }

    func search(query: String) async -> [SearchResult] {
        await searchIndex.search(query: query)
    }

    func captureClipboard() async {
        let changeCount = UIPasteboard.general.changeCount
        guard let snippet = await clipboardMonitor.captureIfNeeded(
            currentChangeCount: changeCount,
            settings: settings,
            stringProvider: { UIPasteboard.general.string }
        ) else {
            return
        }

        if settings.automaticClipboardSave {
            await snippetRepository.save(snippet)
            selectedSnippet = snippet
            await reindexAll()
        } else {
            selectedSnippet = snippet
            currentActionInput = snippet.content
        }
    }

    func reindexAll() async {
        let snippets = await snippetRepository.allSnippets()
        for snippet in snippets {
            await searchIndex.upsert(snippet: snippet)
        }
        for document in documents {
            await searchIndex.upsert(document: document)
        }
    }
}
