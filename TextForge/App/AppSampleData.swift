import Foundation

enum AppSampleData {
    static func snippets() -> [Snippet] {
        [
            Snippet(
                content: "trim me\ntrim me\nswiftui",
                isPinned: true,
                tags: ["swift", "notes"],
                source: .manual
            ),
            Snippet(
                content: "https://developer.apple.com/documentation/swiftui",
                isFavorite: true,
                tags: ["reference"],
                source: .clipboard
            ),
            Snippet(
                content: #"{"name":"TextForge","platform":"iOS"}"#,
                tags: ["json", "sample"],
                source: .imported
            )
        ]
    }

    static func workflows() -> [Workflow] {
        [
            Workflow(
                name: "Cleanup Lines",
                steps: [
                    WorkflowStep(kind: .trimWhitespace),
                    WorkflowStep(kind: .uniqueLines),
                    WorkflowStep(kind: .sortLines)
                ]
            ),
            Workflow(
                name: "JSON Format",
                steps: [WorkflowStep(kind: .jsonPrettyPrint)]
            ),
            Workflow(
                name: "Link Harvest",
                steps: [WorkflowStep(kind: .extractLinks)]
            ),
            Workflow(
                name: "Script Action",
                steps: [WorkflowStep(kind: .scriptStub)]
            )
        ]
    }

    static func documents(using knowledgeService: KnowledgeParsing) -> [TextDocument] {
        let drafts: [TextDocument] = [
            TextDocument(
                title: "Welcome",
                filename: "welcome.md",
                storageKind: .library(relativePath: "welcome.md"),
                tags: ["intro", "markdown"],
                body: """
                # Welcome
                TextForge keeps notes local first.

                Link to [[Workflow Ideas]] and tag #ios.
                """
            ),
            TextDocument(
                title: "Workflow Ideas",
                filename: "workflow-ideas.md",
                storageKind: .library(relativePath: "workflow-ideas.md"),
                tags: ["automation"],
                body: """
                # Workflow Ideas
                - Trim whitespace
                - Extract links

                See [[Welcome]] for the app overview.
                """
            ),
            TextDocument(
                title: "Scratchpad",
                filename: "scratchpad.txt",
                storageKind: .library(relativePath: "scratchpad.txt"),
                tags: ["draft"],
                body: "Plain text draft for quick capture."
            )
        ]

        return drafts.map { draft in
            var copy = draft
            copy.knowledge = knowledgeService.parse(
                documentID: copy.id,
                title: copy.title,
                body: copy.body,
                corpus: drafts.filter { $0.id != copy.id }
            )
            return copy
        }
    }
}
