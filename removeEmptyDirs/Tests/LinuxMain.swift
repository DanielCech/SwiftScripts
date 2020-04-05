import XCTest

import removeEmptyDirsTests

var tests = [XCTestCaseEntry]()
tests += removeEmptyDirsTests.allTests()
XCTMain(tests)
