////  File.swift
//  
//
//  Created by Eric Rabil on 8/29/21.
//  
//

import Foundation

public struct LoggingPayload: Codable, Hashable, Equatable {
    public var level: LoggingLevel.Name
    public var fileID: String
    public var line: Int
    public var function: String
    public var category: String
    public var message: String
    public var metadata: MetadataValue
    
    public init(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg]) {
        self.level = level.name
        self.fileID = String(fileID)
        self.line = line
        self.function = String(function)
        self.category = String(category)
        self.message = String(format: String(message), arguments: args)
        self.metadata = .nil
    }
    
    public init(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: BackportedOSLogMessage, metadata: MetadataValue) {
        self.level = level.name
        self.fileID = String(fileID)
        self.line = line
        self.function = String(function)
        self.category = String(category)
        self.message = message.render(level: .auto)
        self.metadata = metadata
    }
    
    public func hash(into hasher: inout Hasher) {
        level.hash(into: &hasher)
        fileID.hash(into: &hasher)
        line.hash(into: &hasher)
        function.hash(into: &hasher)
        category.hash(into: &hasher)
        message.hash(into: &hasher)
        metadata.hash(into: &hasher)
    }
}

public protocol LoggingDriver: AnyObject {
    func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg])
    func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: BackportedOSLogMessage, metadata: MetadataValue)
}

open class LoggingStream: LoggingDriver {
    open var callback: (LoggingPayload) -> ()
    
    public init(_ callback: @escaping (LoggingPayload) -> ()) {
        self.callback = callback
    }
    
    open func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg]) {
        callback(LoggingPayload(level: level, fileID: fileID, line: line, function: function, dso: dso, category: category, message: message, args: args))
    }
    
    open func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: BackportedOSLogMessage, metadata: MetadataValue) {
        callback(LoggingPayload(level: level, fileID: fileID, line: line, function: function, dso: dso, category: category, message: message, metadata: metadata))
    }
}
