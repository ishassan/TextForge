import XCTest
@testable import TextForge

final class TextForgeSmokeTests: XCTestCase {
    func testWorkflowSampleExists() {
        XCTAssertFalse(AppSampleData.workflows().isEmpty)
    }
}
