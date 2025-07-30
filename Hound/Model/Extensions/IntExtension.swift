//
//  IntExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/24/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension Int {
    /// Takes the given day of month and appends an appropiate suffix of st, nd, rd, or th, e.g. 31 returns st, 20 returns th, 2 returns nd
    func daySuffix() -> String {
        switch self {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
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
        return Double(self).readable(capitalizeWords: capitalizeWords, abbreviationLevel: abbreviationLevel, maxComponents: maxComponents, enforceSequentialComponents: enforceSequentialComponents)
    }
}
