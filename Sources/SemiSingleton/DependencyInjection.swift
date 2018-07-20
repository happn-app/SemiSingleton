/*
 * DependencyInjection.swift
 * SemiSingleton
 *
 * Created by François Lamboley on 1/20/18.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation
#if canImport(os)
	import os.log
#endif

#if canImport(DummyLinuxOSLog)
	import DummyLinuxOSLog
#endif



public struct DependencyInjection {
	
	init() {
		#if canImport(os)
			if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {log = .default}
			else                                                          {log = nil}
		#else
		log = ()
		#endif
	}
	
	public var log: OSLog?
	
}

public var di = DependencyInjection()
