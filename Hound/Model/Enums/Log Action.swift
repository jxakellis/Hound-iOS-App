//
//  Log Action.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/27/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogAction: CaseIterable, Comparable {
    
    // MARK: - Comparable
    
    static func < (lhs: LogAction, rhs: LogAction) -> Bool {
        let lhsIndex = LogAction.allCases.firstIndex(of: lhs) ?? .max
        let rhsIndex = LogAction.allCases.firstIndex(of: rhs) ?? .max
        
        return lhsIndex <= rhsIndex
    }
    
    // MARK: - Main

    init?(internalValue: String) {
        // <= 3.1.0 other names used, compare to readableValue as well
        for action in LogAction.allCases where action.internalValue == internalValue || action.readableValue == internalValue {
            self = action
            return
        }

        // <= 3.1.0 other names used
        if internalValue == "Potty: Pee" {
            self = .pee
            return
        }
        else if internalValue == "Potty: Poo" {
            self = .poo
            return
        }
        else if internalValue == "Potty: Both" {
            self = .both
            return
        }
        else if internalValue == "Potty: Didn't Go" {
            self = .neither
            return
        }
        
        return nil
    }

    case feed
    case water

    case treat

    case pee
    case poo
    case both
    case neither
    case accident

    case walk
    case brush
    case bathe
    case medicine
    case weight

    case wakeUp

    case sleep

    case crate
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
        case .treat:
            return LogAndReminderActionConstant.InternalValue.treat.rawValue
        case .pee:
            return LogAndReminderActionConstant.InternalValue.pee.rawValue
        case .poo:
            return LogAndReminderActionConstant.InternalValue.poo.rawValue
        case .both:
            return LogAndReminderActionConstant.InternalValue.both.rawValue
        case .neither:
            return LogAndReminderActionConstant.InternalValue.neither.rawValue
        case .accident:
            return LogAndReminderActionConstant.InternalValue.accident.rawValue
        case .walk:
            return LogAndReminderActionConstant.InternalValue.walk.rawValue
        case .brush:
            return LogAndReminderActionConstant.InternalValue.brush.rawValue
        case .bathe:
            return LogAndReminderActionConstant.InternalValue.bathe.rawValue
        case .medicine:
            return LogAndReminderActionConstant.InternalValue.medicine.rawValue
        case .weight:
            return LogAndReminderActionConstant.InternalValue.weight.rawValue
        case .wakeUp:
            return LogAndReminderActionConstant.InternalValue.wakeUp.rawValue
        case .sleep:
            return LogAndReminderActionConstant.InternalValue.sleep.rawValue
        case .crate:
            return LogAndReminderActionConstant.InternalValue.crate.rawValue
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
        case .treat:
            return LogAndReminderActionConstant.ReadableValue.treat.rawValue
        case .pee:
            return  LogAndReminderActionConstant.ReadableValue.pee.rawValue
        case .poo:
            return  LogAndReminderActionConstant.ReadableValue.poo.rawValue
        case .both:
            return  LogAndReminderActionConstant.ReadableValue.both.rawValue
        case .neither:
            return  LogAndReminderActionConstant.ReadableValue.neither.rawValue
        case .accident:
            return  LogAndReminderActionConstant.ReadableValue.accident.rawValue
        case .walk:
            return  LogAndReminderActionConstant.ReadableValue.walk.rawValue
        case .brush:
            return  LogAndReminderActionConstant.ReadableValue.brush.rawValue
        case .bathe:
            return  LogAndReminderActionConstant.ReadableValue.bathe.rawValue
        case .medicine:
            return  LogAndReminderActionConstant.ReadableValue.medicine.rawValue
        case .weight:
            return  LogAndReminderActionConstant.ReadableValue.weight.rawValue
        case .wakeUp:
            return  LogAndReminderActionConstant.ReadableValue.wakeUp.rawValue
        case .sleep:
            return  LogAndReminderActionConstant.ReadableValue.sleep.rawValue
        case .crate:
            return  LogAndReminderActionConstant.ReadableValue.crate.rawValue
        case .trainingSession:
            return  LogAndReminderActionConstant.ReadableValue.trainingSession.rawValue
        case .doctor:
            return  LogAndReminderActionConstant.ReadableValue.doctor.rawValue
        case .custom:
            return  LogAndReminderActionConstant.ReadableValue.custom.rawValue
        }
    }
    
    /// The readable emoji that corresponds to each case, e.g. 🍗 for .feed
    var readableEmoji: String {
        switch self {
        case .feed:
            return LogAndReminderActionConstant.ReadableEmoji.feed.rawValue
        case .water:
            return LogAndReminderActionConstant.ReadableEmoji.water.rawValue
        case .treat:
            return LogAndReminderActionConstant.ReadableEmoji.treat.rawValue
        case .pee:
            return  LogAndReminderActionConstant.ReadableEmoji.pee.rawValue
        case .poo:
            return  LogAndReminderActionConstant.ReadableEmoji.poo.rawValue
        case .both:
            return  LogAndReminderActionConstant.ReadableEmoji.both.rawValue
        case .neither:
            return  LogAndReminderActionConstant.ReadableEmoji.neither.rawValue
        case .accident:
            return  LogAndReminderActionConstant.ReadableEmoji.accident.rawValue
        case .walk:
            return  LogAndReminderActionConstant.ReadableEmoji.walk.rawValue
        case .brush:
            return  LogAndReminderActionConstant.ReadableEmoji.brush.rawValue
        case .bathe:
            return  LogAndReminderActionConstant.ReadableEmoji.bathe.rawValue
        case .medicine:
            return  LogAndReminderActionConstant.ReadableEmoji.medicine.rawValue
        case .weight:
            return  LogAndReminderActionConstant.ReadableEmoji.weight.rawValue
        case .wakeUp:
            return  LogAndReminderActionConstant.ReadableEmoji.wakeUp.rawValue
        case .sleep:
            return  LogAndReminderActionConstant.ReadableEmoji.sleep.rawValue
        case .crate:
            return  LogAndReminderActionConstant.ReadableEmoji.crate.rawValue
        case .trainingSession:
            return  LogAndReminderActionConstant.ReadableEmoji.trainingSession.rawValue
        case .doctor:
            return  LogAndReminderActionConstant.ReadableEmoji.doctor.rawValue
        case .custom:
            return  LogAndReminderActionConstant.ReadableEmoji.custom.rawValue
        }
    }
    
    /// Returns the name of the current logAction with an appropiate emoji appended. If non-nil, non-"" logCustomActionName is provided, then then that is returned, e.g. fullReadableName(nil) -> 'Feed 🍗'; fullReadableName(nil) -> 'Custom 📝'; fullReadableName('someCustomName', true) -> 'someCustomName'; fullReadableName('someCustomName', false) -> 'Custom 📝: someCustomName'
    func fullReadableName(logCustomActionName: String?, includeMatchingEmoji: Bool = true) -> String {
        let fullReadableNameWithoutEmoji: String = {
            guard self == .custom else {
                return self.readableValue
            }
            
            if let logCustomActionName = logCustomActionName, logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                return logCustomActionName
            }
            
            return self.readableValue
        }()
        
        return includeMatchingEmoji ? fullReadableNameWithoutEmoji.appending(" \(self.readableEmoji)") : fullReadableNameWithoutEmoji
    }
    
    /// If this log type can correspond to some reminder action, returns that type
    var matchingReminderAction: ReminderAction? {
        switch self {
        case .feed:
            return ReminderAction.feed
        case .water:
            return ReminderAction.water
        case .treat:
            return nil
        case .pee:
            return ReminderAction.potty
        case .poo:
            return ReminderAction.potty
        case .both:
            return ReminderAction.potty
        case .neither:
            return ReminderAction.potty
        case .accident:
            return ReminderAction.potty
        case .walk:
            return ReminderAction.walk
        case .brush:
            return ReminderAction.brush
        case .bathe:
            return ReminderAction.bathe
        case .medicine:
            return ReminderAction.medicine
        case .weight:
            return nil
        case .wakeUp:
            return nil
        case .sleep:
            return ReminderAction.sleep
        case .crate:
            return nil
        case .trainingSession:
            return ReminderAction.trainingSession
        case .doctor:
            return ReminderAction.doctor
        case .custom:
            return ReminderAction.custom
        }
    }
}
