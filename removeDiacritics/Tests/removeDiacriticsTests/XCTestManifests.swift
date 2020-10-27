import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(removeDiacriticsTests.allTests),
        ]
    }
#endif
