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

    init(internalValue: String) {
        // <= 3.2.0 other names used, compare to readableValue as well
        for action in LogAction.allCases where action.internalValue == internalValue || action.readableValue == internalValue {
            self = action
            return
        }

        // <= 3.2.0 other names used
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
        
        self = .custom
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
            return "feed"
        case .water:
            return "water"
        case .treat:
            return "treat"
        case .pee:
            return "pee"
        case .poo:
            return "poo"
        case .both:
            return "both"
        case .neither:
            return "neither"
        case .accident:
            return "accident"
        case .walk:
            return "walk"
        case .brush:
            return "brush"
        case .bathe:
            return "bathe"
        case .medicine:
            return "medicine"
        case .weight:
            return "weight"
        case .wakeUp:
            return "wakeUp"
        case .sleep:
            return "sleep"
        case .crate:
            return "crate"
        case .trainingSession:
            return "trainingSession"
        case .doctor:
            return "doctor"
        case .custom:
            return "custom"
        }
    }
    
    /// The readable value that corresponds to each case, e.g. "Feed" for .feed
    var readableValue: String {
        switch self {
        case .feed:
            return "Feed"
        case .water:
            return "Fresh Water"
        case .treat:
            return "Treat"
        case .pee:
            return "Pee"
        case .poo:
            return "Poo"
        case .both:
            return "Pee & Poo"
        case .neither:
            return "Didn't Go Potty"
        case .accident:
            return "Accident"
        case .walk:
            return "Walk"
        case .brush:
            return "Brush"
        case .bathe:
            return "Bathe"
        case .medicine:
            return "Medicine"
        case .weight:
            return "Weight"
        case .wakeup:
            return "Wake Up"
        case .sleep:
            return "Sleep"
        case .crate:
            return "Crate"
        case .trainingSession:
            return "Training Session"
        case .doctor:
            return "Doctor Visit"
        case .custom:
            return "Custom"
        }
    }
    
    /// The readable emoji that corresponds to each case, e.g. 🍗 for .feed
    var readableEmoji: String {
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
}
