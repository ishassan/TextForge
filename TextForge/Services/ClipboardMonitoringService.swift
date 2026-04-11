import Foundation
import UIKit

actor ClipboardMonitoringService: ClipboardMonitoring {
    private var lastChangeCount: Int?

    func captureIfNeeded(
        currentChangeCount: Int,
        settings: AppSettings,
        stringProvider: @escaping @Sendable () -> String?
    ) async -> Snippet? {
        guard settings.clipboardMonitoringEnabled else {
            lastChangeCount = currentChangeCount
            return nil
        }
        guard lastChangeCount != currentChangeCount else { return nil }
        lastChangeCount = currentChangeCount

        guard let value = stringProvider()?.trimmingCharacters(in: .whitespacesAndNewlines), value.isEmpty == false else {
            return nil
        }

        return Snippet(content: value, source: .clipboard)
    }
}
