import XCTest

import directorizeTests

var tests = [XCTestCaseEntry]()
tests += directorizeTests.allTests()
XCTMain(tests)
