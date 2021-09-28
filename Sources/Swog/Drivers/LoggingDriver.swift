////  File.swift
//  
//
//  Created by Eric Rabil on 8/29/21.
//  
//

import Foundation

public protocol LoggingDriver {
    func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg])
    func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: BackportedOSLogMessage)
}
