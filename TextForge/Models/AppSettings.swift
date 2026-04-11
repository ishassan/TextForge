import Foundation

public struct AppSettings: Hashable, Codable, Sendable {
    public var clipboardMonitoringEnabled: Bool
    public var automaticClipboardSave: Bool
    public var faceIDLockEnabled: Bool
    public var iCloudSyncEnabled: Bool

    public init(
        clipboardMonitoringEnabled: Bool = true,
        automaticClipboardSave: Bool = false,
        faceIDLockEnabled: Bool = false,
        iCloudSyncEnabled: Bool = false
    ) {
        self.clipboardMonitoringEnabled = clipboardMonitoringEnabled
        self.automaticClipboardSave = automaticClipboardSave
        self.faceIDLockEnabled = faceIDLockEnabled
        self.iCloudSyncEnabled = iCloudSyncEnabled
    }
}
