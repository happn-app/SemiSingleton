/*
 * ReentrantSemiSingletonInit.swift
 * SemiSingleton
 *
 * Created by François Lamboley on 30/10/2018.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation

import SemiSingleton



class ReentrantSemiSingletonInit : SemiSingletonWithFallibleInit {
	
	enum InitType {
		
		case otherClass
		case sameClassOtherKey
		case sameClassSameId /* This init type is (purposefully) invalid. */
		case sameClassOtherStoreThenSameStoreOtherKey(store: SemiSingletonStore)
		
		case noNewAllocation
		case sameClassOtherStoreOtherKey(store: SemiSingletonStore)
		
	}
	
	static var objectNumber = 0
	
	typealias SemiSingletonKey = String
	typealias SemiSingletonAdditionalInitInfo = InitType
	
	let key: String
	let objectNumber: Int
	
	required init(key k: String, additionalInfo: InitType, store: SemiSingletonStore) throws {
		ReentrantSemiSingletonInit.objectNumber += 1
		objectNumber = ReentrantSemiSingletonInit.objectNumber
		key = k
		
		let otherKey = key + " other key"
		switch additionalInfo {
		case .noNewAllocation: ()
		case .otherClass:        _ =     store.semiSingleton(forKey: key) as SimpleSemiSingleton
		case .sameClassOtherKey: _ = try store.semiSingleton(forKey: otherKey, additionalInitInfo: .noNewAllocation) as ReentrantSemiSingletonInit
		case .sameClassSameId:   _ = try store.semiSingleton(forKey: key,      additionalInitInfo: .noNewAllocation) as ReentrantSemiSingletonInit
		case .sameClassOtherStoreOtherKey(store: let s):              _ = try s.semiSingleton(forKey: otherKey, additionalInitInfo: .noNewAllocation)                           as ReentrantSemiSingletonInit
		case .sameClassOtherStoreThenSameStoreOtherKey(store: let s): _ = try s.semiSingleton(forKey: otherKey, additionalInitInfo: .sameClassOtherStoreOtherKey(store: store)) as ReentrantSemiSingletonInit
		}
	}
	
}
