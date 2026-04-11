import Combine
import CoreGraphics
import Foundation

enum EditorMode: String, CaseIterable, Identifiable {
    case write = "Write"
    case preview = "Preview"
    case both = "Both"

    var id: String { rawValue }
}

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var documents: [TextDocument] = []
    @Published var searchText = ""
    @Published var editorMode: EditorMode = .both
    @Published var splitRatio: CGFloat = 0.55
    @Published var currentDocumentID: UUID?
    @Published var draftText = ""
    @Published var importMessage: String?

    private let coordinator: AppCoordinator
    private var cancellables: Set<AnyCancellable> = []

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.documents = coordinator.documents
        self.currentDocumentID = coordinator.selectedDocument?.id
        self.draftText = coordinator.selectedDocument?.body ?? ""

        coordinator.$documents
            .receive(on: RunLoop.main)
            .sink { [weak self] documents in
                self?.documents = documents
            }
            .store(in: &cancellables)

        coordinator.$selectedDocument
            .receive(on: RunLoop.main)
            .sink { [weak self] document in
                self?.currentDocumentID = document?.id
                self?.draftText = document?.body ?? self?.draftText ?? ""
            }
            .store(in: &cancellables)
    }

    var filteredDocuments: [TextDocument] {
        guard searchText.isEmpty == false else { return documents }

        return documents.filter { document in
            document.title.localizedCaseInsensitiveContains(searchText) ||
            document.body.localizedCaseInsensitiveContains(searchText) ||
            document.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }

    var currentDocument: TextDocument? {
        documents.first { $0.id == currentDocumentID }
    }

    func select(_ document: TextDocument) {
        coordinator.select(document: document)
    }

    func updateDraft(_ newValue: String) {
        draftText = newValue
        coordinator.currentActionInput = newValue
    }

    func saveCurrentDocument() async {
        guard var document = currentDocument else { return }
        document.body = draftText
        await coordinator.saveDocument(document)
    }

    func showImportPlaceholder() {
        importMessage = "Document import and open-in-place hooks are scaffolded, but simulator/device validation still requires full Xcode."
    }
}
