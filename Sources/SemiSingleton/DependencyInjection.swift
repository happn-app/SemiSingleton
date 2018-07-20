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



#if !canImport(os)
public typealias OSLog = Void?
public enum OSLogType {
	case `default`
	case info
	case debug
	case error
	case fault
}
public func os_log(_ message: StaticString, dso: UnsafeRawPointer? = #dsohandle, log: OSLog = (), type: OSLogType = .default, _ args: CVarArg...) {
	let messageString = message.withUTF8Buffer{ buffer -> String in
		String(decoding: buffer, as: UTF8.self)
	}
	let regex = try! NSRegularExpression(pattern: "%\\{.*\\}", options: []) /* Note: "Hello %%{world}!" fails. Not the end of the world… */
	let fullRange = NSRange(messageString.startIndex..<messageString.endIndex, in: messageString)
	let nonOSLogMessageString = regex.stringByReplacingMatches(in: messageString, options: [], range: fullRange, withTemplate: "%")
	withVaList(args, { vaListPtr in
		NSLogv(nonOSLogMessageString, vaListPtr)
	})
}
public func NSLogString(_ str: String) {
	NSLog(str.replacingOccurrences(of: "%", with: "%%"))
}
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
