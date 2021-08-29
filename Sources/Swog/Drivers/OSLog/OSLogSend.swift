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
@inline(__always)
@usableFromInline
internal func os_log_prepare<P>(_ message: BackportedOSLogMessage, _ cb: (UnsafePointer<UInt8>, UnsafeMutablePointer<UInt8>, Int) throws -> P) rethrows -> P {
    // Compute static constants first so that they can be folded by
    // OSLogOptimization pass.
    let interpolation = message.interpolation
    let objectCount = interpolation.objectArgumentCount
    let stringCount = interpolation.stringArgumentCount

    // Buffer for storing NSObjects and strings to keep them alive until the
    // _os_log_impl_test call completes.
    let objectArguments = createStorage(capacity: objectCount, type: NSObject.self)
    let stringArgumentOwners = createStorage(capacity: stringCount, type: Any.self)
    
    @_transparent
    @inline(__always)
    func os_log_serialize(_ interpolation: BackportedOSLogInterpolation, objectArguments: ObjectStorage<NSObject>, stringArgumentOwners: ObjectStorage<Any>) -> UnsafeMutablePointer<UInt8> {
        let bufferMemory = UnsafeMutablePointer<UInt8>.allocate(capacity: interpolation.totalBytesForSerializingArguments + 2)
        
        var currentBufferPosition = bufferMemory
        var objectArgumentsPosition = objectArguments
        var stringArgumentOwnersPosition = stringArgumentOwners
        serialize(interpolation.preamble, at: &currentBufferPosition)
        serialize(interpolation.argumentCount, at: &currentBufferPosition)
        
        let baseAddress = interpolation.arguments.argumentClosures._baseAddressIfContiguous.unsafelyUnwrapped
        let count = interpolation.arguments.argumentClosures.count
        var index = 0
        
        while index < count {
            baseAddress[index](&currentBufferPosition, &objectArgumentsPosition, &stringArgumentOwnersPosition)
            index += 1
        }
        
        return bufferMemory
    }
    
    let bufferMemory = os_log_serialize(interpolation, objectArguments: objectArguments, stringArgumentOwners: stringArgumentOwners)
    var contiguousView = interpolation.formatString.contiguousView
    
    defer {
        // The following operation extends the lifetime of objectArguments and
        // stringArgumentOwners till this point. This is necessary because the
        // assertion is passed internal pointers to the objects/strings stored
        // in these arrays, as in the actual os log implementation.
        destroyStorage(objectArguments, count: objectCount)
        destroyStorage(stringArgumentOwners, count: stringCount)
        bufferMemory.deallocate()
        contiguousView.removeAll()
    }
    
    return try cb(contiguousView._baseAddressIfContiguous.unsafelyUnwrapped, bufferMemory, interpolation.totalBytesForSerializingArguments + 2)
}

@_transparent
public func os_log_send(_ dso: UnsafeRawPointer = #dsohandle, _ log: OSLog, _ type: OSLogType, _ message: BackportedOSLogMessage) {
    os_log_prepare(message) { formatString, bufferMemory, bufferSize in
        _os_log_impl(
            dso,
            log,
            type,
            UnsafeRawPointer(formatString).assumingMemoryBound(to: CChar.self),
            bufferMemory,
            UInt32(bufferSize))
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
    os_log_prepare(message) { formatString, bufferMemory, bufferSize in
        _os_signpost_emit_with_name_impl(dso, log, type, id.rawValue, String(name), UnsafeRawPointer(formatString).assumingMemoryBound(to: CChar.self), bufferMemory, UInt32(bufferSize))
    }
}
