import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(stylesheetHelperTests.allTests),
        ]
    }
#endif
