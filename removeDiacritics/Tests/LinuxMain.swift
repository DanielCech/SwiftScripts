import XCTest

import removeDiacriticsTests

var tests = [XCTestCaseEntry]()
tests += removeDiacriticsTests.allTests()
XCTMain(tests)
