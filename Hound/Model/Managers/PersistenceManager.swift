//
//  PersistenceManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/16/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
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
        
        // If localAppVersion and appVersion are missing, that means the user just installed the app or upgraded from Hound 1.3.5. A user who just installed won't have a value stored for "appBuild", but a user who just upgraded from Hound 1.3.5 will.
        let previousAppBuild = UserDefaults.standard.value(forKey: "appBuild") as? Int
        UserDefaults.standard.set(nil, forKey: "appBuild")
        
        // <= build 8000 appVersion
        UIApplication.previousAppVersion = UserDefaults.standard.object(forKey: KeyConstant.localAppVersion.rawValue) as? String ?? UserDefaults.standard.object(forKey: "appVersion") as? String ?? (previousAppBuild != nil ? "1.3.5" : "2.0.0")
        
        UserDefaults.standard.setValue(UIApplication.appVersion, forKey: KeyConstant.localAppVersion.rawValue)
        
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // MARK: Load Stored Keychain
        
        // These values are retrieved from Sign In With Apple so therefore need to be persisted specially. All other values can be retrieved using these values.
        let keychain = KeychainSwift()
        
        UserInformation.userIdentifier = keychain.get(KeyConstant.userIdentifier.rawValue) ?? UserInformation.userIdentifier
        
        UserInformation.userEmail = keychain.get(KeyConstant.userEmail.rawValue) ?? UserInformation.userEmail
        UserInformation.userFirstName = keychain.get(KeyConstant.userFirstName.rawValue) ?? UserInformation.userFirstName
        UserInformation.userLastName = keychain.get(KeyConstant.userLastName.rawValue) ?? UserInformation.userLastName
        
        // MARK: Load User Information
        
        UserInformation.userId = UserDefaults.standard.value(forKey: KeyConstant.userId.rawValue) as? String ?? UserInformation.userId
       
        UserInformation.familyId = UserDefaults.standard.value(forKey: KeyConstant.familyId.rawValue) as? String ?? UserInformation.familyId
        
        // MARK: Load Local Configuration
        // <= build 8000 lastDogManagerSynchronization
        LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationPreviousDogManagerSynchronization.rawValue) as? Date ?? UserDefaults.standard.value(forKey: "lastDogManagerSynchronization") as? Date ?? LocalConfiguration.userConfigurationPreviousDogManagerSynchronization
        
        if UIApplication.previousAppVersion == "1.3.5" {
            UserDefaults.standard.removeObject(forKey: "dogManager")
        }
        
        if let dataDogManager: Data = UserDefaults.standard.data(forKey: KeyConstant.dogManager.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataDogManager) {
            unarchiver.requiresSecureCoding = false
            
            if let dogManager = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? DogManager {
                ServerSyncViewController.dogManager = dogManager
            }
            else {
                // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refetch from the server
                AppDelegate.generalLogger.error("Failed to decode dogManager with unarchiver")
                ServerSyncViewController.dogManager = DogManager()
                LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = ClassConstant.DateConstant.default1970Date
            }
        }
        else {
            // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refetch from the server
            AppDelegate.generalLogger.error("Failed to construct dataDogManager or construct unarchiver for dogManager")
            ServerSyncViewController.dogManager = DogManager()
            LocalConfiguration.userConfigurationPreviousDogManagerSynchronization = ClassConstant.DateConstant.default1970Date
        }
        
        // <= build 8000 logCustomActionNames
        LocalConfiguration.localPreviousLogCustomActionNames =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousLogCustomActionNames.rawValue) as? [String]
        ?? UserDefaults.standard.value(forKey: "logCustomActionNames") as? [String]
        ?? LocalConfiguration.localPreviousLogCustomActionNames
        
        // <= build 8000 reminderCustomActionNames
        LocalConfiguration.localPreviousReminderCustomActionNames =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousReminderCustomActionNames.rawValue) as? [String]
        ?? UserDefaults.standard.value(forKey: "reminderCustomActionNames") as? [String]
        ?? LocalConfiguration.localPreviousReminderCustomActionNames
        
        // <= build 8000 isNotificationAuthorized
        LocalConfiguration.localIsNotificationAuthorized =
        UserDefaults.standard.value(forKey: KeyConstant.localIsNotificationAuthorized.rawValue) as? Bool
        ?? UserDefaults.standard.value(forKey: "isNotificationAuthorized") as? Bool
        ?? LocalConfiguration.localIsNotificationAuthorized
        
        // <= build 6500 userAskedToReviewHoundDates
        // <= build 8000 datesUserShownBannerToReviewHound
        LocalConfiguration.localPreviousDatesUserShownBannerToReviewHound =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousDatesUserShownBannerToReviewHound.rawValue) as? [Date]
        ?? UserDefaults.standard.value(forKey: "datesUserShownBannerToReviewHound") as? [Date]
        ?? UserDefaults.standard.value(forKey: "userAskedToReviewHoundDates") as? [Date]
        ?? LocalConfiguration.localPreviousDatesUserShownBannerToReviewHound
        
        // <= build 6000 reviewRequestDates
        // <= build 6500 rateReviewRequestedDates
        // <= build 8000 datesUserReviewRequested
        LocalConfiguration.localPreviousDatesUserReviewRequested =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousDatesUserReviewRequested.rawValue) as? [Date]
        ?? UserDefaults.standard.value(forKey: "datesUserReviewRequested") as? [Date]
        ?? UserDefaults.standard.value(forKey: "reviewRequestDates") as? [Date]
        ?? UserDefaults.standard.value(forKey: "rateReviewRequestedDates") as? [Date] ?? LocalConfiguration.localPreviousDatesUserReviewRequested
        
        // <= build 8000 appVersionsWithReleaseNotesShown
        LocalConfiguration.localAppVersionsWithReleaseNotesShown =
        UserDefaults.standard.value(forKey: KeyConstant.localAppVersionsWithReleaseNotesShown.rawValue) as? [String]
        ?? UserDefaults.standard.value(forKey: "appVersionsWithReleaseNotesShown") as? [String]
        ?? LocalConfiguration.localAppVersionsWithReleaseNotesShown
        
        // <= build 8000 hasLoadedHoundIntroductionViewControllerBefore
        LocalConfiguration.localHasCompletedHoundIntroductionViewController =
        UserDefaults.standard.value(forKey: KeyConstant.localHasCompletedHoundIntroductionViewController.rawValue) as? Bool
        ?? UserDefaults.standard.value(forKey: "hasLoadedHoundIntroductionViewControllerBefore") as? Bool
        ?? LocalConfiguration.localHasCompletedHoundIntroductionViewController
        
        // <= build 8000 hasLoadedRemindersIntroductionViewControllerBefore
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController =
        UserDefaults.standard.value(forKey: KeyConstant.localHasCompletedRemindersIntroductionViewController.rawValue) as? Bool
        ?? UserDefaults.standard.value(forKey: "hasLoadedRemindersIntroductionViewControllerBefore") as? Bool
        ?? LocalConfiguration.localHasCompletedRemindersIntroductionViewController
        
        // <= build 8000 hasLoadedSettingsFamilyIntroductionViewControllerBefore
        LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController =
        UserDefaults.standard.value(forKey: KeyConstant.localHasCompletedSettingsFamilyIntroductionViewController.rawValue) as? Bool
        ?? UserDefaults.standard.value(forKey: "hasLoadedSettingsFamilyIntroductionViewControllerBefore") as? Bool
        ?? LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController
    }
    
    /// Called by App or Scene Delegate when entering the background, used to save information, can be called when terminating for a slightly modifed case.
    static func didEnterBackground(isTerminating: Bool = false) {
        
        // MARK: Loud Notifications and Silent Audio
        
        // Check to see if the user is eligible for loud notifications
        // Don't check for enabled reminders, as client could be out of sync with server
        if UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotification {
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
        
        // Data below is retrieved from the server, so no need to store/persist locally
        
        // Local Configuration
        
        UserDefaults.standard.set(LocalConfiguration.userConfigurationPreviousDogManagerSynchronization, forKey: KeyConstant.userConfigurationPreviousDogManagerSynchronization.rawValue)
        
        if let dogManager = MainTabBarViewController.mainTabBarViewController?.dogManager, let dataDogManager = try? NSKeyedArchiver.archivedData(withRootObject: dogManager, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataDogManager, forKey: KeyConstant.dogManager.rawValue)
        }
        
        UserDefaults.standard.set(LocalConfiguration.localPreviousLogCustomActionNames, forKey: KeyConstant.localPreviousLogCustomActionNames.rawValue)
        UserDefaults.standard.set(LocalConfiguration.localPreviousReminderCustomActionNames, forKey: KeyConstant.localPreviousReminderCustomActionNames.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.localIsNotificationAuthorized, forKey: KeyConstant.localIsNotificationAuthorized.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.localPreviousDatesUserShownBannerToReviewHound, forKeyPath: KeyConstant.localPreviousDatesUserShownBannerToReviewHound.rawValue)
        PersistenceManager.persistRateReviewRequestedDates()
    
        UserDefaults.standard.setValue(LocalConfiguration.localAppVersionsWithReleaseNotesShown, forKey: KeyConstant.localAppVersionsWithReleaseNotesShown.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedHoundIntroductionViewController, forKey: KeyConstant.localHasCompletedHoundIntroductionViewController.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedRemindersIntroductionViewController, forKey: KeyConstant.localHasCompletedRemindersIntroductionViewController.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController, forKey: KeyConstant.localHasCompletedSettingsFamilyIntroductionViewController.rawValue)
        
        // Don't persist value. This is purposefully reset everytime the app reopens
        LocalConfiguration.localDateWhenAppLastEnteredBackground = Date()
    }
    
    static func willEnterForeground() {
        
        // Invocation of synchronizeNotificationAuthorization from willEnterForeground will only be accurate in conjuction with invocation of synchronizeNotificationAuthorization in viewDidAppear of MainTabBarViewController. This makes it so every time Hound is opened, either from the background or from terminated, notifications are properly synced.
        // 1. Hound entering foreground from being terminated. willEnterForeground called upon inital launch of Hound although UserConfiguration (and notification settings) aren't loaded from the server, but viewDidAppear MainTabBarViewController will catch as it's invoked once ServerSyncViewController is done loading (and notification settings are loaded
        // 2. Hound entering foreground after entering background. viewDidAppear MainTabBarViewController won't catch as MainTabBarViewController's view isn't appearing anymore but willEnterForeground will catch any imbalance as it's called once app is loaded to foreground
        NotificationManager.synchronizeNotificationAuthorization()
        
        // stop any loud notifications that may have occured
        AudioManager.stopLoudNotification()
        
        // If the app has been closed for more than a certain amount of time, then refresh the data
        if LocalConfiguration.localDateWhenAppLastEnteredBackground.distance(to: Date()) >= 5 * 60 {
            MainTabBarViewController.mainTabBarViewController?.shouldRefreshDogManager = true
            MainTabBarViewController.mainTabBarViewController?.shouldRefreshFamily = true
        }
    
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
    }
    
    /// It is important to persist this value to memory immediately. Apple keeps track of when we ask the user for a rate review and we must keep accurate track. But, if Hound crashes before we can save an updated value of localPreviousDatesUserReviewRequested, then our value and Apple's true value is mismatched.
    static func persistRateReviewRequestedDates() {
        UserDefaults.standard.setValue(LocalConfiguration.localPreviousDatesUserReviewRequested, forKeyPath: KeyConstant.localPreviousDatesUserReviewRequested.rawValue)
    }
    
}
