//
//  OSLogSend.swift
//  Adapted from https://github.com/apple/swift/blob/main/stdlib/private/OSLog/OSLogTestHelper.swift
//
//  Created by Eric Rabil on 8/28/21.
//

import Foundation
import Swift
import ObjectiveC
import os
import _SwiftOSOverlayShims

@_transparent
private func resolveSystemSymbol<P>(named name: String) -> P {
    unsafeBitCast(dlsym(dlopen("/usr/lib/libSystem.dylib", RTLD_LAZY | RTLD_NOLOAD), name)!, to: P.self)
}

// void _os_log_impl(void *dso, os_log_t log, os_log_type_t type, const char *format, uint8_t *buf, uint32_t size);

@usableFromInline
typealias _os_log_impl_ = @convention(c) (
    _ dso: UnsafeRawPointer,
    _ log: OSLog,
    _ type: OSLogType,
    _ format: UnsafePointer<CChar>,
    _ buf: UnsafeMutablePointer<UInt8>,
    _ size: UInt32
) -> ()

@usableFromInline
let _os_log_impl: _os_log_impl_ = resolveSystemSymbol(named: "_os_log_impl")

@_transparent
@usableFromInline
internal func os_log_prepare<P>(_ message: BackportedOSLogMessage, _ cb: (String, UnsafeMutablePointer<UInt8>, UInt32) throws -> P) rethrows -> P {
    // Compute static constants first so that they can be folded by
    // OSLogOptimization pass.
    let formatString = message.interpolation.formatString
    let preamble = message.interpolation.preamble
    let argumentCount = message.interpolation.argumentCount
    let bufferSize = message.bufferSize
    let objectCount = message.interpolation.objectArgumentCount
    let stringCount = message.interpolation.stringArgumentCount
    let uint32bufferSize = UInt32(bufferSize)
    let argumentClosures = message.interpolation.arguments.argumentClosures

    let bufferMemory = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    // Buffer for storing NSObjects and strings to keep them alive until the
    // _os_log_impl_test call completes.
    let objectArguments = createStorage(capacity: objectCount, type: NSObject.self)
    let stringArgumentOwners = createStorage(capacity: stringCount, type: Any.self)

    var currentBufferPosition = bufferMemory
    var objectArgumentsPosition = objectArguments
    var stringArgumentOwnersPosition = stringArgumentOwners
    serialize(preamble, at: &currentBufferPosition)
    serialize(argumentCount, at: &currentBufferPosition)
    argumentClosures.forEach {
    $0(&currentBufferPosition,
       &objectArgumentsPosition,
       &stringArgumentOwnersPosition)
    }
    
    defer {
        // The following operation extends the lifetime of objectArguments and
        // stringArgumentOwners till this point. This is necessary because the
        // assertion is passed internal pointers to the objects/strings stored
        // in these arrays, as in the actual os log implementation.
        destroyStorage(objectArguments, count: objectCount)
        destroyStorage(stringArgumentOwners, count: stringCount)
        bufferMemory.deallocate()
    }
    
    return try cb(formatString, bufferMemory, uint32bufferSize)
}

@_transparent
public func os_log_send(_ dso: UnsafeRawPointer = #dsohandle, _ log: OSLog, _ type: OSLogType, _ message: BackportedOSLogMessage) {
    os_log_prepare(message) { formatString, bufferMemory, uint32bufferSize in
        _os_log_impl(
            dso,
            log,
            type,
            formatString,
            bufferMemory,
            uint32bufferSize)
    }
}

//void
//_os_signpost_emit_with_name_impl(void *dso, os_log_t log,
//        os_signpost_type_t type, os_signpost_id_t spid, const char *name,
//        const char *format, uint8_t *buf, uint32_t size);

@usableFromInline
@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
typealias _os_signpost_emit_with_name_impl_ = @convention(c) (
    _ dso: UnsafeRawPointer,
    _ log: OSLog,
    _ type: OSSignpostType,
    _ id: os_signpost_id_t,
    _ name: UnsafePointer<CChar>,
    _ format: UnsafePointer<CChar>?,
    _ buffer: UnsafeMutablePointer<UInt8>?,
    _ size: UInt32
) -> ()

@usableFromInline
@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
let _os_signpost_emit_with_name_impl: _os_signpost_emit_with_name_impl_ = resolveSystemSymbol(named: "_os_signpost_emit_with_name_impl")

@_transparent
@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
public func os_signpost_send(_ dso: UnsafeRawPointer = #dsohandle, log: OSLog, type: OSSignpostType, id: OSSignpostID, name: StaticString) {
    _os_signpost_emit_with_name_impl(dso, log, type, id.rawValue, String(name), nil, nil, 0)
}

@_transparent
@available(macOS 10.14, iOS 12.0, watchOS 5.0, *)
public func os_signpost_send(_ dso: UnsafeRawPointer = #dsohandle, log: OSLog, type: OSSignpostType, id: OSSignpostID, name: StaticString, message: BackportedOSLogMessage) {
    os_log_prepare(message) { formatString, bufferMemory, uint32BufferSize in
        _os_signpost_emit_with_name_impl(dso, log, type, id.rawValue, String(name), formatString, bufferMemory, uint32BufferSize)
    }
}
