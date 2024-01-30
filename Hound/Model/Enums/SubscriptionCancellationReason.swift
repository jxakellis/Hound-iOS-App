//
//  SubscriptionCancellationReason.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum SubscriptionCancellationReason: CaseIterable {
    
    case tooExpensive
    case lackingFeatures
    case betterAlternative
    case puppyGrownUp
    case notUseful
    case tooManyBugs
    case badUpdate
    case other
    
    /// The standardized, internal readable value that corresponds to each case, e.g. "tooExpensive" for .tooExpensive
    var internalValue: String {
        switch self {
        case .tooExpensive:
            return "tooExpensive"
        case .lackingFeatures:
            return "lackingFeatures"
        case .betterAlternative:
            return "betterAlternative"
        case .puppyGrownUp:
            return "puppyGrownUp"
        case .notUseful:
            return "notUseful"
        case .tooManyBugs:
            return "tooManyBugs"
        case .badUpdate:
            return "badUpdate"
        case .other:
            return "other"
        }
    }
    
    /// The readable value that corresponds to each case, e.g. "Too Expensive 💸" for .tooExpensive
    var readableValue: String {
        switch self {
        case .tooExpensive:
            return "Too Expensive 💸"
        case .lackingFeatures:
            return "Lacking Key Features 🛠️"
        case .betterAlternative:
            return "Found Better Alternative 📱"
        case .puppyGrownUp:
            return "Puppy Outgrew App 🐕"
        case .notUseful:
            return "Not Useful 👎"
        case .tooManyBugs:
            return "Too Many Bugs 🪲"
        case .badUpdate:
            return "Update Made Things Worse 💻"
        case .other:
            return "Something Else 📝"
        }
    }
    
}
