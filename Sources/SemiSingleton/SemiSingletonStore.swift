/*
 * SemiSingletonStore.swift
 * SemiSingleton
 *
 * Created by François Lamboley on 1/8/18.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation
#if canImport(os)
	import os.log
#endif

#if canImport(DummyLinuxOSLog)
	import DummyLinuxOSLog
#endif



public protocol SemiSingleton : class {
	
	associatedtype SemiSingletonKey : Hashable
	
	init(key: SemiSingletonKey)
	
}

public protocol SemiSingletonWithFallibleInit : class {
	
	associatedtype SemiSingletonKey : Hashable
	
	init(key: SemiSingletonKey) throws
	
}


public class SemiSingletonStore {
	
	public static let shared = SemiSingletonStore(forceClassInKeys: true)
	
	public let forceClassInKeys: Bool
	
	public init(forceClassInKeys fcik: Bool) {
		forceClassInKeys = fcik
	}
	
	public func semiSingleton<K, O : SemiSingleton>(forKey k: K) -> O where O.SemiSingletonKey == K {
		var isNew = false
		return semiSingleton(forKey: k, isNew: &isNew)
	}
	
	/* This method is duplicated below */
	public func semiSingleton<K, O : SemiSingleton>(forKey k: K, isNew: inout Bool) -> O where O.SemiSingletonKey == K {
		return retrievingQueue.sync{
			let key = StoreKey(key: k, objectType: forceClassInKeys ? O.self : nil)
			if let ro = registeredObjects.object(forKey: key) {
				/* An object has been registered for the given key */
				guard let o = ro as? O else {
					/* Invalid type found. We do not un-register the previous object,
					 * we simply return a non-singleton... */
					#if !os(Linux)
						if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Asked to retrieve an object of type %{public}@ for key %@, but registered object is of type %{public}@. Creating a new, non-singleton’d object of required type. For reference, registered object is %@", log: $0, type: .error, String(describing: O.self), String(describing: k), String(describing: type(of: ro)), String(describing: ro)) }}
						else                                                          {NSLog("***** Asked to retrieve an object of type %@ for key %@, but registered object is of type %@. Creating a new, non-singleton’d object of required type. For reference, registered object is %@", String(describing: O.self), String(describing: k), String(describing: type(of: ro)), String(describing: ro))}
					#else
						NSLogString("***** Asked to retrieve an object of type \(String(describing: O.self)) for key \(String(describing: k)), but registered object is of type \(String(describing: type(of: ro))). Creating a new, non-singleton’d object of required type. For reference, registered object is \(String(describing: ro))")
					#endif
					assert(!forceClassInKeys)
					
					isNew = true
					return O(key: k)
				}
				
				isNew = false
				return o
			}
			
			isNew = true
			let o = O(key: k)
			registeredObjects.setObject(o, forKey: key)
			return o
		}
	}
	
	public func semiSingleton<K, O : SemiSingletonWithFallibleInit>(forKey k: K) throws -> O where O.SemiSingletonKey == K {
		var isNew = false
		return try semiSingleton(forKey: k, isNew: &isNew)
	}
	
	/* This method is duplicated above */
	public func semiSingleton<K, O : SemiSingletonWithFallibleInit>(forKey k: K, isNew: inout Bool) throws -> O where O.SemiSingletonKey == K {
		return try retrievingQueue.sync{
			let key = StoreKey(key: k, objectType: forceClassInKeys ? O.self : nil)
			if let ro = registeredObjects.object(forKey: key) {
				/* An object has been registered for the given key */
				guard let o = ro as? O else {
					/* Invalid type found. We do not un-register the previous object,
					 * we simply return a non-singleton... */
					#if !os(Linux)
						if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Asked to retrieve an object of type %{public}@ for key %@, but registered object is of type %{public}@. Creating a new, non-singleton’d object of required type. For reference, registered object is %@", log: $0, type: .error, String(describing: O.self), String(describing: k), String(describing: type(of: ro)), String(describing: ro)) }}
						else                                                          {NSLog("***** Asked to retrieve an object of type %@ for key %@, but registered object is of type %@. Creating a new, non-singleton’d object of required type. For reference, registered object is %@", String(describing: O.self), String(describing: k), String(describing: type(of: ro)), String(describing: ro))}
					#else
						NSLogString("***** Asked to retrieve an object of type \(String(describing: O.self)) for key \(String(describing: k)), but registered object is of type \(String(describing: type(of: ro))). Creating a new, non-singleton’d object of required type. For reference, registered object is \(String(describing: ro))")
					#endif
					assert(!forceClassInKeys)
					
					isNew = true
					return try O(key: k)
				}
				
				isNew = false
				return o
			}
			
			isNew = true
			let o = try O(key: k)
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
			return hashValue
		}
		
		override var hashValue: Int {
			return key.hashValue &+ (objectType.flatMap{ NSStringFromClass($0).hashValue } ?? 0)
		}
		
		static func ==(lhs: StoreKey, rhs: StoreKey) -> Bool {
			return lhs.objectType == rhs.objectType && lhs.key == rhs.key
		}
		
	}
	
	#if !os(Linux)
		private var registeredObjects = NSMapTable<StoreKey, AnyObject>.strongToWeakObjects()
	#else
		private var registeredObjects = LinuxStrongToWeakMapTable<StoreKey, AnyObject>()
	#endif
	private let retrievingQueue = DispatchQueue(label: "SemiSingletonStore Object Retrieving Queue", qos: .userInitiated)
	
}
