//
//  Logging.swift
//  BarcelonaFoundation
//
//  Created by Eric Rabil on 7/29/21.
//  Copyright © 2021 Eric Rabil. All rights reserved.
//

import Foundation
import OSLog
import Swift

#if canImport(OSLog)
public var LoggingDrivers: [LoggingDriver] = [ConsoleDriver.shared]
#else
public var LoggingDrivers: [LoggingDriver] = [ConsoleDriver.shared]
#endif

// MARK: - Old API
@_transparent
@_optimize(speed)
public func CLLog(
    level: LoggingLevel,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ category: StaticString,
    _ message: StaticString,
    _ args: [CVarArg]
) {
    for driver in LoggingDrivers {
        driver.log(level: level, fileID: fileID, line: line, function: function, dso: dso, category: category, message: message, args: args)
    }
}

// MARK: - New API
@_transparent
@_optimize(speed)
public func CLLog(level: LoggingLevel, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ category: StaticString, _ message: BackportedOSLogMessage, metadata: MetadataValue = nil) {
    for driver in LoggingDrivers {
        driver.log(level: level, fileID: fileID, line: line, function: function, dso: dso, category: category, message: message, metadata: metadata)
    }
}

extension Notification: CVarArg {}
