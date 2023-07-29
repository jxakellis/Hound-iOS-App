//
//  Log View Mode.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/3/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

private let smallScaleFactor = 0.7
private let mediumScaleFactor = 1.0
private let largeScaleFactor = 1.3

enum LogsInterfaceScale: String, CaseIterable {
    
    init?(rawValue: String) {
        for scale in LogsInterfaceScale.allCases where scale.rawValue == rawValue {
            self = scale
            return
        }
        self = .medium
        return
    }
    
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var currentScaleFactor: Double {
        switch self {
        case .small:
            return smallScaleFactor
        case .medium:
            return mediumScaleFactor
        case .large:
            return largeScaleFactor
        }
    }
}

enum RemindersInterfaceScale: String, CaseIterable {
    
    init?(rawValue: String) {
        for scale in RemindersInterfaceScale.allCases where scale.rawValue == rawValue {
            self = scale
            return
        }
        self = .medium
        return
    }
    
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var currentScaleFactor: Double {
        switch self {
        case .small:
            return smallScaleFactor
        case .medium:
            return mediumScaleFactor
        case .large:
            return largeScaleFactor
        }
    }
}
