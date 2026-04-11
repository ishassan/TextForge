import SwiftUI

struct DocumentLibraryView: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Recent Notes")
                        .font(.headline)

                    ForEach(viewModel.documents.prefix(2)) { document in
                        Button {
                            viewModel.select(document)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(document.title)
                                        .font(.headline)
                                    Text(document.filename)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                            }
                        }
                        .buttonStyle(.plain)
                        .textForgeCard()
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }

            Section("Library") {
                ForEach(viewModel.filteredDocuments) { document in
                    NavigationLink {
                        DocumentEditorView(viewModel: viewModel, documentID: document.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(document.title)
                                .font(.headline)
                            Text(document.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            if document.tags.isEmpty == false {
                                Text(document.tags.map { "#\($0)" }.joined(separator: " "))
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.accent)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Editor")
        .searchable(text: $viewModel.searchText, prompt: "Search notes")
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("Import") {
                    viewModel.showImportPlaceholder()
                }

                Button("Open") {
                    viewModel.showImportPlaceholder()
                }
            }
        }
        .alert("Document Access", isPresented: Binding(
            get: { viewModel.importMessage != nil },
            set: { if !$0 { viewModel.importMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.importMessage ?? "")
        }
    }
}
