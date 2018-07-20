/*
 * LinuxStrongToWeakMapTable.swift
 * SemiSingleton
 *
 * Created by François Lamboley on 20/07/2018.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation



#if os(Linux)

/** Unsafe class (not fully tested, not fully documented). Do not use outside of
the SemiSingleton project! */
class LinuxStrongToWeakMapTable<KeyType : Hashable, ObjectType : AnyObject> {
	
	func object(forKey key: KeyType) -> ObjectType? {
		guard let w = store[key] else {return nil}
		guard let r = w.element else {
			store.removeValue(forKey: key)
			return nil
		}
		return r
	}
	
	func setObject(_ object: ObjectType?, forKey key: KeyType) {
		guard let o = object else {
			store.removeValue(forKey: key)
			return
		}
		store[key] = WeakElementBox(e: o)
	}
	
	private class WeakElementBox<ElementType : AnyObject> {
		
		weak var element: ElementType?
		
		init(e: ElementType) {
			element = e
		}
		
	}
	
	private var store = [KeyType: WeakElementBox<ObjectType>]()
	
}

#endif
