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
       - maxComponents: The maximum number of time components to display.
       - enforceSequentialComponents: If `true`, only display adjacent nonzero time units (e.g., "2h 5m", never "2h 0m").
     */
    func readable(
        capitalizeWords: Bool = false,
        abbreviationLevel: AbbreviationLevel = .medium,
        maxComponents: Int? = nil,
        enforceSequentialComponents: Bool = false
    ) -> String {
        
        // Convert total seconds to absolute integer value for easier processing
        let totalSeconds = abs(Int(self.rounded()))
        
        // Split into time units (weeks, days, hours, minutes, seconds)
        let units: [(value: Int, short: String, medium: String, long: String)] = [
            (totalSeconds / 604800, "w", "wk", "week"),                         // weeks
            ((totalSeconds % 604800) / 86400, "d", "day", "day"),               // days
            ((totalSeconds % 86400) / 3600, "h", "hr", "hour"),                 // hours
            ((totalSeconds % 3600) / 60, "m", "min", "minute"),                 // minutes
            (totalSeconds % 60, "s", "sec", "second")                           // seconds
        ]
        
        // Helper function to format a single unit string according to abbreviation style
        func formattedUnit(value: Int, short: String, medium: String, long: String) -> String {
            switch abbreviationLevel {
            case .short:
                return "\(value)\(short)"
            case .medium:
                return "\(value) \(value == 1 ? medium : "\(medium)s")"
            case .long:
                return "\(value) \(value == 1 ? long : "\(long)s")"
            }
        }
        
        var components: [String] = []
        
        if enforceSequentialComponents {
            // Find the first nonzero unit (e.g., first is hours for 1h 5m)
            guard let firstNonzeroIndex = units.firstIndex(where: { $0.value > 0 }) else {
                // All components are zero, show "0 seconds" in selected abbreviation style
                return formattedUnit(value: 0, short: "s", medium: "sec", long: "second")
            }
            
            let maxSequential = maxComponents ?? units.count
            var sequentialCount = 0
            
            // Only add consecutive nonzero units after the first, stop if a zero is found
            for i in firstNonzeroIndex..<units.count {
                let (value, short, medium, long) = units[i]
                if value == 0 { break }
                components.append(formattedUnit(value: value, short: short, medium: medium, long: long))
                sequentialCount += 1
                if sequentialCount >= maxSequential { break }
            }
        }
        else {
            // Collect up to maxComponents nonzero units, regardless of adjacency
            var nonzeroCount = 0
            for (value, short, medium, long) in units {
                guard value > 0 else { continue }
                if let maxComponents, nonzeroCount >= maxComponents { break }
                components.append(formattedUnit(value: value, short: short, medium: medium, long: long))
                nonzeroCount += 1
            }
            // If all components are zero, return "0 seconds" (or the equivalent)
            if components.isEmpty {
                return formattedUnit(value: 0, short: "s", medium: "sec", long: "second")
            }
        }
        
        // Apply capitalization if needed, then join with spaces
        return components
            .map { capitalizeWords ? $0.capitalized : $0.lowercased() }
            .joined(separator: " ")
    }
}
