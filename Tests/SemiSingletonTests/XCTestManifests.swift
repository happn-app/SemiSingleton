import XCTest

extension SemiSingletonTests {
    static let __allTests = [
        ("testInvalidReentrantSemiSingletonAllocation", testInvalidReentrantSemiSingletonAllocation),
        ("testReentrantOtherClassSemiSingletonAllocation", testReentrantOtherClassSemiSingletonAllocation),
        ("testReentrantSameClassSemiSingletonAllocation", testReentrantSameClassSemiSingletonAllocation),
        ("testReentrantThroughHopSemiSingletonAllocation", testReentrantThroughHopSemiSingletonAllocation),
        ("testSimpleSemiSingletonNonReallocation", testSimpleSemiSingletonNonReallocation),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SemiSingletonTests.__allTests),
    ]
}
#endif
