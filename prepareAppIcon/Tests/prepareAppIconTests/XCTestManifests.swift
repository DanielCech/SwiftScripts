import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(prepareAppIconTests.allTests),
        ]
    }
#endif
