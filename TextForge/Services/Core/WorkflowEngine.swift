import Foundation

public enum WorkflowExecutionError: Error, LocalizedError, Sendable {
    case invalidJSON
    case invalidBase64
    case invalidURLDecoding
    case invalidRegularExpression
    case scriptingUnavailable

    public var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return "The input is not valid JSON."
        case .invalidBase64:
            return "The input is not valid base64."
        case .invalidURLDecoding:
            return "The input could not be URL-decoded."
        case .invalidRegularExpression:
            return "The regular expression configuration is invalid."
        case .scriptingUnavailable:
            return "Script actions are included for compatibility but are not executable in v1."
        }
    }
}

public struct WorkflowEngine: WorkflowExecuting {
    public init() {}

    public func execute(workflow: Workflow, input: String, context: ActionExecutionContext) throws -> WorkflowExecutionResult {
        let output = try workflow.steps.reduce(input) { partialResult, step in
            try execute(step: step, input: partialResult)
        }
        return WorkflowExecutionResult(output: output, context: context, stepCount: workflow.steps.count)
    }

    private func execute(step: WorkflowStep, input: String) throws -> String {
        switch step.kind {
        case .uppercase:
            return input.uppercased()
        case .lowercase:
            return input.lowercased()
        case .trimWhitespace:
            return input
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        case .sortLines:
            return input
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map(String.init)
                .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
                .joined(separator: "\n")
        case .uniqueLines:
            var seen = Set<String>()
            return input
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map(String.init)
                .filter { seen.insert($0).inserted }
                .joined(separator: "\n")
        case .jsonPrettyPrint:
            return try prettyPrintedJSON(from: input)
        case .urlEncode:
            return input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? input
        case .urlDecode:
            guard let decoded = input.removingPercentEncoding else {
                throw WorkflowExecutionError.invalidURLDecoding
            }
            return decoded
        case .base64Encode:
            return Data(input.utf8).base64EncodedString()
        case .base64Decode:
            guard let data = Data(base64Encoded: input), let decoded = String(data: data, encoding: .utf8) else {
                throw WorkflowExecutionError.invalidBase64
            }
            return decoded
        case .regexReplace:
            return try regexReplace(step: step, input: input)
        case .markdownToHTML:
            return markdownToHTML(input)
        case .extractLinks:
            return extractLinks(from: input).joined(separator: "\n")
        case .wordStats:
            return wordStats(for: input)
        case .scriptStub:
            throw WorkflowExecutionError.scriptingUnavailable
        }
    }

    private func prettyPrintedJSON(from input: String) throws -> String {
        guard let data = input.data(using: .utf8) else {
            throw WorkflowExecutionError.invalidJSON
        }
        let object = try JSONSerialization.jsonObject(with: data)
        let formatted = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        guard let output = String(data: formatted, encoding: .utf8) else {
            throw WorkflowExecutionError.invalidJSON
        }
        return output
    }

    private func regexReplace(step: WorkflowStep, input: String) throws -> String {
        guard let pattern = step.configuration["pattern"] else {
            throw WorkflowExecutionError.invalidRegularExpression
        }
        let replacement = step.configuration["replacement"] ?? ""
        let caseInsensitive = step.options["caseInsensitive"] ?? false

        let regex = try NSRegularExpression(pattern: pattern, options: caseInsensitive ? [.caseInsensitive] : [])
        let range = NSRange(input.startIndex..<input.endIndex, in: input)
        return regex.stringByReplacingMatches(in: input, range: range, withTemplate: replacement)
    }

    private func markdownToHTML(_ input: String) -> String {
        let htmlBody = input
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line -> String in
                if line.hasPrefix("# ") {
                    return "<h1>\(escapeHTML(String(line.dropFirst(2))))</h1>"
                }
                if line.hasPrefix("## ") {
                    return "<h2>\(escapeHTML(String(line.dropFirst(3))))</h2>"
                }
                if line.isEmpty {
                    return ""
                }
                return "<p>\(inlineMarkdownToHTML(escapeHTML(String(line))))</p>"
            }
            .joined(separator: "\n")

        return """
        <html>
        <body>
        \(htmlBody)
        </body>
        </html>
        """
    }

    private func inlineMarkdownToHTML(_ line: String) -> String {
        line
            .replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
            .replacingOccurrences(of: #"_(.+?)_"#, with: "<em>$1</em>", options: .regularExpression)
    }

    private func escapeHTML(_ input: String) -> String {
        input
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private func extractLinks(from input: String) -> [String] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(input.startIndex..<input.endIndex, in: input)
        let matches = detector?.matches(in: input, range: range) ?? []
        return matches.compactMap(\.url?.absoluteString)
    }

    private func wordStats(for input: String) -> String {
        let words = input
            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .filter { $0.isEmpty == false }
        let wordCount = words.count
        let readingTimeMinutes = max(1, Int(ceil(Double(wordCount) / 200.0)))
        return "Words: \(wordCount)\nReading time: \(readingTimeMinutes) min"
    }
}
