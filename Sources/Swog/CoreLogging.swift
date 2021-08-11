//
//  Logging.swift
//  BarcelonaFoundation
//
//  Created by Eric Rabil on 7/29/21.
//  Copyright © 2021 Eric Rabil. All rights reserved.
//

import Foundation
import OSLog

public enum LoggingLevel: Int, Codable {
    case info
    case warn
    case error
    case fault
    case debug
}

public protocol LoggingDriver {
    func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg])
}

#if canImport(OSLog)
public var LoggingDrivers: [LoggingDriver] = [OSLogDriver.shared]
#else
public var LoggingDrivers: [LoggingDriver] = [ConsoleDriver.shared]
#endif

@inlinable @inline(__always)
public func CLLog(level: LoggingLevel, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ category: StaticString, _ message: StaticString, _ args: [CVarArg]) {
    for driver in LoggingDrivers {
        driver.log(level: level, fileID: fileID, line: line, function: function, dso: dso, category: category, message: message, args: args)
    }
}

@inlinable @inline(__always)
public func CLLogVA(level: LoggingLevel, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ category: StaticString, _ message: StaticString, _ args: CVarArg...) {
    CLLog(level: level, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}

@inlinable @inline(__always)
public func CLInfo(_ category: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ message: StaticString, _ args: CVarArg...) {
    CLLog(level: .info, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}

@inlinable @inline(__always)
public func CLWarn(_ category: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ message: StaticString, _ args: CVarArg...) {
    CLLog(level: .warn, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}

@inlinable @inline(__always)
public func CLError(_ category: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ message: StaticString, _ args: CVarArg...) {
    CLLog(level: .error, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}

@inlinable @inline(__always)
public func CLFault(_ category: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ message: StaticString, _ args: CVarArg...) {
    CLLog(level: .fault, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}

@inlinable @inline(__always)
public func CLDebug(_ category: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ message: StaticString, _ args: CVarArg...) {
    CLLog(level: .debug, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}

extension Notification: CVarArg {}
