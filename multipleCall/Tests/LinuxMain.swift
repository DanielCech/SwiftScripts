import XCTest

import multipleCallTests

var tests = [XCTestCaseEntry]()
tests += multipleCallTests.allTests()
XCTMain(tests)
