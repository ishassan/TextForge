import SwiftUI

struct RootTabView: View {
    @StateObject private var snippetsViewModel: SnippetsViewModel
    @StateObject private var editorViewModel: EditorViewModel
    @StateObject private var actionsViewModel: ActionsViewModel
    @State private var isSettingsPresented = false

    @ObservedObject private var coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        self._coordinator = ObservedObject(wrappedValue: coordinator)
        _snippetsViewModel = StateObject(
            wrappedValue: SnippetsViewModel(
                repository: coordinator.snippetRepository,
                coordinator: coordinator
            )
        )
        _editorViewModel = StateObject(wrappedValue: EditorViewModel(coordinator: coordinator))
        _actionsViewModel = StateObject(wrappedValue: ActionsViewModel(coordinator: coordinator))
    }

    var body: some View {
        TabView {
            NavigationStack {
                SnippetsView(viewModel: snippetsViewModel)
                    .toolbar { chromeToolbar }
            }
            .tabItem {
                Label("Snippets", systemImage: "pin.text")
            }

            NavigationStack {
                DocumentLibraryView(viewModel: editorViewModel)
                    .toolbar { chromeToolbar }
            }
            .tabItem {
                Label("Editor", systemImage: "doc.text")
            }

            NavigationStack {
                ActionsView(viewModel: actionsViewModel)
                    .toolbar { chromeToolbar }
            }
            .tabItem {
                Label("Actions", systemImage: "wand.and.stars")
            }
        }
        .sheet(isPresented: $coordinator.isSearchPresented) {
            GlobalSearchSheet(coordinator: coordinator)
        }
        .sheet(isPresented: $isSettingsPresented) {
            NavigationStack {
                SettingsView(coordinator: coordinator)
            }
        }
    }

    @ToolbarContentBuilder
    private var chromeToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                coordinator.isSearchPresented = true
            } label: {
                Image(systemName: "magnifyingglass")
            }

            Button {
                isSettingsPresented = true
            } label: {
                Image(systemName: "gearshape")
            }
        }
    }
}
