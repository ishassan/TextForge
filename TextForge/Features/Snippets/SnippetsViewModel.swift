import Foundation

@MainActor
final class SnippetsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedTag: String?
    @Published private(set) var snippets: [Snippet] = []
    @Published var isLoading = false

    private let repository: SnippetStoring
    private let coordinator: AppCoordinator

    init(repository: SnippetStoring, coordinator: AppCoordinator) {
        self.repository = repository
        self.coordinator = coordinator
    }

    var availableTags: [String] {
        Array(Set(snippets.flatMap(\.tags))).sorted()
    }

    func refresh() async {
        isLoading = true
        snippets = await repository.recentSnippets(
            matching: searchText.isEmpty ? nil : searchText,
            tag: selectedTag
        )
        isLoading = false
    }

    func select(_ snippet: Snippet) {
        coordinator.applySelectedSnippet(snippet)
    }

    func togglePinned(_ snippet: Snippet) async {
        await repository.togglePinned(id: snippet.id)
        await refresh()
        await coordinator.reindexAll()
    }

    func toggleFavorite(_ snippet: Snippet) async {
        await repository.toggleFavorite(id: snippet.id)
        await refresh()
        await coordinator.reindexAll()
    }

    func delete(_ snippet: Snippet) async {
        await repository.delete(id: snippet.id)
        await refresh()
        await coordinator.reindexAll()
    }

    func captureClipboard() async {
        await coordinator.captureClipboard()
        await refresh()
    }
}
