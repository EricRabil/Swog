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
    public var privacyLevel: BackportedOSLogPrivacy
    
    public init(privacyLevel: BackportedOSLogPrivacy = .public) {
        self.privacyLevel = privacyLevel
    }
    
    @_optimize(speed)
    public func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg]) {
        _log(level: level, category: String(category), message: String(format: String(message), arguments: args))
    }
    
    @_optimize(speed)
    public func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: BackportedOSLogMessage) {
        _log(level: level, category: String(category), message: message.render(level: privacyLevel))
    }
    
    @_optimize(speed)
    public func log(level: LoggingLevel, category: String, message: String) {
        _log(level: level, category: category, message: message)
    }
}

public extension BackportedOSLogMessage {
    @_transparent
    @_optimize(speed)
    func render(level: BackportedOSLogPrivacy) -> String {
        var arguments: [String] = interpolation.arguments.rawArguments.map { argument, privacy in
            if privacy.privacy == .private {
                guard level.isAtleastPrivate else {
                    return "{private}"
                }
            }
            
            return String(describing: argument())
        }
        
        let pieces = interpolation.stringPieces
        
        func render(_ argument: () -> Any, _ privacy: BackportedOSLogPrivacy) -> String {
            if privacy.privacy == .private {
                guard level.isAtleastPrivate else {
                    return "{private}"
                }
            }
            
            return String(describing: argument())
        }
        
        return pieces.map { piece in
            if arguments.count > 0 {
                return String(piece) + arguments.removeFirst()
            }
            
            return String(piece)
        }.joined() + arguments.joined(separator: " ")
    }
}

internal extension ConsoleDriver {
    @_transparent
    @_optimize(speed)
    func _log(level: LoggingLevel, category: String, message: String) {
        let text = level.color(text: "[\(category.padding(toLength: 20, withPad: " ", startingAt: 0).prefix(20))] \(level.printText) \(message)\n")
        
        flockfile(stdout)
        fwrite(text, 1, text.utf8.count, stdout)
        funlockfile(stdout)
    }
}
