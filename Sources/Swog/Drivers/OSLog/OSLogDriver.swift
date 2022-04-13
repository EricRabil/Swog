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
    public var logs: NSMapTable<NSNumber, OSLog> = NSMapTable.strongToStrongObjects()
    
    @usableFromInline internal let writeSemaphore = DispatchSemaphore(value: 1)
    
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

extension StaticString {
    @_transparent
    @usableFromInline
    func firstIndex(of character: StaticString) -> Int? {
        guard let pos = strchr(utf8Start, Int32(character.utf8Start.pointee)) else {
            return nil
        }
        return abs(utf8Start.distance(to: UnsafeRawPointer(pos).assumingMemoryBound(to: UInt8.self)))
    }
    
    @_transparent
    @usableFromInline
    func hashUpToCharacter(_ character: StaticString, hasher: inout Hasher) {
        let index = firstIndex(of: character) ?? utf8CodeUnitCount
        hasher.combine(bytes: UnsafeRawBufferPointer(start: utf8Start, count: index))
    }
}

internal extension OSLogDriver {
    @_transparent
    @usableFromInline
    func log(forCategory category: StaticString, fileID: StaticString) -> OSLog {
        var hasher = Hasher()
        fileID.hashUpToCharacter("/", hasher: &hasher)
        hasher.combine(bytes: UnsafeRawBufferPointer(start: category.utf8Start, count: category.utf8CodeUnitCount))
        let hash = hasher.finalize() as NSNumber
        
        var log = logs.object(forKey: hash)
        
        if _fastPath(log != nil) {
            return log!
        }
        
        writeSemaphore.wait()
        defer {
            writeSemaphore.signal()
        }
        if let log = logs.object(forKey: hash) {
            // did someone else beat us to the punch?
            return log
        }
        
        let subsystemID = String(String(fileID).split(separator: "/").first!)
        log = OSLog(subsystem: String(subsystemPrefix) + subsystemID, category: String(category))
        logs.setObject(log, forKey: hash)
        return log!
    }
}
