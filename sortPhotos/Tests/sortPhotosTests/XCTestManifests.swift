import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(sortPhotosTests.allTests),
        ]
    }
#endif
