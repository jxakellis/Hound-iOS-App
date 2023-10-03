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

// TODO FUTURE add offline mode, where we can locally store logs.

enum PersistenceManager {
    /// Called by App or Scene Delegate when setting up in didFinishLaunchingWithOptions, can be either the first time setup or a recurring setup (i.e. not the app isnt being opened for the first time)
    static func applicationDidFinishLaunching() {
        // MARK: Log Launch

        AppDelegate.generalLogger.notice("\n-----Device Info-----\n Model: \(UIDevice.current.model) \n Name: \(UIDevice.current.name) \n System Name: \(UIDevice.current.systemName) \n System Version: \(UIDevice.current.systemVersion)")

        // MARK: Save App State Values

        UIApplication.previousAppVersion = UserDefaults.standard.object(forKey: KeyConstant.localAppVersion.rawValue) as? String

        UserDefaults.standard.setValue(UIApplication.appVersion, forKey: KeyConstant.localAppVersion.rawValue)

        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

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

        // MARK: Load User Information

        UserInformation.userId = UserDefaults.standard.value(forKey: KeyConstant.userId.rawValue) as? String ?? UserInformation.userId ?? DevelopmentConstant.developmentDatabaseTestUserId

        UserInformation.familyId = UserDefaults.standard.value(forKey: KeyConstant.familyId.rawValue) as? String ?? UserInformation.familyId

        // MARK: Load User Configuration
        // NOTE: User configuration is accurately stored on the server and retrieved when server sync contacts the Hound servers. However, before that point in time, we show some of the interface to the user. This means the user could have configurated their interface style but we aren't accurately displaying it yet, as we have yet to retrieve it from the server. For this reason, we store it locally here and use its value until we get the correct value from the server.
        if let interfaceStyleInt = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationInterfaceStyle.rawValue) as? Int {
            UserConfiguration.interfaceStyle = UIUserInterfaceStyle(rawValue: interfaceStyleInt) ?? UserConfiguration.interfaceStyle
        }

        // MARK: Load Local Configuration
        LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationPreviousDogManagerSynchronization.rawValue) as? Date ?? LocalConfiguration.userConfigurationPreviousDogManagerSynchronization

        if let dataDogManager: Data = UserDefaults.standard.data(forKey: KeyConstant.dogManager.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataDogManager) {
            unarchiver.requiresSecureCoding = false

            if let dogManager = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? DogManager {
                DogManager.globalDogManager = dogManager
            }
            else {
                // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refresh from the server
                AppDelegate.generalLogger.error("Failed to decode dogManager with unarchiver")
                DogManager.globalDogManager = nil
                LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = ClassConstant.DateConstant.default1970Date
            }
        }
        else {
            // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refresh from the server
            AppDelegate.generalLogger.error("Failed to construct dataDogManager or construct unarchiver for dogManager")
            DogManager.globalDogManager = nil
            LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = ClassConstant.DateConstant.default1970Date
        }

        LocalConfiguration.localPreviousLogCustomActionNames =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousLogCustomActionNames.rawValue) as? [String]
        ?? LocalConfiguration.localPreviousLogCustomActionNames

        LocalConfiguration.localPreviousReminderCustomActionNames =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousReminderCustomActionNames.rawValue) as? [String]
        ?? LocalConfiguration.localPreviousReminderCustomActionNames

        LocalConfiguration.localIsNotificationAuthorized =
        UserDefaults.standard.value(forKey: KeyConstant.localIsNotificationAuthorized.rawValue) as? Bool
        ?? LocalConfiguration.localIsNotificationAuthorized

        LocalConfiguration.localPreviousDatesUserShareHoundRequested =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousDatesUserShareHoundRequested.rawValue) as? [Date]
        ?? LocalConfiguration.localPreviousDatesUserShareHoundRequested

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
    static func didEnterBackground(isTerminating: Bool = false) {

        // MARK: Loud Notifications and Silent Audio

        // Check to see if the user is eligible for loud notifications
        // Don't check for enabled reminders, as client could be out of sync with server
        if UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotificationEnabled {
            if isTerminating == true {
                // Send notification to user that their loud notifications won't work
                AlertRequest.create(completionHandler: { _, _, _ in
                    //
                })
            }
            else {
                // app isn't terminating so add background silence
                AudioManager.stopAudio()
                AudioManager.playSilenceAudio()
            }
        }

        // MARK: - User Defaults

        // User Information

        UserDefaults.standard.setValue(UserInformation.userId, forKey: KeyConstant.userId.rawValue)
        UserDefaults.standard.setValue(UserInformation.familyId, forKey: KeyConstant.familyId.rawValue)

        // other user info from ASAuthorization is saved immediately to the keychain

        // User Configuration
        // NOTE: User configuration is accurately stored on the server and retrieved when server sync contacts the Hound servers. However, before that point in time, we show some of the interface to the user. This means the user could have configurated their interface style but we aren't accurately displaying it yet, as we have yet to retrieve it from the server. For this reason, we store it locally here and use its value until we get the correct value from the server.
        UserDefaults.standard.set(UserConfiguration.interfaceStyle.rawValue, forKey: KeyConstant.userConfigurationInterfaceStyle.rawValue)

        // Local Configuration

        UserDefaults.standard.set(LocalConfiguration.userConfigurationPreviousDogManagerSynchronization, forKey: KeyConstant.userConfigurationPreviousDogManagerSynchronization.rawValue)

        if let dogManager = DogManager.globalDogManager, let dataDogManager = try? NSKeyedArchiver.archivedData(withRootObject: dogManager, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataDogManager, forKey: KeyConstant.dogManager.rawValue)
        }

        UserDefaults.standard.set(LocalConfiguration.localPreviousLogCustomActionNames, forKey: KeyConstant.localPreviousLogCustomActionNames.rawValue)
        UserDefaults.standard.set(LocalConfiguration.localPreviousReminderCustomActionNames, forKey: KeyConstant.localPreviousReminderCustomActionNames.rawValue)

        UserDefaults.standard.setValue(LocalConfiguration.localIsNotificationAuthorized, forKey: KeyConstant.localIsNotificationAuthorized.rawValue)

        UserDefaults.standard.setValue(LocalConfiguration.localPreviousDatesUserShareHoundRequested, forKeyPath: KeyConstant.localPreviousDatesUserShareHoundRequested.rawValue)

        UserDefaults.standard.setValue(LocalConfiguration.localAppVersionsWithReleaseNotesShown, forKey: KeyConstant.localAppVersionsWithReleaseNotesShown.rawValue)

        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedHoundIntroductionViewController, forKey: KeyConstant.localHasCompletedHoundIntroductionViewController.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedRemindersIntroductionViewController, forKey: KeyConstant.localHasCompletedRemindersIntroductionViewController.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController, forKey: KeyConstant.localHasCompletedSettingsFamilyIntroductionViewController.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController, forKey: KeyConstant.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController.rawValue)

        // Don't persist value. This is purposefully reset everytime the app reopens
        LocalConfiguration.localDateWhenAppLastEnteredBackground = Date()
    }

    static func willEnterForeground() {

        // Invocation of synchronizeNotificationAuthorization from willEnterForeground will only be accurate in conjuction with invocation of synchronizeNotificationAuthorization in viewDidAppear of MainTabBarController. This makes it so every time Hound is opened, either from the background or from terminated, notifications are properly synced.
        // 1. Hound entering foreground from being terminated. willEnterForeground called upon initial launch of Hound although UserConfiguration (and notification settings) aren't loaded from the server, but viewDidAppear MainTabBarController will catch as it's invoked once ServerSyncViewController is done loading (and notification settings are loaded
        // 2. Hound entering foreground after entering background. viewDidAppear MainTabBarController won't catch as MainTabBarController's view isn't appearing anymore but willEnterForeground will catch any imbalance as it's called once app is loaded to foreground
        NotificationManager.synchronizeNotificationAuthorization()

        // stop any loud notifications that may have occured
        AudioManager.stopAudio()

        // If the app hasn't refreshed the dogManager for a given amount of time, then refresh the data.
        if LocalConfiguration.userConfigurationPreviousDogManagerSynchronization.distance(to: Date()) >= 5 {
            MainTabBarController.shouldRefreshDogManager = true
            MainTabBarController.shouldRefreshFamily = true
        }

        UNUserNotificationCenter.current().removeAllDeliveredNotifications()

    }

    /// It is important to persist this value to memory immediately. Apple keeps track of when we ask the user for a rate review and we must keep accurate track. But, if Hound crashes before we can save an updated value of localPreviousDatesUserReviewRequested, then our value and Apple's true value is mismatched.
    static func persistRateReviewRequestedDates() {
        UserDefaults.standard.setValue(LocalConfiguration.localPreviousDatesUserReviewRequested, forKeyPath: KeyConstant.localPreviousDatesUserReviewRequested.rawValue)
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

        clearStorageToRejoinFamily()
    }

    /// Removes values stored in the keychain and UserDefaults for familyId, localHasCompletedHoundIntroductionViewController, localHasCompletedRemindersIntroductionViewController, localHasCompletedSettingsFamilyIntroductionViewController, localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController, userConfigurationPreviousDogManagerSynchronization, and dogManager.
    static func clearStorageToRejoinFamily() {
        // We write these changes to storage immediately. If not, could cause funky issues if not persisted.

        // MARK: User Inforamtion
        
        UserInformation.familyId = nil
        UserDefaults.standard.removeObject(forKey: KeyConstant.familyId.rawValue)

        // MARK: Local Configuration
        LocalConfiguration.localHasCompletedHoundIntroductionViewController = false
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedHoundIntroductionViewController, forKey: KeyConstant.localHasCompletedHoundIntroductionViewController.rawValue)

        LocalConfiguration.localHasCompletedRemindersIntroductionViewController = false
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedRemindersIntroductionViewController, forKey: KeyConstant.localHasCompletedRemindersIntroductionViewController.rawValue)

        LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController = false
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController, forKey: KeyConstant.localHasCompletedSettingsFamilyIntroductionViewController.rawValue)

        LocalConfiguration.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController = false
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController, forKey: KeyConstant.localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController.rawValue)

        LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = ClassConstant.DateConstant.default1970Date
        UserDefaults.standard.set(LocalConfiguration.userConfigurationPreviousDogManagerSynchronization, forKey: KeyConstant.userConfigurationPreviousDogManagerSynchronization.rawValue)

        DogManager.globalDogManager = nil
        UserDefaults.standard.removeObject(forKey: KeyConstant.dogManager.rawValue)
    }

}
