//
//  HoundLogger.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import os.log
import UIKit

struct HoundLogger {
    static var general = HoundLogger(subsystem: "com.example.Pupotty", category: "General")
    static var lifecycle = HoundLogger(subsystem: "com.example.Pupotty", category: "Life Cycle")
    static var apiRequest  = HoundLogger(subsystem: "com.example.Pupotty", category: "API Request")
    static var apiResponse = HoundLogger(subsystem: "com.example.Pupotty", category: "API Response")
    
    private let logger: Logger
    private let category: String
    private let forwardToLogger: Bool = false
    
    init(subsystem: String, category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.category = category
    }
    
    private static let timeFormat: HoundDateFormat = .template("HH:mm:ss")
    
    private func formattedMessage(_ message: String) -> String {
        let time = Date().houndFormatted(Self.timeFormat, displayTimeZone: TimeZone.current)
        return "\(time) [\(category)] \(message)"
    }
    
    func notice(_ message: String) {
        let formatted = formattedMessage(message)
        print(formatted)
        if forwardToLogger {
            logger.notice("\(message)")
        }
    }
    
    func debug(_ message: String) {
        let formatted = formattedMessage(message)
        print(formatted)
        if forwardToLogger {
            logger.debug("\(message)")
        }
    }
    
    func error(_ message: String) {
        let formatted = formattedMessage(message)
        print(formatted)
        if forwardToLogger {
            logger.error("\(message)")
        }
    }
    
    func fault(_ message: String) {
        let formatted = formattedMessage(message)
        print(formatted)
        if forwardToLogger {
            logger.fault("\(message)")
        }
    }
    
    func warning(_ message: String) {
        let formatted = formattedMessage(message)
        print(formatted)
        if forwardToLogger {
            logger.log(level: .default, "\(message)")
        }
    }
}
