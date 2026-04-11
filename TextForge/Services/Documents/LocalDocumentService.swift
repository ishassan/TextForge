import Foundation

enum DocumentAccessError: Error {
    case missingLibraryURL
    case missingBookmarkResolution
    case pdfExportUnavailable
}

/// Sensitive note bodies are stored on-device under the app support container for library documents.
/// External documents retain Files ownership and are accessed through security-scoped bookmarks.
actor LocalDocumentService: DocumentAccessing {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func loadDocument(id _: UUID) async throws -> TextDocument {
        throw DocumentAccessError.missingLibraryURL
    }

    func saveDocument(_ document: TextDocument) async throws {
        let url = try url(for: document)
        try ensureParentDirectory(for: url)
        let data = Data(document.body.utf8)
        try data.write(to: url, options: .atomic)
    }

    func exportHTML(for document: TextDocument) async throws -> Data {
        let escapedBody = document.body
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")

        let html = """
        <html>
        <head><meta charset="utf-8"></head>
        <body>
        <h1>\(document.title)</h1>
        <pre>\(escapedBody)</pre>
        </body>
        </html>
        """

        return Data(html.utf8)
    }

    func exportPDF(for document: TextDocument) async throws -> Data {
        _ = document
        throw DocumentAccessError.pdfExportUnavailable
    }

    private func url(for document: TextDocument) throws -> URL {
        switch document.storageKind {
        case let .library(relativePath):
            guard let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                throw DocumentAccessError.missingLibraryURL
            }
            return baseURL.appendingPathComponent("TextForge/Documents").appendingPathComponent(relativePath)
        case let .externalBookmark(bookmarkData):
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [.withoutUI],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            _ = url.startAccessingSecurityScopedResource()
            return url
        }
    }

    private func ensureParentDirectory(for url: URL) throws {
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    }
}
