import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(removeEmptyDirsTests.allTests),
        ]
    }
#endif
