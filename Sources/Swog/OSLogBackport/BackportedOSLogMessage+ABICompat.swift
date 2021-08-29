//
//  File.swift
//  
//
//  Created by Eric Rabil on 8/28/21.
//

import Foundation
import Swift
import ObjectiveC
import os
import _SwiftOSOverlayShims


// void _os_log_impl(void *dso, os_log_t log, os_log_type_t type, const char *format, uint8_t *buf, uint32_t size);

//

@usableFromInline
typealias _os_log_impl_ = @convention(c) (_ dso: UnsafeRawPointer, _ log: OSLog, _ type: OSLogType, _ format: UnsafePointer<CChar>, _ buf: UnsafeMutablePointer<UInt8>, _ size: UInt32) -> ()

@usableFromInline
let _os_log_impl = unsafeBitCast(dlsym(dlopen("/usr/lib/libSystem.dylib", RTLD_LAZY | RTLD_NOLOAD), "_os_log_impl")!, to: _os_log_impl_.self)

@_transparent
@_optimize(none)
public func os_log_send(_ dso: UnsafeRawPointer = #dsohandle, _ log: OSLog, _ type: OSLogType, _ message: BackportedOSLogMessage) {
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

    _os_log_impl(
        dso,
        log,
        type,
        formatString,
        bufferMemory,
        uint32bufferSize)

    // The following operation extends the lifetime of objectArguments and
    // stringArgumentOwners till this point. This is necessary because the
    // assertion is passed internal pointers to the objects/strings stored
    // in these arrays, as in the actual os log implementation.
    destroyStorage(objectArguments, count: objectCount)
    destroyStorage(stringArgumentOwners, count: stringCount)
    bufferMemory.deallocate()
}
