import SwiftUI

struct GlobalSearchSheet: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var coordinator: AppCoordinator
    @State private var query = ""
    @State private var results: [SearchResult] = []

    var body: some View {
        NavigationStack {
            List(results) { result in
                Button {
                    Task {
                        await select(result)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.title)
                            .font(.headline)
                        Text(result.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Text(result.kind.rawValue.capitalized + " • score \(result.score)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.accent)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "Search snippets and notes")
            .task(id: query) {
                if query.isEmpty {
                    results = []
                } else {
                    results = await coordinator.search(query: query)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func select(_ result: SearchResult) async {
        switch result.kind {
        case .document:
            if let document = coordinator.documents.first(where: { $0.id == result.id }) {
                coordinator.select(document: document)
            }
        case .snippet:
            let snippets = await coordinator.snippetRepository.allSnippets()
            if let snippet = snippets.first(where: { $0.id == result.id }) {
                coordinator.applySelectedSnippet(snippet)
            }
        }

        dismiss()
    }
}
