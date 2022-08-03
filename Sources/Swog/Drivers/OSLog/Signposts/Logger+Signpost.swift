////  File.swift
//  
//
//  Created by Eric Rabil on 8/29/21.
//  
//

import Foundation
import OSLog
import _SwiftOSOverlayShims

@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
public extension Logger {
    func signpost(_ type: OSSignpostType, fileID: StaticString = #fileID, dso: UnsafeRawPointer = #dsohandle, _ name: StaticString, _ format: StaticString? = nil, _ arguments: [CVarArg] = [], id: OSSignpostID) {
        let ra = _swift_os_log_return_address()
        let log = osLog(forFileID: fileID)
        
        guard log.signpostsEnabled && id != .invalid else {
            return
        }
        
        name.withUTF8Buffer { nameBuf in
            nameBuf.baseAddress!.withMemoryRebound(to: CChar.self, capacity: nameBuf.count) { nameStr in
                guard let format = format else {
                    _swift_os_signpost(dso, ra, log, type, nameStr, id.rawValue)
                    return
                }
                
                format.withUTF8Buffer { formatBuf in
                    formatBuf.baseAddress!.withMemoryRebound(to: CChar.self, capacity: formatBuf.count) { formatStr in
                        withVaList(arguments) { valist in
                            _swift_os_signpost_with_format(dso, ra, log, type, nameStr, id.rawValue, formatStr, valist)
                        }
                    }
                }
            }
        }
    }
    
    @inlinable @inline(__always)
    func signpost(_ type: OSSignpostType, fileID: StaticString = #fileID, dso: UnsafeRawPointer = #dsohandle, _ name: StaticString, _ message: StaticString? = nil, _ args: [CVarArg] = []) -> OSSignpostID {
        let id = OSSignpostID(log: osLog(forFileID: fileID))
        signpost(type, fileID: fileID, dso: dso, name, message, args, id: id)
        return id
    }
    
    @inlinable @inline(__always)
    func signpost(fileID: StaticString = #fileID, dso: UnsafeRawPointer = #dsohandle, _ name: StaticString, _ message: StaticString? = nil, _ args: [CVarArg]) -> () -> () {
        let id = OSSignpostID(log: osLog(forFileID: fileID))
        
        signpost(.begin, dso: dso, name, message, args, id: id)
        
        return {
            self.signpost(.end, dso: dso, name, id: id)
        }
    }
    
    @inlinable @inline(__always)
    func signpost(fileID: StaticString = #fileID, dso: UnsafeRawPointer = #dsohandle, _ name: StaticString, _ message: StaticString? = nil, _ args: CVarArg...) -> () -> () {
        let id = OSSignpostID(log: osLog(forFileID: fileID))
        
        signpost(.begin, dso: dso, name, message, args, id: id)
        
        return {
            self.signpost(.end, dso: dso, name, id: id)
        }
    }
    
    @_transparent
    @usableFromInline
    internal func osLog(forFileID fileID: StaticString) -> OSLog {
        OSLogDriver.shared.log(forCategory: category, subsystem: subsystem, fileID: fileID)
    }
}
