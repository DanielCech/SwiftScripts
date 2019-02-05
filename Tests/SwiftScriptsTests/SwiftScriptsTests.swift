import XCTest
@testable import SwiftScripts

final class SwiftScriptsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftScripts().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
