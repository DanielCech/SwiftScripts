import XCTest

import invokeTests

var tests = [XCTestCaseEntry]()
tests += invokeTests.allTests()
XCTMain(tests)
