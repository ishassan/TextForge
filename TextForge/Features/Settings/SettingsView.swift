import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        List {
            Section("Privacy") {
                Toggle("Monitor Clipboard", isOn: binding(\.clipboardMonitoringEnabled))
                Toggle("Automatically Save Clipboard", isOn: binding(\.automaticClipboardSave))
                Toggle("Face ID Lock", isOn: binding(\.faceIDLockEnabled))
            }

            Section("Sync") {
                Toggle("iCloud Sync", isOn: .constant(false))
                    .disabled(true)
                Text("v1 is intentionally local-only. Sync remains visible so the storage model can evolve without changing the settings surface later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private func binding(_ keyPath: WritableKeyPath<AppSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { coordinator.settings[keyPath: keyPath] },
            set: { newValue in
                coordinator.settings[keyPath: keyPath] = newValue
                coordinator.saveSettings()
            }
        )
    }
}
