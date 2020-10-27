import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(reduceVideoTests.allTests),
        ]
    }
#endif
