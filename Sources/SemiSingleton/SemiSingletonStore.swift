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

#if !canImport(os) && canImport(DummyLinuxOSLog)
	import DummyLinuxOSLog
#endif



public protocol SemiSingleton : class {
	
	associatedtype SemiSingletonKey : Hashable
	associatedtype SemiSingletonAdditionalInitInfo
	
	init(key: SemiSingletonKey, additionalInfo: SemiSingletonAdditionalInitInfo)
	
}

public protocol SemiSingletonWithFallibleInit : class {
	
	associatedtype SemiSingletonKey : Hashable
	associatedtype SemiSingletonAdditionalInitInfo
	
	init(key: SemiSingletonKey, additionalInfo: SemiSingletonAdditionalInitInfo) throws
	
}


public class SemiSingletonStore {
	
	public static let shared = SemiSingletonStore(forceClassInKeys: true)
	
	public let forceClassInKeys: Bool
	
	public init(forceClassInKeys fcik: Bool) {
		forceClassInKeys = fcik
	}
	
	/* ************
	   MARK: - Core
	   ************ */
	
	/* This method is duplicated below in a throwable version */
	public func semiSingleton<O : SemiSingleton>(forKey k: O.SemiSingletonKey, additionalInitInfo: O.SemiSingletonAdditionalInitInfo, isNew: inout Bool) -> O {
		return retrievingQueue.sync{
			let key = StoreKey(key: k, objectType: forceClassInKeys ? O.self : nil)
			if let ro = registeredObjects.object(forKey: key) {
				/* An object has been registered for the given key */
				guard let o = ro as? O else {
					/* Invalid type found. We do not un-register the previous object,
					 * we simply return a non-singleton... */
					#if canImport(os)
						if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Asked to retrieve an object of type %{public}@ for key %@, but registered object is of type %{public}@. Creating a new, non-singleton’d object of required type. For reference, registered object is %@", log: $0, type: .error, String(describing: O.self), String(describing: k), String(describing: type(of: ro)), String(describing: ro)) }}
						else                                                          {NSLog("***** Asked to retrieve an object of type %@ for key %@, but registered object is of type %@. Creating a new, non-singleton’d object of required type. For reference, registered object is %@", String(describing: O.self), String(describing: k), String(describing: type(of: ro)), String(describing: ro))}
					#else
					NSLogString("***** Asked to retrieve an object of type \(String(describing: O.self)) for key \(String(describing: k)), but registered object is of type \(String(describing: type(of: ro))). Creating a new, non-singleton’d object of required type. For reference, registered object is \(String(describing: ro))", log: di.log)
					#endif
					assert(!forceClassInKeys)
					
					isNew = true
					return O(key: k, additionalInfo: additionalInitInfo)
				}
				
				isNew = false
				return o
			}
			
			isNew = true
			let o = O(key: k, additionalInfo: additionalInitInfo)
			registeredObjects.setObject(o, forKey: key)
			return o
		}
	}
	
	/* This method is duplicated above in a non-throwable version */
	public func semiSingleton<O : SemiSingletonWithFallibleInit>(forKey k: O.SemiSingletonKey, additionalInitInfo: O.SemiSingletonAdditionalInitInfo, isNew: inout Bool) throws -> O {
		return try retrievingQueue.sync{
			let key = StoreKey(key: k, objectType: forceClassInKeys ? O.self : nil)
			if let ro = registeredObjects.object(forKey: key) {
				/* An object has been registered for the given key */
				guard let o = ro as? O else {
					/* Invalid type found. We do not un-register the previous object,
					 * we simply return a non-singleton... */
					#if canImport(os)
						if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Asked to retrieve an object of type %{public}@ for key %@, but registered object is of type %{public}@. Creating a new, non-singleton’d object of required type. For reference, registered object is %@", log: $0, type: .error, String(describing: O.self), String(describing: k), String(describing: type(of: ro)), String(describing: ro)) }}
						else                                                          {NSLog("***** Asked to retrieve an object of type %@ for key %@, but registered object is of type %@. Creating a new, non-singleton’d object of required type. For reference, registered object is %@", String(describing: O.self), String(describing: k), String(describing: type(of: ro)), String(describing: ro))}
					#else
						NSLogString("***** Asked to retrieve an object of type \(String(describing: O.self)) for key \(String(describing: k)), but registered object is of type \(String(describing: type(of: ro))). Creating a new, non-singleton’d object of required type. For reference, registered object is \(String(describing: ro))", log: di.log)
					#endif
					assert(!forceClassInKeys)
					
					isNew = true
					return try O(key: k, additionalInfo: additionalInitInfo)
				}
				
				isNew = false
				return o
			}
			
			isNew = true
			let o = try O(key: k, additionalInfo: additionalInitInfo)
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
	
	#if !os(Linux)
		private var registeredObjects = NSMapTable<StoreKey, AnyObject>.strongToWeakObjects()
	#else
		private var registeredObjects = LinuxStrongToWeakMapTable<StoreKey, AnyObject>()
	#endif
	private let retrievingQueue = DispatchQueue(label: "SemiSingletonStore Object Retrieving Queue", qos: .userInitiated)
	
}
