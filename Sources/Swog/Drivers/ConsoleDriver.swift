//
//  ConsoleDriver.swift
//  BarcelonaFoundation
//
//  Created by Eric Rabil on 7/29/21.
//  Copyright © 2021 Eric Rabil. All rights reserved.
//

import Foundation
#if canImport(Rainbow)
import Rainbow
#endif

extension LoggingLevel {
    var name: String {
        "\(self)"
    }
    
    var printText: String {
        "[\(name.uppercased().padding(toLength: 6, withPad: " ", startingAt: 0))]"
    }
    
    #if canImport(Rainbow)
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
    #endif
}

public class ConsoleDriver: LoggingDriver {
    public static let shared = ConsoleDriver()
    
    public func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg]) {
        var output = "[\(String(category).padding(toLength: 20, withPad: " ", startingAt: 0).prefix(20))] \(level.printText) \(String(format: String(message), arguments: args))"
        
        #if canImport(Rainbow)
        print(level.color(text: output))
        #else
        print(output)
        #endif
    }
}
