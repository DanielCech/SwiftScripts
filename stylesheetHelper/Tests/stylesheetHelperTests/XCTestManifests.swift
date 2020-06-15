import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(stylesheetHelperTests.allTests),
    ]
}
#endif
