//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

#if canImport(OSLog)

import Foundation
import Swift
import OSLog

@available(macOS 10.14, *)
public class LoggingOperation: Logger {
    public let operationID = UUID().uuidString
    public let name: StaticString
    
    private var signpostID: OSSignpostID? = nil
    
    public init(category: StaticString, name: StaticString) {
        self.name = name
        super.init(category: category)
    }
    
    @discardableResult
    public func begin(_ message: StaticString? = nil, _ args: CVarArg...) -> Self {
        signpostID = signpost(.begin, name, message, args)
        debug("OPERATION.BEGIN: Name=%@ ID=%@", String(name), operationID)
        if let message = message {
            CLLog(level: .debug, category, message, args)
        }
        
        return self
    }
    
    public func event(_ message: StaticString, _ args: CVarArg...) {
        guard let signpostID = signpostID else {
            warn("Logged an operation event when no operation was started. operationID %@ name %@", operationID, String(name))
            return
        }
        
        CLLog(level: .debug, category, message, args)
        
        signpost(.event, name, message, args, id: signpostID)
    }
    
    public func end(_ message: StaticString? = nil, _ args: CVarArg...) {
        guard let signpostID = signpostID else {
            fault("Attempted to end an operation when no operation was started. operationID %@ name %@", operationID, String(name))
            return
        }
        
        if let message = message {
            CLLog(level: .debug, category, message, args)
        }
        
        debug("OPERATION.END: Name=%@ ID=%@", String(name), operationID)
        signpost(.end, name, message, args, id: signpostID)
        self.signpostID = nil
    }
}

#endif
