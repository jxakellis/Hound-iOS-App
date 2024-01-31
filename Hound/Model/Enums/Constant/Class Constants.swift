//
//  Dog Constants.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ClassConstant {

    enum SubscriptionConstant {
        static var defaultSubscription: Subscription {
            Subscription(
                transactionId: nil,
                productId: defaultProductId,
                purchaseDate: nil,
                expiresDate: nil,
                numberOfFamilyMembers: defaultSubscriptionNumberOfFamilyMembers,
                isActive: true,
                autoRenewStatus: true,
                autoRenewProductId: defaultProductId)
        }
        static let defaultSubscriptionNumberOfFamilyMembers = 1
        static let defaultSubscriptionSpelledOutNumberOfFamilyMembers = "one"
        static let defaultProductId = "com.jonathanxakellis.hound.default"
    }

    enum DogConstant {
        static let defaultDogName: String = "Bella"
        static let defaultDogIcon: UIImage = whitePawWithHands
        static let whitePawWithHands: UIImage = UIImage.init(named: "whitePawWithHands") ?? UIImage()
        static let blackPawWithHands: UIImage = UIImage.init(named: "blackPawWithHands") ?? UIImage()

        static let defaultDogId: Int = -1

        static let dogNameCharacterLimit: Int = 32
        // IMPORTANT: If you modify this value, change the value on Hound server's globalConstant LIMIT
        static let maximumNumberOfDogs = 10
        // IMPORTANT: If you modify this value, change the value on Hound server's globalConstant LIMIT
        static let maximumNumberOfLogs = 50000
        // IMPORTANT: If you modify this value, change the value on Hound server's globalConstant LIMIT
        static let maximumNumberOfReminders = 10
    }

    enum LogConstant {
        static let defaultLogId: Int = -1
        static var defaultUserId: String {
            UserInformation.userId ?? VisualConstant.TextConstant.unknownHash
        }
        static let defaultLogAction = LogAction.feed
        static var defaultLogStartDate: Date { Date() }
        static let logCustomActionNameCharacterLimit: Int = 32
        static let logNoteCharacterLimit: Int = 500
    }

    enum ReminderConstant {
        static let defaultReminderId: Int = -1
        static let defaultReminderAction = ReminderAction.feed
        static let defaultReminderType = ReminderType.countdown
        static var defaultReminderExecutionBasis: Date { Date() }
        static let defaultReminderIsEnabled = true
        static let reminderCustomActionNameCharacterLimit: Int = 32
        static var defaultReminders: [Reminder] {
            [ defaultReminderOne, defaultReminderTwo, defaultReminderThree, defaultReminderFour ]
        }
        private static var defaultReminderOne: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .potty
            reminder.reminderType = .countdown
            reminder.countdownComponents.executionInterval = ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
            return reminder
        }
        private static var defaultReminderTwo: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .feed
            reminder.reminderType = .weekly
            // 7:00 AM local time
            return reminder
        }
        private static var defaultReminderThree: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .feed
            reminder.reminderType = .weekly
            var date = reminder.reminderExecutionDate ?? DateConstant.default1970Date
            // 12:00 PM local time
            date = Calendar.current.date(byAdding: .hour, value: 5, to: date) ?? DateConstant.default1970Date
            reminder.weeklyComponents.changeUTCHour(forDate: date)
            reminder.weeklyComponents.changeUTCMinute(forDate: date)
            return reminder
        }
        private static var defaultReminderFour: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .feed
            reminder.reminderType = .weekly
            var date = reminder.reminderExecutionDate ?? DateConstant.default1970Date
            // 5:00 PM local time
            date = Calendar.current.date(byAdding: .hour, value: 10, to: date) ?? DateConstant.default1970Date
            reminder.weeklyComponents.changeUTCHour(forDate: date)
            reminder.weeklyComponents.changeUTCMinute(forDate: date)
            return reminder
        }
    }

    enum ReminderComponentConstant {
        static let defaultCountdownExecutionInterval: TimeInterval = 60 * 60 * 2

        static let defaultUTCDay: Int = 1

        /// Hour 7 of the day in the user's local time zone, but adjusted so that hour 7 is in UTC hours (e.g. UTC-5 so localHour is 7 and UTCHour is 12)
        static var defaultUTCHour: Int {
            // We want hour 7 of the day in the users local timezone
            let defaultLocalHour = 7
            let hoursFromUTC = Calendar.current.timeZone.secondsFromGMT() / 3600

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
            let minutesFromUTC = (Calendar.current.timeZone.secondsFromGMT() % 3600) / 60

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

    enum DateConstant {
        static let default1970Date = Date(timeIntervalSince1970: 0.0)
    }
    
    enum FeedbackConstant {
        static let subscriptionCancellationSuggestionCharacterLimit: Int = 1000
    }
}
