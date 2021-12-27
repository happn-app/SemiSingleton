/*
Copyright 2019 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import XCTest
@testable import SemiSingleton



class SemiSingletonTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		
		SimpleSemiSingleton.objectNumber = 0
		ReentrantSemiSingletonInit.objectNumber = 0
	}
	
	func testSimpleSemiSingletonNonReallocation() {
		let key = #function
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		let s1: SimpleSemiSingleton = semiSingletonStore.semiSingleton(forKey: key)
		let s2: SimpleSemiSingleton = semiSingletonStore.semiSingleton(forKey: key)
		XCTAssertEqual(s1.key, key)
		XCTAssertEqual(s2.key, key)
		XCTAssertEqual(s1.objectNumber, s2.objectNumber)
		XCTAssertEqual(SimpleSemiSingleton.objectNumber, 1)
	}
	
	func testSimpleSemiSingletonDeallocationAutoreleasePool() {
#if !canImport(ObjectiveC)
		NSLog("Test unavailable on this OS.")
#else
		let key = #function
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as SimpleSemiSingleton? == nil)
		autoreleasepool{
			let s: SimpleSemiSingleton = semiSingletonStore.semiSingleton(forKey: key)
			XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as SimpleSemiSingleton? === s)
			XCTAssertEqual(s.key, key)
		}
		XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as SimpleSemiSingleton? == nil)
#endif
	}
	
	func testSimpleSemiSingletonDeallocationAsyncDispatch() {
		guard #available(OSX 10.12, tvOS 10.0, iOS 10.0, *) else {
			NSLog("Test unavailable on this OS.")
			return
		}
		
		let key = #function
		var checkDone = false
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		let queue = DispatchQueue(label: "TestQueue", autoreleaseFrequency: .workItem)
		
		XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as SimpleSemiSingleton? == nil)
		queue.async{
			let s: SimpleSemiSingleton = semiSingletonStore.semiSingleton(forKey: key)
			XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as SimpleSemiSingleton? === s)
			XCTAssertEqual(s.key, key)
		}
		queue.async{
			XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as SimpleSemiSingleton? == nil)
			checkDone = true
		}
		
		/* XCTWaiter not available on Linux… yet? */
		while !checkDone {Thread.sleep(until: Date(timeIntervalSinceNow: 0.01))}
	}
	
	func testReentrantOtherClassSemiSingletonAllocation() throws {
		let key = #function
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		let s: ReentrantSemiSingletonInit = try semiSingletonStore.semiSingleton(forKey: key, additionalInitInfo: .otherClass)
		XCTAssertEqual(s.key, key)
		XCTAssertEqual(SimpleSemiSingleton.objectNumber, 1)
		XCTAssertEqual(ReentrantSemiSingletonInit.objectNumber, 1)
	}
	
	func testReentrantSameClassSemiSingletonAllocation() throws {
		let key = #function
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		let s: ReentrantSemiSingletonInit = try semiSingletonStore.semiSingleton(forKey: key, additionalInitInfo: .sameClassOtherKey)
		XCTAssertEqual(s.key, key)
		XCTAssertEqual(SimpleSemiSingleton.objectNumber, 0)
		XCTAssertEqual(ReentrantSemiSingletonInit.objectNumber, 2)
	}
	
	func testInvalidReentrantSemiSingletonAllocation() throws {
		let key = #function
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		XCTAssertThrowsError(try semiSingletonStore.semiSingleton(forKey: key, additionalInitInfo: .sameClassSameId) as ReentrantSemiSingletonInit)
	}
	
	func testReentrantThroughHopSemiSingletonAllocation() throws {
		let key = #function
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		let semiSingletonStore2 = SemiSingletonStore(forceClassInKeys: true)
		let s: ReentrantSemiSingletonInit = try semiSingletonStore.semiSingleton(forKey: key, additionalInitInfo: .sameClassOtherStoreThenSameStoreOtherKey(store: semiSingletonStore2))
		XCTAssertEqual(s.key, key)
		XCTAssertEqual(SimpleSemiSingleton.objectNumber, 0)
		XCTAssertEqual(ReentrantSemiSingletonInit.objectNumber, 3)
	}
	
	func testActorDeallocationSemiSingleton() {
#if !canImport(ObjectiveC)
		NSLog("Test unavailable on this OS.")
#else
		let key = #function
		let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
		XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as ActorSemiSingleton? == nil)
		autoreleasepool{
			let s: ActorSemiSingleton = semiSingletonStore.semiSingleton(forKey: key)
			XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as ActorSemiSingleton? === s)
			XCTAssertEqual(s.key, key)
		}
		XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as ActorSemiSingleton? == nil)
		XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as ActorSemiSingleton? == nil)
		XCTAssert(semiSingletonStore.registeredSemiSingleton(forKey: key) as ActorSemiSingleton? == nil)
#endif
	}
	
	/* TODO: More tests... */
	
}
