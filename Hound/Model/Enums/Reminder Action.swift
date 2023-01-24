//
//  Reminder Action.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/27/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ReminderAction: String, CaseIterable {
    
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
    
    /// Returns the name of the current reminderAction with an appropiate emoji appended. If non-nil, non-"" reminderCustomActionName is provided, then then that is returned, e.g. displayActionName(nil, valueDoesNotMatter) -> 'Feed 🍗'; displayActionName(nil, valueDoesNotMatter) -> 'Custom 📝'; displayActionName('someCustomName', true) -> 'someCustomName'; displayActionName('someCustomName', false) -> 'Custom 📝: someCustomName'
    func displayActionName(reminderCustomActionName: String?, isShowingAbreviatedCustomActionName: Bool) -> String {
        switch self {
        case .feed:
            return self.rawValue.appending(" 🍗")
        case .water:
            return self.rawValue.appending(" 💧")
        case .potty:
            return self.rawValue.appending(" 💦💩")
        case .walk:
            return self.rawValue.appending(" 🦮")
        case .brush:
            return self.rawValue.appending(" 💈")
        case .bathe:
            return self.rawValue.appending(" 🛁")
        case .medicine:
            return self.rawValue.appending(" 💊")
        case .sleep:
            return self.rawValue.appending(" 💤")
        case .trainingSession:
            return self.rawValue.appending(" 🐾")
        case .doctor:
            return self.rawValue.appending(" 🩺")
        case .custom:
            if let reminderCustomActionName = reminderCustomActionName, reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                if isShowingAbreviatedCustomActionName == true {
                    return reminderCustomActionName
                }
                else {
                    return self.rawValue.appending(" 📝: \(reminderCustomActionName)")
                }
            }
            else {
                return self.rawValue.appending(" 📝")
            }
        }
    }
}
