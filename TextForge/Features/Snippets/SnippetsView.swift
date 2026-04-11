import SwiftUI

struct SnippetsView: View {
    @ObservedObject var viewModel: SnippetsViewModel

    var body: some View {
        List {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(title: "All", isSelected: viewModel.selectedTag == nil) {
                            viewModel.selectedTag = nil
                        }
                        ForEach(viewModel.availableTags, id: \.self) { tag in
                            filterChip(title: "#\(tag)", isSelected: viewModel.selectedTag == tag) {
                                viewModel.selectedTag = tag
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Section {
                ForEach(viewModel.snippets) { snippet in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if snippet.isPinned {
                                Image(systemName: "pin.fill")
                                    .foregroundStyle(AppTheme.warm)
                            }
                            if snippet.isFavorite {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                            }
                            Text(snippet.preview.isEmpty ? "Untitled Snippet" : snippet.preview)
                                .font(.headline)
                                .lineLimit(2)
                        }

                        Text(snippet.plainText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)

                        if snippet.tags.isEmpty == false {
                            Text(snippet.tags.map { "#\($0)" }.joined(separator: " "))
                                .font(.caption)
                                .foregroundStyle(AppTheme.accent)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.select(snippet)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task { await viewModel.delete(snippet) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            Task { await viewModel.toggleFavorite(snippet) }
                        } label: {
                            Label("Favorite", systemImage: snippet.isFavorite ? "star.slash" : "star")
                        }
                        .tint(.yellow)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            Task { await viewModel.togglePinned(snippet) }
                        } label: {
                            Label("Pin", systemImage: snippet.isPinned ? "pin.slash" : "pin")
                        }
                        .tint(AppTheme.warm)
                    }
                }
            } header: {
                HStack {
                    Text("Saved Snippets")
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
        }
        .navigationTitle("Snippets")
        .searchable(text: $viewModel.searchText, prompt: "Search content or tags")
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.refresh()
        }
        .task(id: viewModel.searchText) {
            await viewModel.refresh()
        }
        .task(id: viewModel.selectedTag) {
            await viewModel.refresh()
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { await viewModel.captureClipboard() }
            } label: {
                Label("Capture Clipboard", systemImage: "doc.on.clipboard")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .background(.ultraThinMaterial)
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.accent.opacity(0.18) : AppTheme.surface)
                )
        }
        .buttonStyle(.plain)
    }
}
