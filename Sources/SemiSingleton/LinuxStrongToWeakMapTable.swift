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

import Foundation



/**
 Unsafe class (not fully tested, not fully documented).
 Do not use outside of the SemiSingleton project! */
class StrongToWeakMapTable<KeyType : Hashable, ObjectType : AnyObject> {
	
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
