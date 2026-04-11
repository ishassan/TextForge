import MarkdownUI
import SwiftUI

struct DocumentEditorView: View {
    @ObservedObject var viewModel: EditorViewModel
    let documentID: UUID

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                modePicker

                if let document = viewModel.documents.first(where: { $0.id == documentID }) {
                    metadataCard(for: document)
                    editorSurface(for: document)
                } else {
                    ContentUnavailableView("Missing Document", systemImage: "doc.slash")
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.currentDocument?.title ?? "Document")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let document = viewModel.documents.first(where: { $0.id == documentID }) {
                viewModel.select(document)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task { await viewModel.saveCurrentDocument() }
                }
            }
        }
    }

    @ViewBuilder
    private func editorSurface(for document: TextDocument) -> some View {
        switch viewModel.editorMode {
        case .write:
            EditorTextView(text: Binding(
                get: { viewModel.draftText },
                set: { viewModel.updateDraft($0) }
            ))
            .frame(minHeight: 320)
            .textForgeCard()
        case .preview:
            Markdown(viewModel.draftText.isEmpty ? document.body : viewModel.draftText)
                .padding()
                .textForgeCard()
        case .both:
            VStack(spacing: 12) {
                EditorTextView(text: Binding(
                    get: { viewModel.draftText },
                    set: { viewModel.updateDraft($0) }
                ))
                .frame(height: max(180, 420 * viewModel.splitRatio))
                .textForgeCard()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Split")
                            .font(.caption.weight(.semibold))
                        Slider(value: Binding(
                            get: { viewModel.splitRatio },
                            set: { viewModel.splitRatio = $0 }
                        ), in: 0.30...0.75)
                    }

                    Markdown(viewModel.draftText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(AppTheme.surface)
                        )
                }
            }
        }
    }

    private var modePicker: some View {
        Picker("Mode", selection: $viewModel.editorMode) {
            ForEach(EditorMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private func metadataCard(for document: TextDocument) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(document.filename)
                .font(.caption)
                .foregroundStyle(.secondary)

            if document.knowledge.headings.isEmpty == false {
                Text("Outline: " + document.knowledge.headings.map(\.title).joined(separator: " • "))
                    .font(.caption)
            }

            if document.knowledge.wikilinks.isEmpty == false {
                Text("Links: " + document.knowledge.wikilinks.joined(separator: ", "))
                    .font(.caption)
            }
        }
        .textForgeCard()
    }
}
