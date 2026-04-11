import Foundation

public enum WorkflowStepKind: String, Codable, CaseIterable, Sendable {
    case uppercase
    case lowercase
    case trimWhitespace
    case sortLines
    case uniqueLines
    case jsonPrettyPrint
    case urlEncode
    case urlDecode
    case base64Encode
    case base64Decode
    case regexReplace
    case markdownToHTML
    case extractLinks
    case wordStats
    case scriptStub
}

public struct WorkflowStep: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var kind: WorkflowStepKind
    public var configuration: [String: String]
    public var options: [String: Bool]

    public init(
        id: UUID = UUID(),
        kind: WorkflowStepKind,
        configuration: [String: String] = [:],
        options: [String: Bool] = [:]
    ) {
        self.id = id
        self.kind = kind
        self.configuration = configuration
        self.options = options
    }
}

public struct Workflow: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var steps: [WorkflowStep]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        steps: [WorkflowStep],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.steps = steps
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum ActionExecutionContext: String, Codable, CaseIterable, Sendable {
    case editorSelection
    case fullDocument
    case snippet
    case pastedText
}

public struct WorkflowExecutionResult: Hashable, Sendable {
    public let output: String
    public let context: ActionExecutionContext
    public let stepCount: Int

    public init(output: String, context: ActionExecutionContext, stepCount: Int) {
        self.output = output
        self.context = context
        self.stepCount = stepCount
    }
}
