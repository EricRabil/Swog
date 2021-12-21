//
//  OSLogDriver.swift
//  BarcelonaFoundation
//
//  Created by Eric Rabil on 7/29/21.
//  Copyright © 2021 Eric Rabil. All rights reserved.
//

import Foundation
import OSLog
import _SwiftOSOverlayShims
import Swift

public extension String {
    init(_ convertible: StaticString) {
        self = String(cString: convertible.utf8Start)
    }
}

/// A logging driver that outputs to OSLog without the consequences of wrapping OSLog
public class OSLogDriver: LoggingDriver {
    public var logs = [Int: OSLog]()
    
    public static let shared = OSLogDriver()
    
    public let subsystemPrefix: StaticString
    
    public init(subsystemPrefix: StaticString = "com.barcelona.") {
        self.subsystemPrefix = subsystemPrefix
    }
    
    /**
     Send a traditional logging message via static strings and CVarArgs
     */
    @_optimize(speed)
    public func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg]) {
        let ra = _swift_os_log_return_address()
        
        message.withUTF8Buffer { buffer in
            buffer.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buffer.count) { cString in
                withVaList(args) { args in
                    _swift_os_log(dso, ra, log(forCategory: category, fileID: fileID), OSLogType(rawValue: level.rawValue), cString, args)
                }
            }
        }
    }
    
    /**
     Sends a logging message constructed from a customized interpolation implementation
     */
    @_optimize(speed)
    public func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: BackportedOSLogMessage, metadata: MetadataValue) {
        os_log_send(dso, log(forCategory: category, fileID: fileID), OSLogType(rawValue: level.rawValue), message)
    }
}

internal extension OSLogDriver {
    @_transparent
    @usableFromInline
    func log(forCategory category: StaticString, fileID: StaticString) -> OSLog {
        let subsystemID = String(String(fileID).split(separator: "/").first!)
        let category = String(category)
        let hash = [subsystemID, category].hashValue
        
        if _fastPath(logs[hash] != nil) {
            return logs[hash]!
        }
        
        let log = OSLog(subsystem: String(subsystemPrefix) + subsystemID, category: category)
        logs[hash] = log
        return log
    }
}
