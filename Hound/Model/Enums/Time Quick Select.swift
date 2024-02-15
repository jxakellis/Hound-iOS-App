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
    
    /// Returns how many seconds ago the TimeQuickSelectOptions represents. .now represents 0.0 seconds ago, .fiveMinsAgo represents -300.0 seconds ago, and .custom represents nil
    func convertToDouble() -> Double? {
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
