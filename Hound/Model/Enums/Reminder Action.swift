//
//  Reminder Action.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/27/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ReminderAction: CaseIterable, Comparable {
    
    // MARK: - Comparable
    
    static func < (lhs: ReminderAction, rhs: ReminderAction) -> Bool {
        let lhsIndex = ReminderAction.allCases.firstIndex(of: lhs) ?? .max
        let rhsIndex = ReminderAction.allCases.firstIndex(of: rhs) ?? .max
        
        return lhsIndex <= rhsIndex
    }
    
    // MARK: - Main

    init?(internalValue: String) {
        // <= 3.1.0 other names used, compare to readableValue as well
        for action in ReminderAction.allCases where action.internalValue == internalValue || action.readableValue == internalValue {
            self = action
            return
        }
        
        return nil
    }
    
    // common
    case feed
    case water
    case potty
    case walk
    // next common
    case brush
    case bathe
    case medicine

    // more common than previous but probably used less by user as weird action
    case sleep
    case trainingSession
    case doctor

    case custom
    
    /// The standardized, internal readable value that corresponds to each case, e.g. "feed" for .feed
    var internalValue: String {
        switch self {
        case .feed:
            return LogAndReminderActionConstant.InternalValue.feed.rawValue
        case .water:
            return LogAndReminderActionConstant.InternalValue.water.rawValue
        case .potty:
            return LogAndReminderActionConstant.InternalValue.potty.rawValue
        case .walk:
            return LogAndReminderActionConstant.InternalValue.walk.rawValue
        case .brush:
            return LogAndReminderActionConstant.InternalValue.brush.rawValue
        case .bathe:
            return LogAndReminderActionConstant.InternalValue.bathe.rawValue
        case .medicine:
            return LogAndReminderActionConstant.InternalValue.medicine.rawValue
        case .sleep:
            return LogAndReminderActionConstant.InternalValue.sleep.rawValue
        case .trainingSession:
            return LogAndReminderActionConstant.InternalValue.trainingSession.rawValue
        case .doctor:
            return LogAndReminderActionConstant.InternalValue.doctor.rawValue
        case .custom:
            return LogAndReminderActionConstant.InternalValue.custom.rawValue
        }
    }
    
    /// The readable value that corresponds to each case, e.g. "Feed" for .feed
    var readableValue: String {
        switch self {
        case .feed:
            return LogAndReminderActionConstant.ReadableValue.feed.rawValue
        case .water:
            return LogAndReminderActionConstant.ReadableValue.water.rawValue
        case .potty:
            return LogAndReminderActionConstant.ReadableValue.potty.rawValue
        case .walk:
            return LogAndReminderActionConstant.ReadableValue.walk.rawValue
        case .brush:
            return LogAndReminderActionConstant.ReadableValue.brush.rawValue
        case .bathe:
            return LogAndReminderActionConstant.ReadableValue.bathe.rawValue
        case .medicine:
            return LogAndReminderActionConstant.ReadableValue.medicine.rawValue
        case .sleep:
            return LogAndReminderActionConstant.ReadableValue.sleep.rawValue
        case .trainingSession:
            return LogAndReminderActionConstant.ReadableValue.trainingSession.rawValue
        case .doctor:
            return LogAndReminderActionConstant.ReadableValue.doctor.rawValue
        case .custom:
            return LogAndReminderActionConstant.ReadableValue.custom.rawValue
        }
    }
    
    /// The readable emoji that corresponds to each case, e.g. 🍗 for .feed
    var readableEmoji: String {
        switch self {
        case .feed:
            return LogAndReminderActionConstant.ReadableEmoji.feed.rawValue
        case .water:
            return LogAndReminderActionConstant.ReadableEmoji.water.rawValue
        case .potty:
            return LogAndReminderActionConstant.ReadableEmoji.potty.rawValue
        case .walk:
            return LogAndReminderActionConstant.ReadableEmoji.walk.rawValue
        case .brush:
            return LogAndReminderActionConstant.ReadableEmoji.brush.rawValue
        case .bathe:
            return LogAndReminderActionConstant.ReadableEmoji.bathe.rawValue
        case .medicine:
            return LogAndReminderActionConstant.ReadableEmoji.medicine.rawValue
        case .sleep:
            return LogAndReminderActionConstant.ReadableEmoji.sleep.rawValue
        case .trainingSession:
            return LogAndReminderActionConstant.ReadableEmoji.trainingSession.rawValue
        case .doctor:
            return LogAndReminderActionConstant.ReadableEmoji.doctor.rawValue
        case .custom:
            return LogAndReminderActionConstant.ReadableEmoji.custom.rawValue
        }
    }

    /// Returns the name of the current reminderAction with an appropiate emoji appended. If non-nil, non-"" reminderCustomActionName is provided, then then that is returned, e.g. fullReadableName(nil, valueDoesNotMatter) -> 'Feed 🍗'; fullReadableName(nil, valueDoesNotMatter) -> 'Custom 📝'; fullReadableName('someCustomName', true) -> 'someCustomName'; fullReadableName('someCustomName', false) -> 'Custom 📝: someCustomName'
    func fullReadableName(reminderCustomActionName: String?, includeMatchingEmoji: Bool = true) -> String {
        let fullReadableNameWithoutEmoji: String = {
            guard self == .medicine || self == .custom else {
                return self.readableValue
            }
            
            if let reminderCustomActionName = reminderCustomActionName, reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                return reminderCustomActionName
            }
            
            return self.readableValue
        }()
        
        return includeMatchingEmoji ? fullReadableNameWithoutEmoji.appending(" \(self.readableEmoji)") : fullReadableNameWithoutEmoji
    }

}
