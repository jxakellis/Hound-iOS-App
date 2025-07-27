//
//  TimeIntervalExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension TimeInterval {
    enum AbbreviationLevel {
        case short   // e.g. "5s"
        case medium  // e.g. "5 sec"
        case long    // e.g. "5 seconds"
    }
    
    /**
     Converts a `TimeInterval` to a human-readable string.
     
     - Parameters:
     - capitalizeWords: If `true`, capitalizes the first letter of each time component.
     - abbreviationLevel: The abbreviation level to use (`.short`, `.medium`, or `.long`).
     - maxComponents: The maximum number of time components to display (e.g., 2 → "3 days 5 hours").
     
     - Examples:
     - `interval.readable(abbreviationLevel: .short, maxComponents: 2)` → `"2d 4h"`
     - `interval.readable(abbreviationLevel: .medium)` → `"2 days 4 hrs"`
     - `interval.readable(abbreviationLevel: .long, maxComponents: 3)` → `"2 days 4 hours 48 minutes"`
     - `interval.readable(capitalizeWords: true, abbreviationLevel: .long)` → `"2 Days 4 Hours"`
     */
    func readable(
        capitalizeWords: Bool = false,
        abbreviationLevel: AbbreviationLevel = .medium,
        maxComponents: Int? = nil
    ) -> String {
        let totalSeconds = abs(Int(self.rounded()))
        let units: [(value: Int, short: String, medium: String, long: String)] = [
            (totalSeconds / 604800, "w", "wk", "week"),                      // weeks
            ((totalSeconds % 604800) / 86400, "d", "day", "day"),           // days
            ((totalSeconds % 86400) / 3600, "h", "hr", "hour"),             // hours
            ((totalSeconds % 3600) / 60, "m", "min", "minute"),             // minutes
            (totalSeconds % 60, "s", "sec", "second")                       // seconds
        ]
        
        var components: [String] = []
        var usedComponents = 0
        
        for (value, short, medium, long) in units {
            if let maxComponents = maxComponents {
                guard usedComponents < maxComponents else { break }
            }
            guard value > 0 || components.isEmpty else { continue } // Always show at least one unit
            
            let label: String
            switch abbreviationLevel {
            case .short:
                label = "\(value)\(short)"
            case .medium:
                let base = medium
                let plural = value == 1 ? base : "\(base)s"
                label = "\(value) \(plural)"
            case .long:
                let base = long
                let plural = value == 1 ? base : "\(base)s"
                label = "\(value) \(plural)"
            }
            
            let finalLabel = capitalizeWords
            ? label.capitalized
            : label.lowercased()
            
            components.append(finalLabel)
            usedComponents += 1
        }
        
        // Short form should have no space between number and unit (e.g., 5s)
        return components.joined(separator: " ")
    }
}

