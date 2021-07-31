//
//  OSLogDriver.swift
//  BarcelonaFoundation
//
//  Created by Eric Rabil on 7/29/21.
//  Copyright © 2021 Eric Rabil. All rights reserved.
//

#if canImport(OSLog)
import Foundation
import OSLog
import _SwiftOSOverlayShims

public extension String {
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}

extension LoggingLevel {
    @inlinable
    var osLogType: OSLogType {
        switch self {
        case .info:
            return .info
        case .warn:
            return .error
        case .error:
            return .error
        case .fault:
            return .fault
        case .debug:
            return .debug
        }
    }
}

extension StaticString: Hashable {
    public static func == (lhs: StaticString, rhs: StaticString) -> Bool {
        String(lhs) == String(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(self))
    }
}

public class OSLogDriver: LoggingDriver {
    public var logs = [Int: OSLog]()
    
    public static let shared = OSLogDriver()
    
    private init() {}
    
    public func log(forCategory category: StaticString, fileID: StaticString) -> OSLog {
        let subsystemID = String(String(fileID).split(separator: "/").first!)
        let category = String(category)
        let hash = [subsystemID, category].hashValue
        
        if _fastPath(logs[hash] != nil) {
            return logs[hash]!
        }
        
        let log = OSLog(subsystem: "com.barcelona.\(subsystemID)", category: category)
        logs[hash] = log
        return log
    }
    
    public func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg]) {
        let ra = _swift_os_log_return_address()
        
        message.withUTF8Buffer { buffer in
            buffer.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buffer.count) { cString in
                withVaList(args) { args in
                    _swift_os_log(dso, ra, log(forCategory: category, fileID: fileID), level.osLogType, cString, args)
                }
            }
        }
    }
}

public extension Logger {
    @usableFromInline
    internal func osLog(forFileID fileID: StaticString) -> OSLog {
        OSLogDriver.shared.log(forCategory: category, fileID: fileID)
    }
}

@available(macOS 10.14, *)
public extension Logger {
    func signpost(_ type: OSSignpostType, fileID: StaticString = #fileID, dso: UnsafeRawPointer = #dsohandle, _ name: StaticString, _ format: StaticString? = nil, _ arguments: [CVarArg] = [], id: OSSignpostID) {
        let ra = _swift_os_log_return_address()
        let log = OSLogDriver.shared.log(forCategory: category, fileID: fileID)
        
        guard log.signpostsEnabled && id != .invalid else {
            return
        }
        
        name.withUTF8Buffer { (nameBuf: UnsafeBufferPointer<UInt8>) in
            // Since dladdr is in libc, it is safe to unsafeBitCast
            // the cstring argument type.
            nameBuf.baseAddress!.withMemoryRebound(
              to: CChar.self, capacity: nameBuf.count
            ) { nameStr in
                guard let format = format else {
                    _swift_os_signpost(dso, ra, log, type, nameStr, id.rawValue)
                    return
                }
                
                format.withUTF8Buffer { (formatBuf: UnsafeBufferPointer<UInt8>) in
                    // Since dladdr is in libc, it is safe to unsafeBitCast
                    // the cstring argument type.
                    formatBuf.baseAddress!.withMemoryRebound(
                        to: CChar.self, capacity: formatBuf.count
                    ) { formatStr in
                        withVaList(arguments) { valist in
                            _swift_os_signpost_with_format(dso, ra, log, type,
                                                           nameStr, id.rawValue, formatStr, valist)
                        }
                    }
                }
            }
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
}
#endif
