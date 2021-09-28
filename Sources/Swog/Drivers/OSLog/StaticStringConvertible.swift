////  File.swift
//  
//
//  Created by Eric Rabil on 8/29/21.
//  
//

import Foundation

extension Array: ExpressibleByUnicodeScalarLiteral where Element == StaticString {
}

extension Array: ExpressibleByExtendedGraphemeClusterLiteral where Element == StaticString {
}

extension Array: ExpressibleByStringLiteral where Element == StaticString {
    public typealias ExtendedGraphemeClusterLiteralType = StaticString
    public typealias UnicodeScalarLiteralType = StaticString
    
    @_transparent
    public init(stringLiteral value: StaticString) {
        self = [value]
    }
    
    @_transparent
    @inline(__always)
    @_optimize(speed)
    public var contiguousView: ContiguousArray<UInt8> {
        let count = count, pointer = _baseAddressIfContiguous.unsafelyUnwrapped
        var index = 0, position = 0, bytes = ContiguousArray<UInt8>()
        
        while index < count {
            let pointer = pointer.advanced(by: index).pointee.utf8Start
            position = 0
            while (pointer + position).pointee != 0x0 {
                bytes.append((pointer + position).pointee)
                position += 1
            }
            index += 1
        }
        
        bytes.append(0x0)
        
        return bytes
    }
}

public typealias ClumpedStaticString = [StaticString]
