import Foundation
import XCTest
@testable import TextForgeCore

final class SnippetStorageTests: XCTestCase {
    func testPinFavoriteFilterAndOrdering() async {
        let older = Snippet(
            content: "alpha",
            createdAt: Date(timeIntervalSince1970: 10),
            updatedAt: Date(timeIntervalSince1970: 10),
            tags: ["ios"]
        )
        let newer = Snippet(
            content: "beta",
            createdAt: Date(timeIntervalSince1970: 20),
            updatedAt: Date(timeIntervalSince1970: 20),
            tags: ["swift"]
        )

        let store = InMemorySnippetStore(snippets: [older, newer])
        await store.togglePinned(id: older.id)
        await store.toggleFavorite(id: newer.id)

        let ordered = await store.allSnippets()
        XCTAssertEqual(ordered.first?.id, older.id)

        let filtered = await store.recentSnippets(matching: nil, tag: "swift")
        XCTAssertEqual(filtered.map(\.id), [newer.id])
    }
}
