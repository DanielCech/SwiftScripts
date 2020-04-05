import XCTest

import tagTests

var tests = [XCTestCaseEntry]()
tests += tagTests.allTests()
XCTMain(tests)
