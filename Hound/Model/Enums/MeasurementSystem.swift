//
//  MeasurementSystem.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum MeasurementSystem: Int, CaseIterable {
    
    init?(rawValue: Int) {
        for system in MeasurementSystem.allCases where system.rawValue == rawValue {
            self = system
            return
        }
        
        return nil
    }
    
    case imperial = 0
    case metric = 1
    case both = 2
    
    func readableMeasurementSystem() -> String {
        switch self {
        case .imperial:
            return "Imperial"
        case .metric:
            return "Metric"
        case .both:
            return "Both"
        }
    }
    
}
