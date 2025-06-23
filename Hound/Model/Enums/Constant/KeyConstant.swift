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
    case requestId
    case responseId

    // MARK: Family Information

    // client and server
    case familyHeadUserId
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
    case userNickname

    // client and server
    case userId
    case userIdentifier
    case userAppAccountToken
    case userEmail
    case userFirstName
    case userLastName
    case userNotificationToken

    // MARK: User Configuration
    
    // client
    case previousDogManagerSynchronization

    // client and server
    case userConfigurationInterfaceStyle
    case userConfigurationMeasurementSystem
    
    case userConfigurationSnoozeLength
    
    case userConfigurationIsNotificationEnabled
    case userConfigurationIsLoudNotificationEnabled
    case userConfigurationIsLogNotificationEnabled
    case userConfigurationIsReminderNotificationEnabled
    case userConfigurationNotificationSound
    
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
    case expiresDate
    case numberOfFamilyMembers
    case isActive
    case autoRenewStatus
    case autoRenewProductId
    
    // MARK: Offline Sync Components
    
    case offlineModeComponents
    case offlineModeComponentsInitialAttemptedSyncDate
    case offlineModeComponentsInitialCreationDate
    
    case offlineModeDeletedObjectDeletedDate
    
    case offlineModeManagerShared
    case offlineModeManagerShouldUpdateUser
    case offlineModeManagerShouldGetUser
    case offlineModeManagerShouldGetFamily
    case offlineModeManagerShouldGetDogManager
    case offlineModeManagerOfflineModeDeletedObjects
    
    // MARK: Dog Manager

    // client
    case dogManager
    case dogs

    // MARK: Dog

    // client
    case dogIcon
    case dogLogs
    case dogReminders
    case dogTriggers

    // client and server
    case dogId
    case dogUUID
    case dogName
    case dogLastModified
    case dogIsDeleted

    // MARK: Log

    // client and server
    case logId
    case logUUID
    case logActionTypeId
    case logCustomActionName
    case logStartDate
    case logEndDate
    case logNote
    case logUnitTypeId
    case logNumberOfLogUnits
    case logLastModified
    case logIsDeleted

    // MARK: Reminder

    // client and server
    case reminderId
    case reminderUUID
    case reminderActionTypeId // also used for ReminderActionType
    case reminderCustomActionName
    case reminderType
    case reminderExecutionBasis
    case reminderExecutionDate
    case reminderIsTriggerResult
    case reminderIsEnabled
    case reminderLastModified
    case reminderIsDeleted
    
    // MARK: GlobalTypes
    
    case globalTypes
    case logActionType
    case reminderActionType
    case mappingLogActionTypeReminderActionType
    case logUnitType
    case mappingLogActionTypeLogUnitType
    
    // MARK: LogUnitType
    
    case unitSymbol
    case isImperial
    case isMetric
    case isUnitMass
    case isUnitVolume
    case isUnitLength
    
    // MARK: ReminderActionType/LogActionType/MappingLogActionTypeReminderActionType
    
    case mappingId
    case internalValue
    case readableValue // also LogUnitType
    case emoji
    case sortOrder
    case isDefault
    case allowsCustom
    
    // MARK: Reminder Trigger
    case triggerId
    case triggerUUID
    case triggerCustomName
    case reactionLogActionTypeIds
    case reactionLogCustomActionNames
    case resultReminderActionTypeId
    case triggerType
    case triggerTimeDelay
    case triggerFixedTimeType
    case triggerFixedTimeTypeAmount
    case triggerFixedTimeUTCHour
    case triggerFixedTimeUTCMinute
    case triggerLastModified
    case triggerIsDeleted
    
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
    
    // MARK: Survey Feedback
    
    case surveyFeedback
    case surveyFeedbackType
    case surveyFeedbackDeviceMetricModel
    case surveyFeedbackDeviceMetricSystemVersion
    case surveyFeedbackDeviceMetricAppVersion
    case surveyFeedbackDeviceMetricLocale
    case surveyFeedbackUserCancellationReason
    case surveyFeedbackUserCancellationFeedback
    case surveyFeedbackAppExperienceNumberOfStars
    case surveyFeedbackAppExperienceFeedback

    // MARK: Local

    // client
    case localIsNotificationAuthorized

    case localPreviousLogCustomActionNames
    case localPreviousReminderCustomActionNames

    case localPreviousDatesUserSurveyFeedbackAppExperienceRequested
    case localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted
    case localPreviousDatesUserReviewRequested

    case localAppVersionsWithReleaseNotesShown

    case localHasCompletedFirstTimeSetup
    case localHasCompletedHoundIntroductionViewController
    case localHasCompletedRemindersIntroductionViewController
    case localHasCompletedSettingsFamilyIntroductionViewController
    case localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController

    case localAppVersion
    case localHasIncompatibleData
}
