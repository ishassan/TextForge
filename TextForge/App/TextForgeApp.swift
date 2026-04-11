import SwiftData
import SwiftUI

@main
struct TextForgeApp: App {
    private let container: ModelContainer

    init() {
        self.container = ModelContainerFactory.makeSharedContainer()
    }

    var body: some Scene {
        WindowGroup {
            TextForgeRootScene(container: container)
        }
        .modelContainer(container)
    }
}

private struct TextForgeRootScene: View {
    let container: ModelContainer

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var coordinator: AppCoordinator

    init(container: ModelContainer) {
        self.container = container
        _coordinator = StateObject(wrappedValue: AppCoordinator(modelContext: container.mainContext))
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                RootTabView(coordinator: coordinator)
                    .environmentObject(coordinator)
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .tint(AppTheme.accent)
        .task {
            await coordinator.bootstrap()
            await coordinator.captureClipboard()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task {
                await coordinator.captureClipboard()
            }
        }
    }
}
