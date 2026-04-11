import XCTest
@testable import TextForgeCore

final class ActionPipelineTests: XCTestCase {
    func testOrderedPipelineExecution() throws {
        let workflow = Workflow(
            name: "Normalize",
            steps: [
                WorkflowStep(kind: .trimWhitespace),
                WorkflowStep(kind: .uppercase),
                WorkflowStep(kind: .uniqueLines)
            ]
        )

        let result = try WorkflowEngine().execute(
            workflow: workflow,
            input: "  alpha \n beta\nalpha  ",
            context: .pastedText
        )

        XCTAssertEqual(result.output, "ALPHA\nBETA")
        XCTAssertEqual(result.stepCount, 3)
    }

    func testJSONFormattingAndRegexReplace() throws {
        let formatter = Workflow(name: "JSON", steps: [WorkflowStep(kind: .jsonPrettyPrint)])
        let formatted = try WorkflowEngine().execute(
            workflow: formatter,
            input: #"{"b":1,"a":2}"#,
            context: .snippet
        )

        XCTAssertTrue(formatted.output.contains(#""a" : 2"#) || formatted.output.contains(#""a": 2"#))

        let replace = Workflow(
            name: "Regex",
            steps: [
                WorkflowStep(
                    kind: .regexReplace,
                    configuration: ["pattern": "foo", "replacement": "bar"]
                )
            ]
        )

        let replaced = try WorkflowEngine().execute(
            workflow: replace,
            input: "foo fighters",
            context: .snippet
        )

        XCTAssertEqual(replaced.output, "bar fighters")
    }

    func testMarkdownAndLinkExtraction() throws {
        let html = try WorkflowEngine().execute(
            workflow: Workflow(name: "HTML", steps: [WorkflowStep(kind: .markdownToHTML)]),
            input: "# Title\nVisit **https://example.com**",
            context: .fullDocument
        )

        XCTAssertTrue(html.output.contains("<h1>Title</h1>"))

        let links = try WorkflowEngine().execute(
            workflow: Workflow(name: "Links", steps: [WorkflowStep(kind: .extractLinks)]),
            input: "Primary https://example.com/path and https://openai.com",
            context: .fullDocument
        )

        XCTAssertTrue(links.output.contains("https://example.com/path"))
        XCTAssertTrue(links.output.contains("https://openai.com"))
    }
}
