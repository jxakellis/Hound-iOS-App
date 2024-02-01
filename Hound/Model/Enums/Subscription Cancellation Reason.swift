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
    case lackingKeyFeatures
    case foundBetterAlternative
    case puppyOutgrewApp
    case notUseful
    case tooManyBugs
    case updateMadeThingsWorse
    case somethingElse
    
    /// The standardized, internal readable value that corresponds to each case, e.g. "tooExpensive" for .tooExpensive
    var internalValue: String {
        switch self {
        case .tooExpensive:
            return "tooExpensive"
        case .lackingKeyFeatures:
            return "lackingKeyFeatures"
        case .foundBetterAlternative:
            return "foundBetterAlternative"
        case .puppyOutgrewApp:
            return "puppyOutgrewApp"
        case .notUseful:
            return "notUseful"
        case .tooManyBugs:
            return "tooManyBugs"
        case .updateMadeThingsWorse:
            return "updateMadeThingsWorse"
        case .somethingElse:
            return "somethingElse"
        }
    }
    
    /// The readable value that corresponds to each case, e.g. "Too Expensive 💸" for .tooExpensive
    var readableValue: String {
        switch self {
        case .tooExpensive:
            return "Too Expensive 💸"
        case .lackingKeyFeatures:
            return "Lacking Key Features 🛠️"
        case .foundBetterAlternative:
            return "Found Better Alternative 📱"
        case .puppyOutgrewApp:
            return "Puppy Outgrew App 🐕"
        case .notUseful:
            return "Not Useful 👎"
        case .tooManyBugs:
            return "Too Many Bugs 🪲"
        case .updateMadeThingsWorse:
            return "Update Made Things Worse 💻"
        case .somethingElse:
            return "Something Else 📝"
        }
    }
    
}
