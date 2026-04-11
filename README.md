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

## Implementation Plan

### Phase 1

- Create the app shell with a `TabView` for Snippets, Editor, and Actions.
- Add onboarding, settings, global search, sample data, and a shared SwiftData container factory.
- Implement snippet persistence with `id`, `content`, `createdAt`, `updatedAt`, `isPinned`, `isFavorite`, `tags`, `source`, `preview`, and `plainText`.
- Add snippet list search, filtering, swipe actions, context actions, and tag browsing.
- Support privacy-aware clipboard capture on launch and foreground using `UIPasteboard.changeCount`.
- Isolate snippet queries behind a repository/protocol boundary so widget-facing storage stays replaceable.
- Add a widget target stub with placeholder-only data.

### Phase 2

- Model documents with a unified `TextDocument` record carrying `storageKind`, display metadata, open/recent state, and cached knowledge data.
- Keep internal notes as `.md` and `.txt` files under app-managed storage.
- Represent external files with security-scoped bookmarks.
- Build an iPhone-first document library with recents, tags, search, import/open actions, and a full-screen editor.
- Use a `UITextView` bridge for the write surface to support wrapping, selection-based actions, undo/redo, keyboard shortcuts, toolbar actions, in-document search, focus mode, and markdown-aware highlighting.
- Use `MarkdownUI` for live preview.
- Support `Write`, `Preview`, and `Both` modes, with a draggable vertical split in `Both`.
- Parse headings, tags, wikilinks, and backlinks on save/index events and surface that knowledge in the editor chrome.

### Phase 3

- Define a text action pipeline with built-in steps for uppercase, lowercase, trim whitespace, sort lines, unique lines, JSON pretty print, URL encode/decode, base64 encode/decode, regex replace, markdown to HTML, extract links, and word count/reading time.
- Implement reusable workflows with create, rename, duplicate, delete, reorder, and run flows.
- Allow workflow execution against editor selection, full document, current snippet, or pasted text.
- Include script actions in the data model and UI, but keep execution stubbed in v1.

### Phase 4

- Add a dedicated `SearchIndexService` actor backed by local SQLite FTS5 for fast global search across snippets and notes.
- Index title, body, tags, outgoing wikilinks, and derived keywords.
- Rank backlinks and related notes using normalized wikilink targets first, then shared tags and keyword overlap as tie-breakers.
- Support `.txt` and `.md` import, open-in-place via `UIDocumentPickerViewController`, safe save/export to `.txt`, `.md`, `.html`, and `.pdf`, plus share sheet integration.
- Export HTML through a markdown-to-HTML layer and render PDF using a hidden `WKWebView` print formatter.
- Use `NSFileCoordinator` and file version checks for conflict handling.

### Phase 5

- Add privacy settings for clipboard monitoring, automatic clipboard save, Face ID lock, and a disabled iCloud Sync toggle with explanatory copy.
- Document sensitive storage behavior near the storage services in code comments.
- Add an app-lock overlay with `LocalAuthentication`.
- Polish accessibility and presentation with accessible empty states, VoiceOver labels, restrained haptics, smooth transitions, accent themes, light/dark support, and Dynamic Type validation.

## Core Models And Interfaces

- `Snippet`, `SnippetTag`, `TextDocument`, `Workflow`, `WorkflowStep`, `AppSettings`, `SearchResult`, and `DocumentKnowledge` are the primary domain and persisted types.
- `TextDocument.storageKind` is the core abstraction for note ownership: `.library(relativePath)` for app-managed files and `.externalBookmark(bookmarkData)` for Files-based documents.
- `WorkflowStep.kind` covers built-ins plus `.scriptStub` for forward-compatible non-executable script steps.
- `ActionExecutionContext` is fixed to `.editorSelection`, `.fullDocument`, `.snippet`, and `.pastedText`.
- `ClipboardMonitoring`, `DocumentAccessing`, `SearchIndexing`, `KnowledgeParsing`, `SnippetStoring`, and `WorkflowExecuting` are the core service protocols.
- Search and backlink queries should flow through index and knowledge services rather than directly through SwiftData models.

## Test Plan

- `SnippetStorageTests`: CRUD, pin/favorite behavior, tag filtering, recent ordering, clipboard capture respecting settings, and manual save behavior when clipboard monitoring is off.
- `SearchIndexTests`: snippet/note indexing, incremental reindex on edit/delete, tag matches, title-vs-body ranking, and mixed global search results.
- `ActionPipelineTests`: ordered execution, whitespace and line transforms, JSON formatting success/failure, regex replace behavior, and markdown-to-HTML conversion.
- `WikiLinkParserTests`: wikilink normalization, duplicate link collapsing, heading extraction, backlink graph generation, and related-note scoring.
- `DocumentAccessTests`: internal note save/load, external bookmark resolution, conflict handling, and HTML/PDF export smoke coverage.

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
