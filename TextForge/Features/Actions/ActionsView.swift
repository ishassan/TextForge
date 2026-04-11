import SwiftUI

struct ActionsView: View {
    @ObservedObject var viewModel: ActionsViewModel

    var body: some View {
        List {
            Section("Input") {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("Context", selection: $viewModel.context) {
                        ForEach(ActionExecutionContext.allCases, id: \.self) { context in
                            Text(context.rawValue).tag(context)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextEditor(text: $viewModel.inputText)
                        .frame(minHeight: 180)
                        .font(.system(.body, design: .monospaced))
                }
            }

            Section("Workflows") {
                ForEach(viewModel.workflows) { workflow in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(workflow.name)
                                .font(.headline)
                            Spacer()
                            Button("Run") {
                                viewModel.run(workflow)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }

                        Text(workflow.steps.map(\.kind.rawValue).joined(separator: " → "))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack {
                            Button("Duplicate") {
                                viewModel.duplicate(workflow)
                            }
                            .buttonStyle(.bordered)

                            Button("Delete", role: .destructive) {
                                viewModel.delete(workflow)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 6)
                }

                HStack {
                    TextField("New workflow name", text: $viewModel.draftWorkflowName)
                    Button("Add") {
                        viewModel.addWorkflow()
                    }
                }
            }

            Section("Output") {
                Text(viewModel.outputText.isEmpty ? "Run a workflow to see output." : viewModel.outputText)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("Actions")
    }
}
