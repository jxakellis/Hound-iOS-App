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
        UserInformation.userId ?? Constant.Visual.Text.unknownHash
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
    static var defaultReminderRecipientUserIds: [String] {
        FamilyInformation.familyMembers.map { $0.userId }
    }
    static let reminderCustomActionNameCharacterLimit: Int = 32
    static var defaultReminders: [Reminder] {
        [ defaultReminderOne, defaultReminderTwo, defaultReminderThree, defaultReminderFour ]
    }
    private static var defaultReminderOne: Reminder {
        let reminder = Reminder()
        reminder.reminderActionTypeId = 3
        reminder.changeReminderType(.countdown)
        reminder.countdownComponents.executionInterval = Constant.Class.ReminderComponent.defaultCountdownExecutionInterval
        return reminder
    }
    private static var defaultReminderTwo: Reminder {
        let reminder = Reminder()
        reminder.reminderActionTypeId = 1
        reminder.changeReminderType(.weekly)
        // 7:00 AM local time
        return reminder
    }
    private static var defaultReminderThree: Reminder {
        let reminder = Reminder()
        reminder.reminderActionTypeId = 1
        reminder.changeReminderType(.weekly)
        // 12:00 PM
        reminder.weeklyComponents.zonedHour = 11
        return reminder
    }
    private static var defaultReminderFour: Reminder {
        let reminder = Reminder()
        reminder.reminderActionTypeId = 1
        reminder.changeReminderType(.weekly)
        // 5:00 PM
        reminder.weeklyComponents.zonedHour = 17
        return reminder
    }
}

public enum ReminderComponentConstant {
    static let defaultCountdownExecutionInterval: Double = 60 * 60 * 2
    
    static let defaultZonedDay: Int = 1
    static var defaultZonedHour: Int = 7
    static var defaultZonedMinute: Int = 0
}

public enum TriggerConstant {
    static let defaultTriggerType = TriggerType.timeDelay
    static let defaultTriggerTimeDelay: Double = 60 * 30
    static let defaultTriggerFixedTimeType = TriggerFixedTimeType.day
    static let defaultTriggerFixedTimeTypeAmount = 1
    static let defaultTriggerManualCondition = true
    static let defaultTriggerAlarmCreatedCondition = true
    static let defaultTriggerFixedTimeHour = 16
    static let defaultTriggerFixedTimeMinute = 5
    static var defaultTriggers: [Trigger] {
        // forLogActionTypeId 1 == feed
        let logReaction = TriggerLogReaction(forLogActionTypeId: 1, forLogCustomActionName: nil)
        // forReminderActionTypeId 3 == potty
        let reminderResult = TriggerReminderResult(forReminderActionTypeId: 3, forReminderCustomActionName: nil)
        let trigger = Trigger(
            triggerLogReactions: [logReaction],
            triggerReminderResult: reminderResult,
            triggerType: .timeDelay,
            triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 60.0 * 30.0)
        )
        return [trigger]
    }
}

public enum FeedbackConstant {
    static let subscriptionCancellationSuggestionCharacterLimit: Int = 1000
    static let appExperienceSuggestionCharacterLimit: Int = 1000
}
