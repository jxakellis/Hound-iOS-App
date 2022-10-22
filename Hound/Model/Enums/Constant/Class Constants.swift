//
//  Dog Constants.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ClassConstant {
    
    enum SubscriptionConstant {
        static var defaultSubscription: Subscription { return Subscription(transactionId: nil, product: nil, purchaseDate: nil, expirationDate: nil, numberOfFamilyMembers: defaultSubscriptionNumberOfFamilyMembers, numberOfDogs: defaultSubscriptionNumberOfDogs, isActive: true, isAutoRenewing: true) }
        static let defaultSubscriptionNumberOfFamilyMembers = 1
        static let defaultSubscriptionSpelledOutNumberOfFamilyMembers = "one"
        static let defaultSubscriptionNumberOfDogs = 2
        static let defaultSubscriptionSpelledOutNumberOfDogs = "two"
    }
    
    enum DogConstant {
        static let defaultDogName: String = "Bella"
        static let defaultDogIcon: UIImage = UIImage.init(named: "whitePawWithHands") ?? UIImage()
        static let defaultDogId: Int = -1
        static let chooseDogIcon: UIImage = UIImage.init(named: "chooseDogIcon") ?? UIImage()
        static let dogNameCharacterLimit: Int = 32
    }
    
    enum LogConstant {
        static let defaultLogId: Int = -1
        static var defaultUserId: String {
            return UserInformation.userId ?? Hash.defaultSHA256Hash
        }
        static let defaultLogAction = LogAction.feed
        static let defaultLogCustomActionName: String = ""
        static let defaultLogNote: String = ""
        static var defaultLogDate: Date { return Date() }
        /// when looking to unskip a reminder, we look for a log that has its time unmodified. if its logDate within a certain percision of the skipdate, then we assume that log is from that reminder skipping.
        static let logRemovalPrecision: Double = 0.025
        static let logCustomActionNameCharacterLimit: Int = 32
        static let logNoteCharacterLimit: Int = 500
    }
    
    enum ReminderConstant {
        static let defaultReminderId: Int = -1
        static let defaultReminderAction = ReminderAction.feed
        static let defaultReminderCustomActionName: String = ""
        static let defaultReminderType = ReminderType.countdown
        static var defaultReminderExecutionBasis: Date { return Date() }
        static let defaultReminderIsEnabled = true
        static let reminderCustomActionNameCharacterLimit: Int = 32
        static var defaultReminders: [Reminder] {
            return [ defaultReminderOne, defaultReminderTwo, defaultReminderThree, defaultReminderFour ]
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
            return reminder
        }
        private static var defaultReminderThree: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .feed
            reminder.reminderType = .weekly
            var date = reminder.reminderExecutionDate ?? DateConstant.default1970Date
            // 5:00 PM local time
            date = Calendar.localCalendar.date(byAdding: .hour, value: 10, to: date) ?? DateConstant.default1970Date
            reminder.weeklyComponents.changeUTCHour(forDate: date)
            reminder.weeklyComponents.changeUTCMinute(forDate: date)
            return reminder
        }
        private static var defaultReminderFour: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .medicine
            reminder.reminderType = .monthly
            var date = reminder.reminderExecutionDate ?? DateConstant.default1970Date
            // 9:00 AM local time
            date = Calendar.localCalendar.date(byAdding: .hour, value: 2, to: date) ?? DateConstant.default1970Date
            reminder.monthlyComponents.changeUTCDay(forDate: date)
            reminder.monthlyComponents.changeUTCHour(forDate: date)
            reminder.monthlyComponents.changeUTCMinute(forDate: date)
            return reminder
        }
    }
    
    enum ReminderComponentConstant {
        static let defaultCountdownExecutionInterval: TimeInterval = 1800
        
        static let defaultUTCDay: Int = 1
        
        /// Hour 7 of the day in the user's local time zone, but adjusted so that hour 7 is in UTC hours (e.g. UTC-5 so localHour is 7 and UTCHour is 12)
        static var defaultUTCHour: Int {
            // We want hour 7 of the day in the users local timezone
            let defaultLocalHour = 7
            let hoursFromUTC = Calendar.localCalendar.timeZone.secondsFromGMT() / 3600
            
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
            let minutesFromUTC = (Calendar.localCalendar.timeZone.secondsFromGMT() % 3600) / 60
            
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
}
