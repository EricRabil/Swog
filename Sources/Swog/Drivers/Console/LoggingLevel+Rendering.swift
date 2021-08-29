////  File.swift
//  
//
//  Created by Eric Rabil on 8/29/21.
//  
//

import Foundation

internal extension LoggingLevel {
    @_transparent
    var name: String {
        "\(self)"
    }
    
    @_transparent
    var printText: String {
        "[\(name.uppercased().padding(toLength: 6, withPad: " ", startingAt: 0))]"
    }
    
    @_transparent
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
