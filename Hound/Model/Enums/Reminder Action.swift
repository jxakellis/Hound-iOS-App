//
//  Reminder Action.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/27/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ReminderAction: String, CaseIterable, Comparable {
    
    // MARK: - Comparable
    
    static func < (lhs: ReminderAction, rhs: ReminderAction) -> Bool {
        let lhsIndex = ReminderAction.allCases.firstIndex(of: lhs) ?? .max
        let rhsIndex = ReminderAction.allCases.firstIndex(of: rhs) ?? .max
        
        return lhsIndex <= rhsIndex
    }
    
    // MARK: - Main

    init?(rawValue: String) {
        for action in ReminderAction.allCases where action.rawValue.lowercased() == rawValue.lowercased() {
            self = action
            return
        }

        self = ReminderAction.feed
        return
    }
    // common
    case feed = "Feed"
    case water = "Fresh Water"
    case potty = "Potty"
    case walk = "Walk"
    // next common
    case brush = "Brush"
    case bathe = "Bathe"
    case medicine = "Medicine"

    // more common than previous but probably used less by user as weird action
    case sleep = "Sleep"
    case trainingSession = "Training Session"
    case doctor = "Doctor Visit"

    case custom = "Custom"
    
    var readableEmoji: String {
        switch self {
        case .feed:
            return "🍗"
        case .water:
            return "🚰"
        case .potty:
            return "🚽"
        case .walk:
            return "🦮"
        case .brush:
            return "💈"
        case .bathe:
            return "🛁"
        case .medicine:
            return "💊"
        case .sleep:
            return "💤"
        case .trainingSession:
            return "🎓"
        case .doctor:
            return "🩺"
        case .custom:
             return "📝"
        }
    }

    /// Returns the name of the current reminderAction with an appropiate emoji appended. If non-nil, non-"" reminderCustomActionName is provided, then then that is returned, e.g. fullReadableName(nil, valueDoesNotMatter) -> 'Feed 🍗'; fullReadableName(nil, valueDoesNotMatter) -> 'Custom 📝'; fullReadableName('someCustomName', true) -> 'someCustomName'; fullReadableName('someCustomName', false) -> 'Custom 📝: someCustomName'
    func fullReadableName(reminderCustomActionName: String?, includeMatchingEmoji: Bool = true) -> String {
        let fullReadableNameWithoutEmoji: String = {
            guard self == .custom else {
                return self.rawValue
            }
            
            if let reminderCustomActionName = reminderCustomActionName, reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                return reminderCustomActionName
            }
            
            return self.rawValue
        }()
        
        return includeMatchingEmoji ? fullReadableNameWithoutEmoji.appending(" \(self.readableEmoji)") : fullReadableNameWithoutEmoji
    }

}
