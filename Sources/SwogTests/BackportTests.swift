//
//  File.swift
//  
//
//  Created by Eric Rabil on 8/28/21.
//

import XCTest
@testable import Swog
import Swift
import OSLog
import _SwiftOSOverlayShims

class BackportTests: XCTestCase {
    func testParse() {
        let x: BackportedOSLogMessage =  "a \(4)"
//        os_log_send(#dsohandle, OSLog.default, OSLogType.debug, "hey girl! \(4)")
        CLInfo("Testing", "hey girl!! \(4, privacy: .private)")
        print(x)
    }
}
