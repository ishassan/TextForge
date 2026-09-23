# TextForge

TextForge is an iPhone-first SwiftUI app for working with snippets, notes, and reusable text actions. It targets iOS 17+, is generated with XcodeGen, and uses clean MVVM with service actors and protocol-driven core logic.

## Summary

- Build TextForge as a privacy-first, local-first app with no analytics and no network dependency for core features.
- Use SwiftData for app metadata and settings, while keeping note contents file-based for robust import, export, and open-in-place workflows.
- Treat internal library notes and external Files documents as first-class peers through a shared editor, search, and workflow surface.
- Keep the dependency set small and deliberate. The current project uses `MarkdownUI` for preview, with room for richer markdown parsing and export layers as those phases are completed.

## Repo Structure

```text
.
├── project.yml
├── Package.swift
├── README.md
├── TextForge/
│   ├── App/
│   ├── DesignSystem/
│   ├── Models/
│   ├── Persistence/
│   ├── Services/
│   ├── Features/
│   │   ├── Snippets/
│   │   ├── Editor/
│   │   ├── Actions/
│   │   ├── Search/
│   │   ├── Settings/
│   │   └── Onboarding/
│   └── WidgetsStub/
└── TextForgeTests/
```

## Core Models And Interfaces

- `Snippet`, `SnippetTag`, `TextDocument`, `Workflow`, `WorkflowStep`, `AppSettings`, `SearchResult`, and `DocumentKnowledge` are the primary domain and persisted types.
- `TextDocument.storageKind` is the core abstraction for note ownership: `.library(relativePath)` for app-managed files and `.externalBookmark(bookmarkData)` for Files-based documents.
- `WorkflowStep.kind` covers built-ins plus `.scriptStub` for forward-compatible non-executable script steps.
- `ActionExecutionContext` is fixed to `.editorSelection`, `.fullDocument`, `.snippet`, and `.pastedText`.
- `ClipboardMonitoring`, `DocumentAccessing`, `SearchIndexing`, `KnowledgeParsing`, `SnippetStoring`, and `WorkflowExecuting` are the core service protocols.
- Search and backlink queries should flow through index and knowledge services rather than directly through SwiftData models.

## Assumptions And Defaults

- v1 is intentionally local-only. The iCloud Sync setting is visible but disabled.
- Internal notes and external Files documents are equal citizens in the product model.
- Script actions are schema-complete but intentionally non-executable in v1.
- The project is generated from `project.yml`, not maintained as a hand-authored `.xcodeproj`.

## Local Commands

```bash
xcodegen generate
swift run TextForgeCoreSmoke
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project TextForge.xcodeproj -scheme TextForge -destination 'platform=iOS Simulator,name=iPhone 17' build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project TextForge.xcodeproj -scheme TextForge -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## License

TextForge's original source code and project files are licensed under the MIT License. See [LICENSE](LICENSE). Third-party dependencies, including MarkdownUI, remain subject to their own licenses.
