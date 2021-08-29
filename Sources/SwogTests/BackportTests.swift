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

func randomAlphaNumericString(length: Int) -> String {
    let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.count)
    var randomString = ""

    for _ in 0 ..< length {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
        let newCharacter = allowedChars[randomIndex]
        randomString += String(newCharacter)
    }

    return randomString
}

class BackportTests: XCTestCase {
    func testBasicUsage() {
        CLInfo("Testing", "hey girl!! \(4, privacy: .private)")
    }
    
    func withLoggingDrivers<P>(_ drivers: [LoggingDriver], _ cb: () throws -> P) rethrows -> P {
        let oldDrivers = LoggingDrivers
        LoggingDrivers = drivers
        defer { LoggingDrivers = oldDrivers }
        return try cb()
    }
    
    func testConsolePerformance() {
        LoggingDrivers = [ConsoleDriver()]
        
        let numbers = 0..<100
        let strings = (0..<100).map { _ in randomAlphaNumericString(length: (10..<20).randomElement()!) }
        
        let measureOptions = XCTMeasureOptions()
        measureOptions.iterationCount = 100
        
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric(), XCTClockMetric()], options: measureOptions) {
            CLInfo("BackportTests", "Hey world! It's \(strings.randomElement()!) and \(numbers.randomElement()!)")
        }
    }
    
    func testOSLogPerformance() {
        LoggingDrivers = [OSLogDriver()]
        
        let numbers = 0..<100
        let strings = (0..<100).map { _ in randomAlphaNumericString(length: (10..<20).randomElement()!) }
        
        let measureOptions = XCTMeasureOptions()
        measureOptions.iterationCount = 100
        
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric(), XCTClockMetric()], options: measureOptions) {
            CLInfo("BackportTests", "Hey world! It's \(strings.randomElement()!) and \(numbers.randomElement()!)")
        }
    }
    
    func testDuplexDriverPerformance() {
        LoggingDrivers = [OSLogDriver(), ConsoleDriver()]
        
        let numbers = 0..<100
        let strings = (0..<100).map { _ in randomAlphaNumericString(length: (10..<20).randomElement()!) }
        
        let measureOptions = XCTMeasureOptions()
        measureOptions.iterationCount = 100
        
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric(), XCTClockMetric()], options: measureOptions) {
            CLInfo("BackportTests", "Hey world! It's \(strings.randomElement()!) and \(numbers.randomElement()!)")
        }
    }
}
