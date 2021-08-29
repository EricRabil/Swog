////  File.swift
//  
//
//  Created by Eric Rabil on 8/29/21.
//  
//

import Foundation
import OSLog

@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
public extension OSLogOperation {
    @_transparent
    func beginSignpost(fileID: StaticString = #fileID, dso: UnsafeRawPointer = #dsohandle, name: StaticString, message: BackportedOSLogMessage) -> Self {
        signpostID = OSSignpostID(log: osLog(forFileID: fileID))
        signpost(fileID: fileID, dso: dso, type: .begin, name: name, message: message, id: signpostID)
        
        Self.delegate?.operation(self, updatedWithType: .begin, message: message)
        
        CLDebug(category, message)
        
        return self
    }
    
    @_transparent
    func beginSignpost(fileID: StaticString = #fileID, dso: UnsafeRawPointer = #dsohandle, name: StaticString) -> Self {
        signpostID = OSSignpostID(log: osLog(forFileID: fileID))
        signpost(fileID: fileID, dso: dso, type: .begin, name: name, id: signpostID)
        
        Self.delegate?.operation(self, updatedWithType: .begin, message: nil)
        
        return self
    }

    @_transparent
    func end(
        fileID: StaticString = #fileID,
        dso: UnsafeRawPointer = #dsohandle,
        name: StaticString,
        message: BackportedOSLogMessage
    ) {
        signpost(fileID: fileID, dso: dso, type: .end, name: name, message: message, id: signpostID)
    }
    
    @_transparent
    func end(
        fileID: StaticString = #fileID,
        dso: UnsafeRawPointer = #dsohandle,
        name: StaticString
    ) {
        signpost(fileID: fileID, dso: dso, type: .end, name: name, id: signpostID)
    }

    @_transparent
    func event(
        fileID: StaticString = #fileID,
        dso: UnsafeRawPointer = #dsohandle,
        name: StaticString,
        message: BackportedOSLogMessage
    ) {
        signpost(fileID: fileID, dso: dso, type: .event, name: name, message: message, id: signpostID)
    }
    
    @_transparent
    func event(
        fileID: StaticString = #fileID,
        dso: UnsafeRawPointer = #dsohandle,
        name: StaticString
    ) {
        signpost(fileID: fileID, dso: dso, type: .event, name: name, id: signpostID)
    }
}
