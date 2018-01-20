/*
 * SimpleSemiSingleton.swift
 * SemiSingleton
 *
 * Created by François Lamboley on 1/20/18.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation

import SemiSingleton



class SimpleSemiSingleton : SemiSingleton {
	
	static var objectNumber = 0
	
	typealias SemiSingletonKey = String
	
	let key: String
	let objectNumber: Int
	
	required init(key k: String) {
		SimpleSemiSingleton.objectNumber += 1
		objectNumber = SimpleSemiSingleton.objectNumber
		key = k
	}
	
}
