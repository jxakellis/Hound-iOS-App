//
//  Log Action.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/27/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogAction: String, CaseIterable, Comparable {
    
    // MARK: - Comparable
    
    static func < (lhs: LogAction, rhs: LogAction) -> Bool {
        let lhsIndex = LogAction.allCases.firstIndex(of: lhs) ?? .max
        let rhsIndex = LogAction.allCases.firstIndex(of: rhs) ?? .max
        
        return lhsIndex <= rhsIndex
    }
    
    // MARK: - Main

    init?(rawValue: String) {
        // regular
        for action in LogAction.allCases where action.rawValue.lowercased() == rawValue.lowercased() {
            self = action
            return
        }

        self = .custom
    }

    case feed = "Feed"
    case water = "Fresh Water"

    case treat = "Treat"

    case pee = "Potty: Pee"
    case poo = "Potty: Poo"
    case both = "Potty: Both"
    case neither = "Potty: Didn't Go"
    case accident = "Accident"

    case walk = "Walk"
    case brush = "Brush"
    case bathe = "Bathe"
    case medicine = "Medicine"
    case weight = "Weight"

    case wakeup = "Wake Up"

    case sleep = "Sleep"

    case crate = "Crate"
    case trainingSession = "Training Session"
    case doctor = "Doctor Visit"

    case custom = "Custom"
    
    var matchingEmoji: String {
        switch self {
        case .feed:
            return "🍗"
        case .water:
            return "🚰"
        case .treat:
            return "🦴"
        case .pee:
            return "💦"
        case .poo:
            return "💩"
        case .both:
            return "🧻"
        case .neither:
            return "🚫"
        case .accident:
            return "🚨"
        case .walk:
            return "🦮"
        case .brush:
            return "💈"
        case .bathe:
            return "🛁"
        case .medicine:
            return "💊"
        case .weight:
            return "⚖️"
        case .wakeup:
            return "☀️"
        case .sleep:
            return "💤"
        case .crate:
            return "🏡"
        case .trainingSession:
            return "🎓"
        case .doctor:
            return "🩺"
        case .custom:
             return "📝"
        }
    }

    /// Returns the name of the current logAction with an appropiate emoji appended. If non-nil, non-"" logCustomActionName is provided, then then that is returned, e.g. displayActionName(nil) -> 'Feed 🍗'; displayActionName(nil) -> 'Custom 📝'; displayActionName('someCustomName', true) -> 'someCustomName'; displayActionName('someCustomName', false) -> 'Custom 📝: someCustomName'
    func displayActionName(logCustomActionName: String?, includeMatchingEmoji: Bool = true) -> String {
        let displayActionNameWithoutEmoji: String = {
            guard self == .custom else {
                return self.rawValue
            }
            
            if let logCustomActionName = logCustomActionName, logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                return logCustomActionName
            }
            
            return self.rawValue
        }()
        
        return includeMatchingEmoji ? displayActionNameWithoutEmoji.appending(" \(self.matchingEmoji)") : displayActionNameWithoutEmoji
    }
}
