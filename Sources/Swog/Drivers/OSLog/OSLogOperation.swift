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
public protocol OSLogOperationDelegate {
    func classicOperation(_ operation: OSLogOperation, updatedWithType type: OSSignpostType, formatString: StaticString?, args: [CVarArg])
    func operation(_ operation: OSLogOperation, updatedWithType type: OSSignpostType, message: BackportedOSLogMessage?)
}

@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
public class OSLogOperation: Logger {
    public let operationID = UUID().uuidString
    public let name: StaticString
    
    public static var delegate: OSLogOperationDelegate?
    
    @usableFromInline
    internal var signpostID: OSSignpostID!
    
    public init(category: StaticString, name: StaticString) {
        self.name = name
        super.init(category: category)
    }
    
    @discardableResult
    func begin(_ message: StaticString? = nil, _ args: CVarArg...) -> Self {
        signpostID = signpost(.begin, name, message, args)
        
        Self.delegate?.classicOperation(self, updatedWithType: .begin, formatString: message, args: args)
        
        if let message = message {
            CLLog(level: .debug, category, message, args)
        }
        
        return self
    }
    
    func event(_ message: StaticString, _ args: CVarArg...) {
        #if DEBUG
        guard signpostID != nil else {
            preconditionFailure("OSLogOperation.begin must be invoked before calling other methods")
        }
        #endif
        
        CLDebug(category, message, args)
        signpost(.event, name, message, args, id: signpostID)
    }
    
    func end(_ message: StaticString? = nil, _ args: CVarArg...) {
        #if DEBUG
        guard signpostID != nil else {
            preconditionFailure("OSLogOperation.begin must be invoked before calling other methods")
        }
        #endif
        
        if let message = message {
            CLDebug(category, message, args)
        }
        
        Self.delegate?.classicOperation(self, updatedWithType: .end, formatString: message, args: args)
        signpost(.end, name, message, args, id: signpostID)
        self.signpostID = nil
    }
}

@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
public typealias LoggingOperation = OSLogOperation
