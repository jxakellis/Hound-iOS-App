//
//  Key Constants.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/21/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum KeyConstant: String {
    
    // MARK: API Response Body
    
    // client and server
    case result
    case message
    case code
    case name
    
    // MARK: Family Information
    
    // client and server
    case familyId
    case familyCode
    case familyIsLocked
    case familyKickUserId
    case familyActiveSubscription
    case familyMembers
    case familyHeadIsUser
    case previousFamilyMembers
    
    // MARK: User Information
    
    // client
    case userMiddleName
    case userNamePrefix
    case userNameSuffix
    
    // client and server
    case userId
    case userIdentifier
    case userApplicationUsername
    case userEmail
    case userFirstName
    case userLastName
    case userNotificationToken
    
    // MARK: User Configuration
    
    // client and server
    case userConfigurationIsNotificationEnabled
    case userConfigurationIsLoudNotificationEnabled
    case userConfigurationIsLogNotificationEnabled
    case userConfigurationIsReminderNotificationEnabled
    case userConfigurationInterfaceStyle
    case userConfigurationSnoozeLength
    case userConfigurationNotificationSound
    case userConfigurationLogsInterfaceScale
    case userConfigurationRemindersInterfaceScale
    case userConfigurationPreviousDogManagerSynchronization
    case userConfigurationIsSilentModeEnabled
    case userConfigurationSilentModeStartUTCHour
    case userConfigurationSilentModeEndUTCHour
    case userConfigurationSilentModeStartUTCMinute
    case userConfigurationSilentModeEndUTCMinute
    
    // MARK: App Store Purchase
    
    // client
    case userPurchasedProduct
    case userPurchasedProductFromSubscriptionGroup20965379
    
    // client and server
    case appStoreReceiptURL
    case transactionId
    case productId
    case purchaseDate
    case expirationDate
    case numberOfFamilyMembers
    case numberOfDogs
    case isActive
    case isAutoRenewing
    
    // MARK: Dog Manager
    
    // client
    case dogManager
    case dogs
    
    // MARK: Dog
    
    // client
    case dogIcon
    case dogLogs
    case dogReminders

    // client and server
    case dogId
    case dogName
    case dogIsDeleted
    
    // MARK: Log Manager
    
    // client and server
    case logs
    
    // MARK: Log
    
    // client and server
    case logId
    case logAction
    case logCustomActionName
    case logDate
    case logNote
    case logIsDeleted
    
    // MARK: Reminder Manager
    
    // client and server
    case reminder
    case reminders
    
    // MARK: Reminder
    
    // client and server
    case reminderId
    case reminderAction
    case reminderCustomActionName
    case reminderType
    case reminderExecutionBasis
    case reminderExecutionDate
    case reminderIsDeleted
    case reminderIsEnabled
    
    // MARK: Snooze Components
    
    // client
    case snoozeComponents
    // client and server
    case snoozeExecutionInterval
    
    // MARK: Countdown Components
    
    // client
    case countdownComponents
    // client and server
    case countdownExecutionInterval
    
    // MARK: Weekly Components
    
    // client
    case weeklyComponents
    case weeklyWeekdays
    // client and server
    case weeklyUTCHour
    case weeklyUTCMinute
    case weeklySunday
    case weeklyMonday
    case weeklyTuesday
    case weeklyWednesday
    case weeklyThursday
    case weeklyFriday
    case weeklySaturday
    case weeklySkippedDate
    
    // MARK: Monthly Components
    
    // client
    case monthlyComponents
    // client and server
    case monthlyUTCDay
    case monthlyUTCHour
    case monthlyUTCMinute
    case monthlySkippedDate
    
    // MARK: One Time Components
    
    // client
    case oneTimeComponents
    // client and server
    case oneTimeDate
    
    // MARK: Local
    
    // client
    case localIsNotificationAuthorized
    
    case localPreviousLogCustomActionNames
    case localPreviousReminderCustomActionNames
    
    case localPreviousDatesUserShareHoundRequested
    case localPreviousDatesUserReviewRequested
    
    case localAppVersionsWithReleaseNotesShown
    
    case localHasCompletedFirstTimeSetup
    case localHasCompletedHoundIntroductionViewController
    case localHasCompletedRemindersIntroductionViewController
    case localHasCompletedSettingsFamilyIntroductionViewController

    case localAppVersion
}
