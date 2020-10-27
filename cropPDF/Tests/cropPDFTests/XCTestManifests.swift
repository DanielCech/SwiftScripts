import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(cropPDFTests.allTests),
        ]
    }
#endif
