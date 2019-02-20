import XCTest
@testable import SemiSingleton



class SemiSingletonTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		
		SimpleSemiSingleton.objectNumber = 0
		ReentrantSemiSingletonInit.objectNumber = 0
	}
	
	func testSimpleSemiSingletonNonReallocation() {
		let key = "hello"
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		let s1: SimpleSemiSingleton = semiSingletonStore.semiSingleton(forKey: key)
		let s2: SimpleSemiSingleton = semiSingletonStore.semiSingleton(forKey: key)
		XCTAssertEqual(s1.key, key)
		XCTAssertEqual(s2.key, key)
		XCTAssertEqual(s1.objectNumber, s2.objectNumber)
		XCTAssertEqual(SimpleSemiSingleton.objectNumber, 1)
	}
	
	func testReentrantOtherClassSemiSingletonAllocation() throws {
		let key = "hello"
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		let s: ReentrantSemiSingletonInit = try semiSingletonStore.semiSingleton(forKey: key, additionalInitInfo: .otherClass)
		XCTAssertEqual(s.key, key)
		XCTAssertEqual(SimpleSemiSingleton.objectNumber, 1)
		XCTAssertEqual(ReentrantSemiSingletonInit.objectNumber, 1)
	}
	
	func testReentrantSameClassSemiSingletonAllocation() throws {
		let key = "hello"
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		let s: ReentrantSemiSingletonInit = try semiSingletonStore.semiSingleton(forKey: key, additionalInitInfo: .sameClassOtherKey)
		XCTAssertEqual(s.key, key)
		XCTAssertEqual(SimpleSemiSingleton.objectNumber, 0)
		XCTAssertEqual(ReentrantSemiSingletonInit.objectNumber, 2)
	}
	
	func testInvalidReentrantSemiSingletonAllocation() throws {
		let key = "hello"
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		XCTAssertThrowsError(try semiSingletonStore.semiSingleton(forKey: key, additionalInitInfo: .sameClassSameId) as ReentrantSemiSingletonInit)
	}
	
	func testReentrantThroughHopSemiSingletonAllocation() throws {
		let key = "hello"
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		let semiSingletonStore2 = SemiSingletonStore(forceClassInKeys: true)
		let s: ReentrantSemiSingletonInit = try semiSingletonStore.semiSingleton(forKey: key, additionalInitInfo: .sameClassOtherStoreThenSameStoreOtherKey(store: semiSingletonStore2))
		XCTAssertEqual(s.key, key)
		XCTAssertEqual(SimpleSemiSingleton.objectNumber, 0)
		XCTAssertEqual(ReentrantSemiSingletonInit.objectNumber, 3)
	}
	
	/* TODO: More tests... */
	
}
