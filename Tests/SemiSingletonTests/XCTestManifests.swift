import XCTest

extension SemiSingletonTests {
    static let __allTests = [
        ("testInvalidReentrantSemiSingletonAllocation", testInvalidReentrantSemiSingletonAllocation),
        ("testReentrantOtherClassSemiSingletonAllocation", testReentrantOtherClassSemiSingletonAllocation),
        ("testReentrantSameClassSemiSingletonAllocation", testReentrantSameClassSemiSingletonAllocation),
        ("testReentrantThroughHopSemiSingletonAllocation", testReentrantThroughHopSemiSingletonAllocation),
        ("testSimpleSemiSingletonDeallocationAsyncDispatch", testSimpleSemiSingletonDeallocationAsyncDispatch),
        ("testSimpleSemiSingletonDeallocationAutoreleasePool", testSimpleSemiSingletonDeallocationAutoreleasePool),
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
