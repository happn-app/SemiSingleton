import XCTest
@testable import SemiSingleton



class SemiSingletonTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		
		SimpleSemiSingleton.objectNumber = 0
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
	
	/* TODO: More tests... */
	
	
	/* Fill this array with all the tests to have Linux testing compatibility. */
	static var allTests = [
		("testSimpleSemiSingletonNonReallocation", testSimpleSemiSingletonNonReallocation),
	]
	
}
