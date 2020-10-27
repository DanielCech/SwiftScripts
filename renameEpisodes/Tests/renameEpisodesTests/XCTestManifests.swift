import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(renameEpisodesTests.allTests),
        ]
    }
#endif
