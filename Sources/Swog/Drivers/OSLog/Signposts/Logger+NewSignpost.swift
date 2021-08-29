////  File.swift
//  
//
//  Created by Eric Rabil on 8/29/21.
//  
//

import Foundation
import OSLog

@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
public extension Logger {
    @_transparent
    func signpost(
        fileID: StaticString = #fileID,
        dso: UnsafeRawPointer = #dsohandle,
        type: OSSignpostType,
        name: StaticString,
        message: BackportedOSLogMessage,
        id: OSSignpostID
    ) {
        os_signpost_send(dso, log: osLog(forFileID: fileID), type: type, id: id, name: name, message: message)
    }
    
    @_transparent
    func signpost(
        fileID: StaticString = #fileID,
        dso: UnsafeRawPointer = #dsohandle,
        type: OSSignpostType,
        name: StaticString,
        id: OSSignpostID
    ) {
        os_signpost_send(dso, log: osLog(forFileID: fileID), type: type, id: id, name: name)
    }

}
