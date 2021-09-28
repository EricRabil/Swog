//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation
import Swift
import OSLog

@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
public protocol OSSignpostOperationDelegate {
    func classicOperation(_ operation: OSSignpostOperation, updatedWithType type: OSSignpostType, formatString: StaticString?, args: [CVarArg])
    func operation(_ operation: OSSignpostOperation, updatedWithType type: OSSignpostType, message: BackportedOSLogMessage?)
}

/**
 Manage an os_signpost operation
 */
@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
public class OSSignpostOperation: Logger {
    public let operationID = UUID().uuidString
    public let name: StaticString
    
    public static var delegate: OSSignpostOperationDelegate?
    
    @usableFromInline
    internal var signpostID: OSSignpostID!
    
    @usableFromInline
    internal var finished = false
    
    public init(category: StaticString, name: StaticString) {
        self.name = name
        super.init(category: category)
    }
    
    /**
     Begins a signpost operation, constructing a new signpost ID that is unique to this log
     */
    @discardableResult
    public func begin(_ message: StaticString? = nil, _ args: CVarArg...) -> Self {
        signpostID = signpost(.begin, name, message, args)
        
        Self.delegate?.classicOperation(self, updatedWithType: .begin, formatString: message, args: args)
        
        if let message = message {
            CLLog(level: .debug, category, message, args)
        }
        
        return self
    }
    
    public func event(_ message: StaticString, line: Int = #line, file: StaticString = #file, _ args: CVarArg...) {
        #if DEBUG
        guard signpostID != nil else {
            print(Thread.callStackSymbols.joined(separator: "\n"))
            print("\(file):\(line)")
            preconditionFailure("OSLogOperation.begin must be invoked before calling other methods")
        }
        #endif
        
        CLLog(level: .debug, category, message, args)
        signpost(.event, name, message, args, id: signpostID)
    }
    
    public func end(_ message: StaticString? = nil, line: Int = #line, file: StaticString = #file, _ args: CVarArg...) {
        #if DEBUG
        guard signpostID != nil else {
            print(Thread.callStackSymbols.joined(separator: "\n"))
            print("\(file):\(line)")
            preconditionFailure("OSLogOperation.begin must be invoked before calling other methods")
        }
        #endif
        
        if let message = message {
            CLLog(level: .debug, category, message, args)
        }
        
        Self.delegate?.classicOperation(self, updatedWithType: .end, formatString: message, args: args)
        signpost(.end, name, message, args, id: signpostID)
        self.signpostID = nil
    }
}

@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
public typealias LoggingOperation = OSSignpostOperation
