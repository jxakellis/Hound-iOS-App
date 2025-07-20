//
//  Dog Constants.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

public enum ClassConstant {
    public typealias Dog = DogConstant
    public typealias Log = LogConstant
    public typealias Reminder = ReminderConstant
    public typealias ReminderComponent = ReminderComponentConstant
    public typealias Trigger = TriggerConstant
    public typealias Date = DateConstant
    public typealias Feedback = FeedbackConstant
    public typealias Subscription = SubscriptionConstant
}

public enum SubscriptionConstant {
    static var defaultSubscription: Subscription {
        Subscription(
            forTransactionId: nil,
            forProductId: defaultProductId,
            forPurchaseDate: nil,
            forExpiresDate: nil,
            forNumberOfFamilyMembers: defaultSubscriptionNumberOfFamilyMembers,
            forIsActive: true,
            forAutoRenewStatus: true,
            forAutoRenewProductId: defaultProductId)
    }
    static let defaultSubscriptionNumberOfFamilyMembers = 1
    static let defaultSubscriptionSpelledOutNumberOfFamilyMembers = "one"
    static let defaultProductId = "com.jonathanxakellis.hound.default"
}

public enum DogConstant {
    static let defaultDogName: String = "Bella"

    static let dogNameCharacterLimit: Int = 32
    // IMPORTANT: If you modify this value, change the value on Hound server's globalConstant LIMIT
    static let maximumNumberOfDogs = 10
    // IMPORTANT: If you modify this value, change the value on Hound server's globalConstant LIMIT
    static let maximumNumberOfLogs = 100000
    // IMPORTANT: If you modify this value, change the value on Hound server's globalConstant LIMIT
    static let maximumNumberOfReminders = 25
    // IMPORTANT: If you modify this value, change the value on Hound server's globalConstant LIMIT
    static let maximumNumberOfTriggers = 25
}

public enum LogConstant {
    static var defaultUserId: String {
        UserInformation.userId ?? Constant.VisualText.unknownHash
    }
    static let defaultLogActionTypeId = 1
    static var defaultLogStartDate: Date { Date() }
    static let logCustomActionNameCharacterLimit: Int = 32
    static let logNoteCharacterLimit: Int = 500
}

public enum ReminderConstant {
    static let defaultReminderActionTypeId = 1
    static let defaultReminderType = ReminderType.countdown
    static var defaultReminderExecutionBasis: Date { Date() }
    static let defaultReminderIsEnabled = true
    static let reminderCustomActionNameCharacterLimit: Int = 32
    static var defaultReminders: [Reminder] {
        [ defaultReminderOne, defaultReminderTwo, defaultReminderThree, defaultReminderFour ]
    }
    private static var defaultReminderOne: Reminder {
        let reminder = Reminder()
        reminder.reminderActionTypeId = 3
        reminder.changeReminderType(forReminderType: .countdown)
        reminder.countdownComponents.executionInterval = Constant.Class.ReminderComponent.defaultCountdownExecutionInterval
        return reminder
    }
    private static var defaultReminderTwo: Reminder {
        let reminder = Reminder()
        reminder.reminderActionTypeId = 1
        reminder.changeReminderType(forReminderType: .weekly)
        // 7:00 AM local time
        return reminder
    }
    private static var defaultReminderThree: Reminder {
        let reminder = Reminder()
        reminder.reminderActionTypeId = 1
        reminder.changeReminderType(forReminderType: .weekly)
        var date = reminder.reminderExecutionDate ?? DateConstant.default1970Date
        // 12:00 PM local time
        date = Calendar.current.date(byAdding: .hour, value: 5, to: date) ?? DateConstant.default1970Date
        reminder.weeklyComponents.changeUTCHour(forDate: date)
        reminder.weeklyComponents.changeUTCMinute(forDate: date)
        return reminder
    }
    private static var defaultReminderFour: Reminder {
        let reminder = Reminder()
        reminder.reminderActionTypeId = 1
        reminder.changeReminderType(forReminderType: .weekly)
        var date = reminder.reminderExecutionDate ?? DateConstant.default1970Date
        // 5:00 PM local time
        date = Calendar.current.date(byAdding: .hour, value: 10, to: date) ?? DateConstant.default1970Date
        reminder.weeklyComponents.changeUTCHour(forDate: date)
        reminder.weeklyComponents.changeUTCMinute(forDate: date)
        return reminder
    }
}

public enum ReminderComponentConstant {
    static let defaultCountdownExecutionInterval: Double = 60 * 60 * 2

    static let defaultUTCDay: Int = 1

    /// Hour 7 of the day in the user's local time zone, but adjusted so that hour 7 is in UTC hours (e.g. UTC-5 so localHour is 7 and UTCHour is 12)
    static var defaultUTCHour: Int {
        // We want hour 7 of the day in the users local timezone
        let defaultLocalHour = 7
        let hoursFromUTC = TimeZone.current.secondsFromGMT() / 3600

        // UTCHour + hoursFromUTC = localHour
        // UTCHour = localHour - hoursFromUTC

        var UTCHour = defaultLocalHour - hoursFromUTC
        // UTCHour could be negative, so roll over into positive
        UTCHour += 24
        // Make sure UTCHour [0, 23]
        UTCHour = UTCHour % 24

        return UTCHour
    }

    /// Minute 0 of the hour in the user's local time zone, but adjusted so that minute 0  is in UTC hours (e.g. UTC-0:30 so localMinute is 0 and UTCMinute is 30)
    static var defaultUTCMinute: Int {
        let defaultLocalMinute = 0
        let minutesFromUTC = (TimeZone.current.secondsFromGMT() % 3600) / 60

        // UTCMinute + minutesFromUTC = localMinute
        // UTCMinute = localMinute - minutesFromUTC

        var UTCMinute = defaultLocalMinute - minutesFromUTC
        // UTCMinute could be negative, so roll over into positive
        UTCMinute += 60
        // Make sure UTCMinute [0, 59]
        UTCMinute = UTCMinute % 60

        return UTCMinute
    }
}

public enum TriggerConstant {
    static let defaultTriggerType = TriggerType.timeDelay
    static let defaultTriggerTimeDelay: Double = 60 * 30
    static let defaultTriggerFixedTimeType = TriggerFixedTimeType.day
    static let defaultTriggerFixedTimeTypeAmount = 1
    static let defaultTriggers: [Trigger] = []
}

public enum DateConstant {
    static let default1970Date = Date(timeIntervalSince1970: 0.0)
}

public enum FeedbackConstant {
    static let subscriptionCancellationSuggestionCharacterLimit: Int = 1000
    static let appExperienceSuggestionCharacterLimit: Int = 1000
}
