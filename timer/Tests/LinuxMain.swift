import XCTest

import timerTests

var tests = [XCTestCaseEntry]()
tests += timerTests.allTests()
XCTMain(tests)
