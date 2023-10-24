//
//  Log Action.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/27/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogAction: String, CaseIterable {

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

    /// Returns the name of the current logAction with an appropiate emoji appended. If non-nil, non-"" logCustomActionName is provided, then then that is returned, e.g. displayActionName(nil) -> 'Feed 🍗'; displayActionName(nil) -> 'Custom 📝'; displayActionName('someCustomName', true) -> 'someCustomName'; displayActionName('someCustomName', false) -> 'Custom 📝: someCustomName'
    func displayActionName(logCustomActionName: String?) -> String {
        switch self {
        case .feed:
            return self.rawValue.appending(" 🍗")
        case .water:
            return self.rawValue.appending(" 💧")
        case .treat:
            return self.rawValue.appending(" 🦴")
        case .pee:
            return self.rawValue.appending(" 💦")
        case .poo:
            return self.rawValue.appending(" 💩")
        case .both:
            return self.rawValue.appending(" 💦💩")
        case .neither:
            return self.rawValue.appending(" ❌")
        case .accident:
            return self.rawValue.appending(" ⚠️")
        case .walk:
            return self.rawValue.appending(" 🦮")
        case .brush:
            return self.rawValue.appending(" 💈")
        case .bathe:
            return self.rawValue.appending(" 🛁")
        case .medicine:
            return self.rawValue.appending(" 💊")
        case .weight:
            return self.rawValue.appending(" ⚖️")
        case .wakeup:
            return self.rawValue.appending(" ☀️")
        case .sleep:
            return self.rawValue.appending(" 💤")
        case .crate:
            return self.rawValue.appending(" 🏡")
        case .trainingSession:
            return self.rawValue.appending(" 🐾")
        case .doctor:
            return self.rawValue.appending(" 🩺")
        case .custom:
            if let logCustomActionName = logCustomActionName, logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                return "\(logCustomActionName) 📝"
            }
            else {
                return self.rawValue.appending(" 📝")
            }
        }
    }
}
