//
//  Logger.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation

public class Logger {
    public let category: StaticString
    
    public init(category: StaticString) {
        self.category = category
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
    public func callAsFunction(_ message: StaticString, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ args: CVarArg...) {
        CLLog(level: .info, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
    }
    
    #if canImport(OSLog)
    @available(macOS 10.14, *)
    public func operation(named name: StaticString) -> LoggingOperation {
        LoggingOperation(category: category, name: name)
    }
    #endif
}
