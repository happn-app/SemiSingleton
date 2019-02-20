import XCTest

import SemiSingletonTests

var tests = [XCTestCaseEntry]()
tests += SemiSingletonTests.__allTests()

XCTMain(tests)
