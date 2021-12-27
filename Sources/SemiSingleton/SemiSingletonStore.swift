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
#if canImport(os)
import os.log
#endif

import RecursiveSyncDispatch



public protocol SemiSingleton : AnyObject {
	
	associatedtype SemiSingletonKey : Hashable
	associatedtype SemiSingletonAdditionalInitInfo
	
	/** Init a semi-singleton instance.
	 
	 You can use the additional info to help initializing your instance. The store
	 is given for informational purposes, mainly so you can instantiate other
	 semi-singletons from the same store.
	 
	 This init method cannot fail. If you want to create a semi-singleton whose
	 initialization can fail, you should conform to the
	 `SemiSingletonWithFallibleInit` protocol. */
	init(key: SemiSingletonKey, additionalInfo: SemiSingletonAdditionalInitInfo, store: SemiSingletonStore)
	
}

public protocol SemiSingletonWithFallibleInit : AnyObject {
	
	associatedtype SemiSingletonKey : Hashable
	associatedtype SemiSingletonAdditionalInitInfo
	
	/** Init a semi-singleton instance.
	 
	 You can use the additional info to help initializing your instance. The store
	 is given for informational purposes, mainly so you can instantiate other
	 semi-singletons from the same store.
	 
	 This init method cann fail. If you create a semi-singleton whose init cannot
	 fail, you should consider conforming to `SemiSingleton` instead. */
	init(key: SemiSingletonKey, additionalInfo: SemiSingletonAdditionalInitInfo, store: SemiSingletonStore) throws
	
}


public class SemiSingletonStore {
	
	public enum Error : Swift.Error {
		
		case invalidReentrantInit
		
	}
	
	public static let shared = SemiSingletonStore(forceClassInKeys: true)
	
	public let forceClassInKeys: Bool
	
	public init(forceClassInKeys fcik: Bool) {
		forceClassInKeys = fcik
	}
	
	/* ************
	   MARK: - Core
	   ************ */
	
	/* This method is duplicated below in a throwable version.
	 * One key difference is about re-entrant SemiSingleton init.
	 * In the throwable version, instantiating a semi-singleton with the same key as another semi-singleton being inited will result in the init throwing.
	 * In the non-throwable version you’ll get a fatal error. */
	public func semiSingleton<O : SemiSingleton>(forKey k: O.SemiSingletonKey, additionalInitInfo: O.SemiSingletonAdditionalInitInfo, isNew: inout Bool) -> O {
		return retrievingQueue.recursiveSync{
			let key = StoreKey(key: k, objectType: forceClassInKeys ? O.self : nil)
			guard ongoingInitKeys.insert(key).inserted else {fatalError("Asked to retrieve/init a semi-singleton with key \(k) while it is being inited (invalid reentrant allocation).")}
			defer {ongoingInitKeys.remove(key)}
			
			if let ro = registeredObjects.object(forKey: key) {
				/* An object has been registered for the given key */
				guard let o = ro as? O else {
					/* Invalid type found. We do not un-register the previous object, we simply return a non-singleton… */
#if canImport(os)
					if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
						SemiSingletonConfig.oslog.flatMap{ os_log("Asked to retrieve an object of type %{public}@ for key %@, but registered object is of type %{public}@. Creating a new, non-singleton’d object of required type. For reference, registered object is %@", log: $0, type: .error, String(describing: O.self), String(describing: k), String(describing: type(of: ro)), String(describing: ro)) }}
#endif
					SemiSingletonConfig.logger?.error("Asked to retrieve an object of type \(String(describing: O.self)) for key \(String(describing: k)), but registered object is of type \(String(describing: type(of: ro))). Creating a new, non-singleton’d object of required type. For reference, registered object is \(String(describing: ro))")
					assert(!forceClassInKeys)
					
					isNew = true
					return O(key: k, additionalInfo: additionalInitInfo, store: self)
				}
				
				isNew = false
				return o
			}
			
			isNew = true
			let o = O(key: k, additionalInfo: additionalInitInfo, store: self)
			registeredObjects.setObject(o, forKey: key)
			return o
		}
	}
	
	/* This method is duplicated above in a non-throwable version.
	 * One key difference is about re-entrant SemiSingleton init.
	 * In the throwable version, instantiating a semi-singleton with the same key as another semi-singleton being inited will result in the init throwing.
	 * In the non-throwable version you’ll get a fatal error. */
	public func semiSingleton<O : SemiSingletonWithFallibleInit>(forKey k: O.SemiSingletonKey, additionalInitInfo: O.SemiSingletonAdditionalInitInfo, isNew: inout Bool) throws -> O {
		return try retrievingQueue.recursiveSync{
			let key = StoreKey(key: k, objectType: forceClassInKeys ? O.self : nil)
			guard ongoingInitKeys.insert(key).inserted else {throw Error.invalidReentrantInit}
			defer {ongoingInitKeys.remove(key)}
			
			if let ro = registeredObjects.object(forKey: key) {
				/* An object has been registered for the given key */
				guard let o = ro as? O else {
					/* Invalid type found. We do not un-register the previous object, we simply return a non-singleton… */
#if canImport(os)
					if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
						SemiSingletonConfig.oslog.flatMap{ os_log("Asked to retrieve an object of type %{public}@ for key %@, but registered object is of type %{public}@. Creating a new, non-singleton’d object of required type. For reference, registered object is %@", log: $0, type: .error, String(describing: O.self), String(describing: k), String(describing: type(of: ro)), String(describing: ro)) }}
#endif
					SemiSingletonConfig.logger?.error("Asked to retrieve an object of type \(String(describing: O.self)) for key \(String(describing: k)), but registered object is of type \(String(describing: type(of: ro))). Creating a new, non-singleton’d object of required type. For reference, registered object is \(String(describing: ro))")
					assert(!forceClassInKeys)
					
					isNew = true
					return try O(key: k, additionalInfo: additionalInitInfo, store: self)
				}
				
				isNew = false
				return o
			}
			
			isNew = true
			let o = try O(key: k, additionalInfo: additionalInitInfo, store: self)
			registeredObjects.setObject(o, forKey: key)
			return o
		}
	}
	
	public func registeredSemiSingleton<K, O : SemiSingleton>(forKey k: K) -> O? where O.SemiSingletonKey == K {
		return retrievingQueue.sync{
			let key = StoreKey(key: k, objectType: forceClassInKeys ? O.self : nil)
			return registeredObjects.object(forKey: key) as? O
		}
	}
	
	public func registeredSemiSingleton<K, O : SemiSingletonWithFallibleInit>(forKey k: K) -> O? where O.SemiSingletonKey == K {
		return retrievingQueue.sync{
			let key = StoreKey(key: k, objectType: forceClassInKeys ? O.self : nil)
			return registeredObjects.object(forKey: key) as? O
		}
	}
	
	/* ********************
	   MARK: - Conveniences
	   ******************** */
	
	public func semiSingleton<O : SemiSingleton>(forKey k: O.SemiSingletonKey, additionalInitInfo: O.SemiSingletonAdditionalInitInfo) -> O {
		var isNew = false
		return semiSingleton(forKey: k, additionalInitInfo: additionalInitInfo, isNew: &isNew)
	}
	
	public func semiSingleton<O : SemiSingleton>(forKey k: O.SemiSingletonKey) -> O where O.SemiSingletonAdditionalInitInfo == Void {
		return semiSingleton(forKey: k, additionalInitInfo: ())
	}
	
	public func semiSingleton<O : SemiSingleton>(forKey k: O.SemiSingletonKey, isNew: inout Bool) -> O where O.SemiSingletonAdditionalInitInfo == Void {
		return semiSingleton(forKey: k, additionalInitInfo: (), isNew: &isNew)
	}
	
	public func semiSingleton<O : SemiSingletonWithFallibleInit>(forKey k: O.SemiSingletonKey, additionalInitInfo: O.SemiSingletonAdditionalInitInfo) throws -> O {
		var isNew = false
		return try semiSingleton(forKey: k, additionalInitInfo: additionalInitInfo, isNew: &isNew)
	}
	
	public func semiSingleton<O : SemiSingletonWithFallibleInit>(forKey k: O.SemiSingletonKey) throws -> O where O.SemiSingletonAdditionalInitInfo == Void {
		return try semiSingleton(forKey: k, additionalInitInfo: ())
	}
	
	public func semiSingleton<O : SemiSingletonWithFallibleInit>(forKey k: O.SemiSingletonKey, isNew: inout Bool) throws -> O where O.SemiSingletonAdditionalInitInfo == Void {
		return try semiSingleton(forKey: k, additionalInitInfo: (), isNew: &isNew)
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private class StoreKey : NSObject {
		
		let objectType: AnyObject.Type?
		let key: AnyHashable
		
		init(key k: AnyHashable, objectType ot: AnyObject.Type?) {
			key = k
			objectType = ot
		}
		
		override func isEqual(_ object: Any?) -> Bool {
			guard let object = object as? StoreKey else {return false}
			return object == self
		}
		
		override var hash: Int {
			return key.hashValue &+ (objectType.flatMap{ NSStringFromClass($0).hashValue } ?? 0)
		}
		
		static func ==(lhs: StoreKey, rhs: StoreKey) -> Bool {
			return lhs.objectType == rhs.objectType && lhs.key == rhs.key
		}
		
	}
	
	private var registeredObjects = StrongToWeakMapTable<StoreKey, AnyObject>()
	private let retrievingQueue = DispatchQueue(label: "SemiSingletonStore Object Retrieving Queue", qos: .userInitiated)
	
	private var ongoingInitKeys = Set<AnyHashable>()
	
}
