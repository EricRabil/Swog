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

extension LoggingLevel {
    var name: String {
        "\(self)"
    }
    
    var printText: String {
        "[\(name.uppercased().padding(toLength: 6, withPad: " ", startingAt: 0))]"
    }
    
    func color(text: String) -> String {
        switch self {
        case .info:
            return text.cyan
        case .warn:
            return text.yellow
        case .debug:
            return text
        case .fault:
            return text.onRed
        case .error:
            return text.lightRed
        }
    }
}

public class ConsoleDriver: LoggingDriver {
    public static let shared = ConsoleDriver()
    public var privacyLevel = BackportedOSLogPrivacy.public
    
    public func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg]) {
        log(level: level, category: String(category), message: String(format: String(message), arguments: args))
    }
    
    private func render(message: BackportedOSLogMessage) -> String {
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
    
    public func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: BackportedOSLogMessage) {
        log(level: level, category: String(category), message: render(message: message))
    }
    
    public func log(level: LoggingLevel, category: String, message: String) {
        print(level.color(text: "[\(category.padding(toLength: 20, withPad: " ", startingAt: 0).prefix(20))] \(level.printText) \(message)"))
    }
}
