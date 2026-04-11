import Combine
import Foundation

@MainActor
final class ActionsViewModel: ObservableObject {
    @Published var workflows: [Workflow] = []
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var context: ActionExecutionContext = .pastedText
    @Published var draftWorkflowName = ""

    private let coordinator: AppCoordinator
    private var cancellables: Set<AnyCancellable> = []

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.workflows = coordinator.workflows
        self.inputText = coordinator.currentActionInput
        self.outputText = coordinator.currentActionOutput

        coordinator.$workflows
            .receive(on: RunLoop.main)
            .sink { [weak self] workflows in
                self?.workflows = workflows
            }
            .store(in: &cancellables)

        coordinator.$currentActionInput
            .receive(on: RunLoop.main)
            .sink { [weak self] input in
                self?.inputText = input
            }
            .store(in: &cancellables)

        coordinator.$currentActionOutput
            .receive(on: RunLoop.main)
            .sink { [weak self] output in
                self?.outputText = output
            }
            .store(in: &cancellables)
    }

    func run(_ workflow: Workflow) {
        coordinator.run(workflow: workflow, input: inputText, context: context)
    }

    func duplicate(_ workflow: Workflow) {
        coordinator.duplicateWorkflow(workflow)
    }

    func delete(_ workflow: Workflow) {
        coordinator.deleteWorkflow(workflow)
    }

    func addWorkflow() {
        let name = draftWorkflowName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard name.isEmpty == false else { return }
        coordinator.addWorkflow(named: name)
        draftWorkflowName = ""
    }
}
