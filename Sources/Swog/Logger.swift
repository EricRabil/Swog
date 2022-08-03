//
//  Logger.swift
//
//
//  Created by Eric Rabil on 7/31/21.
//


import Foundation
import Swift

public class Logger {
    public let category: StaticString
    public let subsystem: StaticString?
    
    public init(category: StaticString, subsystem: StaticString? = nil) {
        self.category = category
        self.subsystem = subsystem
    }
    
    @inlinable @inline(__always)
    public func info(_ message: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ args: CVarArg...) {
        CLLog(level: .info, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
    }
    
    @inlinable @inline(__always)
    public func warn(_ message: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ args: CVarArg...) {
        CLLog(level: .warn, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
    }
    
    @inlinable @inline(__always)
    public func error(_ message: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ args: CVarArg...) {
        CLLog(level: .error, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
    }
    
    @inlinable @inline(__always)
    public func fault(_ message: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ args: CVarArg...) {
        CLLog(level: .fault, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
    }
    
    @inlinable @inline(__always)
    public func debug(_ message: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ args: CVarArg...) {
        CLLog(level: .debug, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
    }
    
    @inlinable @inline(__always)
    public func callAsFunction(_ message: StaticString, _ args: CVarArg..., level: LoggingLevel = .info, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle) {
        CLLog(level: level, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
    }
    
    @available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
    public func operation(named name: StaticString) -> LoggingOperation {
        LoggingOperation(category: category, name: name)
    }
}

public extension Logger {
    @_transparent
    @_optimize(speed)
    func info(_ message: BackportedOSLogMessage, metadata: MetadataValue = nil, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle) {
        CLLog(level: .info, fileID: fileID, line: line, function: function, dso: dso, category, message, metadata: metadata)
    }
    
    @_transparent
    @_optimize(speed)
    func warn(_ message: BackportedOSLogMessage, metadata: MetadataValue = nil, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle) {
        CLLog(level: .warn, fileID: fileID, line: line, function: function, dso: dso, category, message, metadata: metadata)
    }
    
    @_transparent
    @_optimize(speed)
    func error(_ message: BackportedOSLogMessage, metadata: MetadataValue = nil, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle) {
        CLLog(level: .error, fileID: fileID, line: line, function: function, dso: dso, category, message, metadata: metadata)
    }
    
    @_transparent
    @_optimize(speed)
    func fault(_ message: BackportedOSLogMessage, metadata: MetadataValue = nil, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle) {
        CLLog(level: .fault, fileID: fileID, line: line, function: function, dso: dso, category, message, metadata: metadata)
    }
    
    @_transparent
    @_optimize(speed)
    func debug(_ message: BackportedOSLogMessage, metadata: MetadataValue = nil, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle) {
        CLLog(level: .debug, fileID: fileID, line: line, function: function, dso: dso, category, message, metadata: metadata)
    }
    
    @_transparent
    @_optimize(speed)
    func callAsFunction(_ message: BackportedOSLogMessage, metadata: MetadataValue = nil, level: LoggingLevel = .info, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle) {
        CLLog(level: level, fileID: fileID, line: line, function: function, dso: dso, category, message, metadata: metadata)
    }
}
