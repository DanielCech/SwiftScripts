import XCTest

import flattenTests

var tests = [XCTestCaseEntry]()
tests += flattenTests.allTests()
XCTMain(tests)
