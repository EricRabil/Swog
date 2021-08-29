//
//  ConsoleDriver.swift
//  BarcelonaFoundation
//
//  Created by Eric Rabil on 7/29/21.
//  Copyright © 2021 Eric Rabil. All rights reserved.
//

import Foundation
import Rainbow
import Swift

public class ConsoleDriver: LoggingDriver {
    public static let shared = ConsoleDriver()
    public var privacyLevel = BackportedOSLogPrivacy.public
    
    public func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg]) {
        _log(level: level, category: String(category), message: String(format: String(message), arguments: args))
    }
    
    public func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: BackportedOSLogMessage) {
        _log(level: level, category: String(category), message: render(message: message))
    }
    
    public func log(level: LoggingLevel, category: StaticString, message: String) {
        _log(level: level, category: String(category), message: message)
    }
}

internal extension ConsoleDriver {
    @_transparent
    func _log(level: LoggingLevel, category: String, message: String) {
        let text = level.color(text: "[\(category.padding(toLength: 20, withPad: " ", startingAt: 0).prefix(20))] \(level.printText) \(message)")
        
        flockfile(stdout)
        fwrite(text, 1, text.utf8.count, stdout)
        funlockfile(stdout)
    }
    
    @_transparent
    func render(message: BackportedOSLogMessage) -> String {
        var arguments = message.interpolation.arguments.rawArguments
        let pieces = message.interpolation.stringPieces
        
        func render(_ argument: () -> Any, _ privacy: BackportedOSLogPrivacy) -> String {
            if privacy.privacy == .private {
                guard privacyLevel.isAtleastPrivate else {
                    return "{private}"
                }
            }
            
            return String(describing: argument())
        }
        
        return pieces.map { piece in
            if arguments.count > 0 {
                let (value, privacy) = arguments.removeFirst()
                return piece + render(value, privacy)
            }
            
            return piece
        }.joined() + arguments.map(render).joined(separator: " ")
    }
}
