//
//  Time Quick Select.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/17/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum TimeQuickSelectOptions: String, CaseIterable {
    case custom = "Custom"
    case now = "Now"
    case fiveMinsAgo = "5 mins ago"
    case fifteenMinsAgo = "15 mins ago"
    case thirtyMinsAgo = "30 mins ago"
    case oneHourAgo = "1 hr ago"
    case twoHoursAgo = "2 hrs ago"
    case fourHoursAgo = "4 hrs ago"
    case eightHoursAgo = "8 hrs ago"
    
    /// Given a forReferenceDate, finds all of the TimeQuickSelectOptions where startingPoint + valueInSeconds is < occurringOnOrBefore
    static func optionsOccurringBeforeDate(startingPoint: Date, occurringOnOrBefore: Date) -> [TimeQuickSelectOptions] {
        return TimeQuickSelectOptions.allCases.filter { timeQuickSelectOption in
            guard let valueInSeconds = timeQuickSelectOption.valueInSeconds() else {
                // If timeQuickSelectOption has no valueInSeconds, then assume it is a valid option (e.g. .custom)
                return true
            }
            
            // Important that this is a <= comparision. If you provide Date() for startingPoint and occurringOnOrBefore, then it isn't deterministic. Sometimes the Dates()s are the exact same, and sometimes they are off by a few microseconds.
            return startingPoint.addingTimeInterval(valueInSeconds) <= occurringOnOrBefore
        }
    }
    
    /// Given a forReferenceDate, finds all of the TimeQuickSelectOptions where startingPoint + valueInSeconds is > occurringOnOrBefore
    static func optionsOccurringAfterDate(startingPoint: Date, occurringOnOrAfter: Date) -> [TimeQuickSelectOptions] {
        return TimeQuickSelectOptions.allCases.filter { timeQuickSelectOption in
            guard let valueInSeconds = timeQuickSelectOption.valueInSeconds() else {
                // If timeQuickSelectOption has no valueInSeconds, then assume it is a valid option (e.g. .custom)
                return true
            }
            
            // Important that this is a >= comparision. If you provide Date() for startingPoint and occurringOnOrAfter, then it isn't deterministic. Sometimes the Dates()s are the exact same, and sometimes they are off by a few microseconds.
            return startingPoint.addingTimeInterval(valueInSeconds) >= occurringOnOrAfter
        }
    }
    
    /// Returns how many seconds ago the TimeQuickSelectOptions represents. .now represents 0.0 seconds ago, .fiveMinsAgo represents -300.0 seconds ago, and .custom represents nil
    func valueInSeconds() -> Double? {
        switch self {
        case .now:
            return -1.0 * 0.0
        case .fiveMinsAgo:
            return -1.0 * 60.0 * 5.0
        case .fifteenMinsAgo:
            return -1.0 * 60.0 * 15.0
        case .thirtyMinsAgo:
            return -1.0 * 60.0 * 30.0
        case .oneHourAgo:
            return -1.0 * 60.0 * 60.0 * 1.0
        case .twoHoursAgo:
            return -1.0 * 60.0 * 60.0 * 2.0
        case .fourHoursAgo:
            return -1.0 * 60.0 * 60.0 * 4.0
        case .eightHoursAgo:
            return -1.0 * 60.0 * 60.0 * 8.0
        case .custom:
            return nil
        }
    }
}
