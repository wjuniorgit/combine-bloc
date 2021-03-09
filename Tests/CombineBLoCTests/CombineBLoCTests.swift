import XCTest
@testable import CombineBLoC

final class CombineBLoCTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CombineBLoC().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
