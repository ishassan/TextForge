import Foundation
import SwiftData

@Model
final class AppSettingsEntity {
    var clipboardMonitoringEnabled: Bool
    var automaticClipboardSave: Bool
    var faceIDLockEnabled: Bool
    var iCloudSyncEnabled: Bool

    init(settings: AppSettings) {
        self.clipboardMonitoringEnabled = settings.clipboardMonitoringEnabled
        self.automaticClipboardSave = settings.automaticClipboardSave
        self.faceIDLockEnabled = settings.faceIDLockEnabled
        self.iCloudSyncEnabled = settings.iCloudSyncEnabled
    }

    func toDomain() -> AppSettings {
        AppSettings(
            clipboardMonitoringEnabled: clipboardMonitoringEnabled,
            automaticClipboardSave: automaticClipboardSave,
            faceIDLockEnabled: faceIDLockEnabled,
            iCloudSyncEnabled: iCloudSyncEnabled
        )
    }

    func update(from settings: AppSettings) {
        clipboardMonitoringEnabled = settings.clipboardMonitoringEnabled
        automaticClipboardSave = settings.automaticClipboardSave
        faceIDLockEnabled = settings.faceIDLockEnabled
        iCloudSyncEnabled = settings.iCloudSyncEnabled
    }
}
