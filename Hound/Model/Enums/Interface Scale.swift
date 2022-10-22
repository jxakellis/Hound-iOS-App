//
//  Log View Mode.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

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
            return 0.85
        case .medium:
            return 1.2
        case .large:
            return 1.55
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
            return 0.85
        case .medium:
            return 1.2
        case .large:
            return 1.55
        }
    }
}
