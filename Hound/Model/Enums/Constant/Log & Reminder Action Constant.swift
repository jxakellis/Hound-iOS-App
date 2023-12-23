//
//  Log & Reminder Action Constant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 12/22/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogAndReminderActionConstant {
    /// The standardized, internal readable value that corresponds to each case, e.g. "feed" for .feed
    enum InternalValue: String {
        case feed = "feed"
        case water = "water"
        case treat = "treat"
        case potty = "potty"
        case pee = "pee"
        case poo = "poo"
        case both = "both"
        case neither = "neither"
        case accident = "accident"
        case walk = "walk"
        case brush = "brush"
        case bathe = "bathe"
        case medicine = "medicine"
        case weight = "weight"
        case wakeUp = "wakeUp"
        case sleep = "sleep"
        case crate = "crate"
        case trainingSession = "trainingSession"
        case doctor = "doctor"
        case custom = "custom"
    }
    
    /// The readable value that corresponds to each case, e.g. "Feed" for .feed
    enum ReadableValue: String {
        case feed = "Feed"
        case water = "Fresh Water"
        case treat = "Treat"
        case potty = "Potty"
        case pee = "Pee"
        case poo = "Poo"
        case both = "Pee & Poo"
        case neither = "Didn't Go Potty"
        case accident = "Accident"
        case walk = "Walk"
        case brush = "Brush"
        case bathe = "Bathe"
        case medicine = "Medicine"
        case weight = "Weight"
        case wakeUp = "Wake Up"
        case sleep = "Sleep"
        case crate = "Crate"
        case trainingSession = "Training Session"
        case doctor = "Doctor Visit"
        case custom = "Custom"
    }
    
    /// The readable emoji that corresponds to each case, e.g. 🍗 for .feed
    enum ReadableEmoji: String {
        case feed = "🍗"
        case water = "🚰"
        case treat = "🦴"
        case potty = "🚽"
        case pee = "💦"
        case poo = "💩"
        case both = "🧻"
        case neither = "🚫"
        case accident = "🚨"
        case walk = "🦮"
        case brush = "💈"
        case bathe = "🛁"
        case medicine = "💊"
        case weight = "⚖️"
        case wakeUp = "☀️"
        case sleep = "💤"
        case crate = "🏡"
        case trainingSession = "🎓"
        case doctor = "🩺"
        case custom = "📝"
    }
}
