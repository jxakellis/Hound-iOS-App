//
//  PersistenceManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/16/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import KeychainSwift
import StoreKit
import UIKit

enum PersistenceManager {
    /// Called by App or Scene Delegate when setting up in didFinishLaunchingWithOptions, can be either the first time setup or a recurring setup (i.e. not the app isnt being opened for the first time)
    static func applicationDidFinishLaunching() {
        // MARK: Log Launch
        
        AppDelegate.generalLogger.notice("\n-----Device Info-----\n Model: \(UIDevice.current.model) \n Name: \(UIDevice.current.name) \n System Name: \(UIDevice.current.systemName) \n System Version: \(UIDevice.current.systemVersion)")
        
        // MARK: Save App State Values
        
        UIApplication.previousAppVersion = UserDefaults.standard.object(forKey: KeyConstant.localAppVersion.rawValue) as? String
        
        // If the previousAppVersion is less than the oldestCompatibleAppVersion, the user's data is no longer compatible and therefore should be redownloaded.
        if UIApplication.isPreviousAppVersionCompatible == false {
            // Clear out this stored data so the user can redownload from the server
            UserDefaults.standard.set(nil, forKey: KeyConstant.previousDogManagerSynchronization.rawValue)
            UserDefaults.standard.set(nil, forKey: KeyConstant.dogManager.rawValue)
        }
        
        UserDefaults.standard.set(UIApplication.appVersion, forKey: KeyConstant.localAppVersion.rawValue)
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // MARK: Load Stored Keychain
        
        // These values are retrieved from Sign In With Apple so therefore need to be persisted specially. All other values can be retrieved using these values.
        let keychain = KeychainSwift()
        
        UserInformation.userIdentifier =
        keychain.get(KeyConstant.userIdentifier.rawValue)
        ?? UserDefaults.standard.value(forKey: KeyConstant.userIdentifier.rawValue) as? String
        ?? DevelopmentConstant.developmentDatabaseTestUserIdentifier
        ?? UserInformation.userIdentifier
        
        UserInformation.userEmail =
        keychain.get(KeyConstant.userEmail.rawValue)
        ?? UserDefaults.standard.value(forKey: KeyConstant.userEmail.rawValue) as? String
        ?? UserInformation.userEmail
        
        UserInformation.userFirstName =
        keychain.get(KeyConstant.userFirstName.rawValue)
        ?? UserDefaults.standard.value(forKey: KeyConstant.userFirstName.rawValue) as? String
        ?? UserInformation.userFirstName
        
        UserInformation.userLastName =
        keychain.get(KeyConstant.userLastName.rawValue)
        ?? UserDefaults.standard.value(forKey: KeyConstant.userLastName.rawValue) as? String
        ?? UserInformation.userLastName
        
        // MARK: Load User Information (excluding that which was loaded from the keychain)
        
        UserInformation.userId = UserDefaults.standard.value(forKey: KeyConstant.userId.rawValue) as? String ?? UserInformation.userId ?? DevelopmentConstant.developmentDatabaseTestUserId
        
        UserInformation.familyId = UserDefaults.standard.value(forKey: KeyConstant.familyId.rawValue) as? String ?? UserInformation.familyId
        
        UserInformation.userAppAccountToken = UserDefaults.standard.value(forKey: KeyConstant.userAppAccountToken.rawValue) as? String ?? UserInformation.userAppAccountToken
        
        UserInformation.userNotificationToken = UserDefaults.standard.value(forKey: KeyConstant.userNotificationToken.rawValue) as? String ?? UserInformation.userNotificationToken
        
        // MARK: Load User Configuration
        // NOTE: User Configuration is stored on the Hound server and retrieved synced. However, if the user is in offline mode, they will need these values. Therefore, use local storage as a second backup for these values

        if let measurementSystemInt = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationMeasurementSystem.rawValue) as? Int {
            UserConfiguration.measurementSystem = MeasurementSystem(rawValue: measurementSystemInt) ?? UserConfiguration.measurementSystem
        }
        
        UserConfiguration.isNotificationEnabled = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationIsNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isNotificationEnabled
        
        UserConfiguration.isLogNotificationEnabled = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationIsLoudNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isLogNotificationEnabled
        
        UserConfiguration.isLogNotificationEnabled = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationIsLogNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isLogNotificationEnabled
        
        UserConfiguration.isReminderNotificationEnabled = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationIsReminderNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isReminderNotificationEnabled
        
        if let interfaceStyleInt = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationInterfaceStyle.rawValue) as? Int {
            UserConfiguration.interfaceStyle = UIUserInterfaceStyle(rawValue: interfaceStyleInt) ?? UserConfiguration.interfaceStyle
        }
        
        UserConfiguration.snoozeLength = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationSnoozeLength.rawValue) as? Double ?? UserConfiguration.snoozeLength
        if let notificationSoundString = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationNotificationSound.rawValue) as? String {
            UserConfiguration.notificationSound = NotificationSound(rawValue: notificationSoundString) ?? UserConfiguration.notificationSound
        }
        
        UserConfiguration.isSilentModeEnabled = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationIsSilentModeEnabled.rawValue) as? Bool ?? UserConfiguration.isSilentModeEnabled
        
        UserConfiguration.silentModeStartUTCHour = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationSilentModeStartUTCHour.rawValue) as? Int ?? UserConfiguration.silentModeStartUTCHour
        
        UserConfiguration.silentModeEndUTCHour = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationSilentModeEndUTCHour.rawValue) as? Int ?? UserConfiguration.silentModeEndUTCHour
        
        UserConfiguration.silentModeStartUTCMinute = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationSilentModeStartUTCMinute.rawValue) as? Int ?? UserConfiguration.silentModeStartUTCMinute
        
        UserConfiguration.silentModeEndUTCMinute = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationSilentModeEndUTCMinute.rawValue) as? Int ?? UserConfiguration.silentModeEndUTCMinute
        
        // MARK: Load Local Configuration
        
        LocalConfiguration.previousDogManagerSynchronization = UserDefaults.standard.value(forKey: KeyConstant.previousDogManagerSynchronization.rawValue) as? Date ?? LocalConfiguration.previousDogManagerSynchronization
        
        if let dataDogManager: Data = UserDefaults.standard.data(forKey: KeyConstant.dogManager.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataDogManager) {
            unarchiver.requiresSecureCoding = false
            
            if let dogManager = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? DogManager {
                DogManager.globalDogManager = dogManager
            }
            else {
                // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refresh from the server
                AppDelegate.generalLogger.error("Failed to decode dogManager with unarchiver")
                DogManager.globalDogManager = nil
                LocalConfiguration.previousDogManagerSynchronization = nil
            }
        }
        else {
            // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refresh from the server
            AppDelegate.generalLogger.error("Failed to construct dataDogManager or construct unarchiver for dogManager")
            DogManager.globalDogManager = nil
            LocalConfiguration.previousDogManagerSynchronization = nil
        }
        
        // TODO persist offline mode deleted objects
        
        if let dataLocalPreviousLogCustomActionNames: Data = UserDefaults.standard.data(forKey: KeyConstant.localPreviousLogCustomActionNames.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataLocalPreviousLogCustomActionNames) {
            unarchiver.requiresSecureCoding = false
            
            LocalConfiguration.localPreviousLogCustomActionNames = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [PreviousLogCustomActionName] ?? LocalConfiguration.localPreviousLogCustomActionNames
        }
        
        if let dataLocalPreviousReminderCustomActionNames: Data = UserDefaults.standard.data(forKey: KeyConstant.localPreviousReminderCustomActionNames.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataLocalPreviousReminderCustomActionNames) {
            unarchiver.requiresSecureCoding = false
            
            LocalConfiguration.localPreviousReminderCustomActionNames = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [PreviousReminderCustomActionName] ?? LocalConfiguration.localPreviousReminderCustomActionNames
        }
        
        LocalConfiguration.localIsNotificationAuthorized =
        UserDefaults.standard.value(forKey: KeyConstant.localIsNotificationAuthorized.rawValue) as? Bool
        ?? LocalConfiguration.localIsNotificationAuthorized
        
        LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.rawValue) as? [Date]
        ?? LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested
        
        LocalConfiguration.localPreviousDatesUserReviewRequested =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousDatesUserReviewRequested.rawValue) as? [Date] ?? LocalConfiguration.localPreviousDatesUserReviewRequested
        
        LocalConfiguration.localAppVersionsWithReleaseNotesShown =
        UserDefaults.standard.value(forKey: KeyConstant.localAppVersionsWithReleaseNotesShown.rawValue) as? [String]
        ?? LocalConfiguration.localAppVersionsWithReleaseNotesShown
        
        LocalConfiguration.localHasCompletedHoundIntroductionViewController =
        UserDefaults.standard.value(forKey: KeyConstant.localHasCompletedHoundIntroductionViewController.rawValue) as? Bool
        ?? LocalConfiguration.localHasCompletedHoundIntroductionViewController
        
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController =
        UserDefaults.standard.value(forKey: KeyConstant.localHasCompletedRemindersIntroductionViewController.rawValue) as? Bool
        ?? LocalConfiguration.localHasCompletedRemindersIntroductionViewController
        
        LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController =
        UserDefaults.standard.value(forKey: KeyConstant.localHasCompletedSettingsFamilyIntroductionViewController.rawValue) as? Bool
        ?? LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController
        
        LocalConfiguration.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController = UserDefaults.standard.value(forKey: KeyConstant.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController.rawValue) as? Bool ?? LocalConfiguration.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController
    }
    
    /// Called by App or Scene Delegate when entering the background, used to save information, can be called when terminating for a slightly modifed case.
    static func didEnterBackground(isTerminating: Bool) {
        // MARK: Loud Notifications and Silent Audio
        
        // Check to see if the user is eligible for loud notifications
        // Don't check for enabled reminders, as client could be out of sync with server
        if UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotificationEnabled {
            if isTerminating == true {
                // Send notification to user that their loud notifications won't work
                AlertRequest.create(errorAlert: .automaticallyAlertForNone, completionHandler: { _, _ in
                })
            }
            else {
                // app isn't terminating so add background silence
                AudioManager.stopAudio()
                AudioManager.playSilenceAudio()
            }
        }
        
        // MARK: User Information (excluding that which was saved to the keychain immediately)
        
        UserDefaults.standard.set(UserInformation.userId, forKey: KeyConstant.userId.rawValue)
        
        UserDefaults.standard.set(UserInformation.familyId, forKey: KeyConstant.familyId.rawValue)
        
        UserDefaults.standard.set(UserInformation.userAppAccountToken, forKey: KeyConstant.userAppAccountToken.rawValue)
        
        UserDefaults.standard.set(UserInformation.userNotificationToken, forKey: KeyConstant.userNotificationToken.rawValue)
        
        // MARK: User Configuration
        
        UserDefaults.standard.set(UserConfiguration.measurementSystem.rawValue, forKey: KeyConstant.userConfigurationMeasurementSystem.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.isNotificationEnabled, forKey: KeyConstant.userConfigurationIsNotificationEnabled.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.isLoudNotificationEnabled, forKey: KeyConstant.userConfigurationIsLoudNotificationEnabled.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.isLogNotificationEnabled, forKey: KeyConstant.userConfigurationIsLogNotificationEnabled.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.isReminderNotificationEnabled, forKey: KeyConstant.userConfigurationIsReminderNotificationEnabled.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.interfaceStyle.rawValue, forKey: KeyConstant.userConfigurationInterfaceStyle.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.notificationSound.rawValue, forKey: KeyConstant.userConfigurationNotificationSound.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.isSilentModeEnabled, forKey: KeyConstant.userConfigurationIsSilentModeEnabled.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.silentModeStartUTCHour, forKey: KeyConstant.userConfigurationSilentModeStartUTCHour.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.silentModeEndUTCHour, forKey: KeyConstant.userConfigurationSilentModeEndUTCHour.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.silentModeStartUTCMinute, forKey: KeyConstant.userConfigurationSilentModeStartUTCMinute.rawValue)
        
        UserDefaults.standard.set(UserConfiguration.silentModeEndUTCMinute, forKey: KeyConstant.userConfigurationSilentModeEndUTCMinute.rawValue)
        
        // MARK: Local Configuration
        
        UserDefaults.standard.set(LocalConfiguration.previousDogManagerSynchronization, forKey: KeyConstant.previousDogManagerSynchronization.rawValue)
        
        if let dogManager = DogManager.globalDogManager, let dataDogManager = try? NSKeyedArchiver.archivedData(withRootObject: dogManager, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataDogManager, forKey: KeyConstant.dogManager.rawValue)
        }
        
        if let dataLocalPreviousLogCustomActionNames = try? NSKeyedArchiver.archivedData(withRootObject: LocalConfiguration.localPreviousLogCustomActionNames, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataLocalPreviousLogCustomActionNames, forKey: KeyConstant.localPreviousLogCustomActionNames.rawValue)
        }
        if let dataLocalPreviousReminderCustomActionNames = try? NSKeyedArchiver.archivedData(withRootObject: LocalConfiguration.localPreviousReminderCustomActionNames, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataLocalPreviousReminderCustomActionNames, forKey: KeyConstant.localPreviousReminderCustomActionNames.rawValue)
        }
        
        UserDefaults.standard.set(LocalConfiguration.localIsNotificationAuthorized, forKey: KeyConstant.localIsNotificationAuthorized.rawValue)
        
        UserDefaults.standard.set(LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested, forKey: KeyConstant.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.rawValue)
        
        UserDefaults.standard.set(LocalConfiguration.localAppVersionsWithReleaseNotesShown, forKey: KeyConstant.localAppVersionsWithReleaseNotesShown.rawValue)
        
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedHoundIntroductionViewController, forKey: KeyConstant.localHasCompletedHoundIntroductionViewController.rawValue)
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedRemindersIntroductionViewController, forKey: KeyConstant.localHasCompletedRemindersIntroductionViewController.rawValue)
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController, forKey: KeyConstant.localHasCompletedSettingsFamilyIntroductionViewController.rawValue)
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController, forKey: KeyConstant.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController.rawValue)
        
        // Don't persist value. This is purposefully reset everytime the app reopens
        LocalConfiguration.localDateWhenAppLastEnteredBackground = Date()
    }
    
    static func willEnterForeground() {
        // Invocation of synchronizeNotificationAuthorization from willEnterForeground will only be accurate in conjuction with invocation of synchronizeNotificationAuthorization in viewIsAppearing of MainTabBarController. This makes it so every time Hound is opened, either from the background or from terminated, notifications are properly synced.
        // 1. Hound entering foreground from being terminated. willEnterForeground called upon initial launch of Hound although UserConfiguration (and notification settings) aren't loaded from the server, but viewIsAppearing MainTabBarController will catch as it's invoked once ServerSyncViewController is done loading (and notification settings are loaded
        // 2. Hound entering foreground after entering background. viewIsAppearing MainTabBarController won't catch as MainTabBarController's view isn't appearing anymore but willEnterForeground will catch any imbalance as it's called once app is loaded to foreground
        NotificationManager.synchronizeNotificationAuthorization()
        
        // stop any loud notifications that may have occured
        AudioManager.stopAudio()
        
        // If the app hasn't refreshed the dogManager for a given amount of time, then refresh the data.
        if let previousDogManagerSynchronization = LocalConfiguration.previousDogManagerSynchronization, previousDogManagerSynchronization.distance(to: Date()) >= 1 {
            MainTabBarController.shouldRefreshDogManager = true
            MainTabBarController.shouldRefreshFamily = true
        }
        else if LocalConfiguration.previousDogManagerSynchronization == nil {
            MainTabBarController.shouldRefreshDogManager = true
            MainTabBarController.shouldRefreshFamily = true
        }
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
    }
    
    /// It is important to persist this value to memory immediately. Apple keeps track of when we ask the user for a rate review and we must keep accurate track. But, if Hound crashes before we can save an updated value of localPreviousDatesUserReviewRequested, then our value and Apple's true value is mismatched.
    static func persistRateReviewRequestedDates() {
        UserDefaults.standard.set(LocalConfiguration.localPreviousDatesUserReviewRequested, forKey: KeyConstant.localPreviousDatesUserReviewRequested.rawValue)
    }
    
    /// Removes values stored in the keychain and UserDefaults for userIdentifier and userId. Additionally, invokes clearStorageToRejoinFamily().
    static func clearStorageToReloginToAccount() {
        /// We write these changes to storage immediately. If not, could cause funky issues if not persisted.
        let keychain = KeychainSwift()
        
        // Clear userIdentifier out of storage so user is forced to login page again
        UserInformation.userIdentifier = nil
        keychain.delete(KeyConstant.userIdentifier.rawValue)
        UserDefaults.standard.removeObject(forKey: KeyConstant.userIdentifier.rawValue)
        
        UserInformation.userId = nil
        keychain.delete(KeyConstant.userId.rawValue)
        UserDefaults.standard.removeObject(forKey: KeyConstant.userId.rawValue)
        
        UserInformation.userAppAccountToken = nil
        UserDefaults.standard.removeObject(forKey: KeyConstant.userAppAccountToken.rawValue)
        
        UserInformation.userNotificationToken = nil
        UserDefaults.standard.removeObject(forKey: KeyConstant.userNotificationToken.rawValue)
        
        clearStorageToRejoinFamily()
    }
    
    /// Removes values stored in the keychain and UserDefaults for localHasCompletedHoundIntroductionViewController, localHasCompletedRemindersIntroductionViewController, localHasCompletedSettingsFamilyIntroductionViewController, localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController, previousDogManagerSynchronization, and dogManager.
    static func clearStorageToRejoinFamily() {
        // We write these changes to storage immediately. If not, could cause funky issues if not persisted.
        
        // MARK: User Information
        
        UserInformation.familyId = nil
        UserDefaults.standard.removeObject(forKey: KeyConstant.familyId.rawValue)
        
        // MARK: Local Configuration
        LocalConfiguration.localHasCompletedHoundIntroductionViewController = false
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedHoundIntroductionViewController, forKey: KeyConstant.localHasCompletedHoundIntroductionViewController.rawValue)
        
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController = false
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedRemindersIntroductionViewController, forKey: KeyConstant.localHasCompletedRemindersIntroductionViewController.rawValue)
        
        LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController = false
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController, forKey: KeyConstant.localHasCompletedSettingsFamilyIntroductionViewController.rawValue)
        
        LocalConfiguration.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController = false
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController, forKey: KeyConstant.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController.rawValue)
        
        LocalConfiguration.previousDogManagerSynchronization = nil
        UserDefaults.standard.set(LocalConfiguration.previousDogManagerSynchronization, forKey: KeyConstant.previousDogManagerSynchronization.rawValue)
        
        // MARK: Data
        
        DogManager.globalDogManager = nil
        UserDefaults.standard.removeObject(forKey: KeyConstant.dogManager.rawValue)
    }
    
}
