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
    static func loadUserDefaults() {
        // MARK: Log Launch
        
        HoundLogger.general.notice("\n-----Device Info-----\n Model: \(UIDevice.current.model) \n Name: \(UIDevice.current.name) \n System Name: \(UIDevice.current.systemName) \n System Version: \(UIDevice.current.systemVersion)")
        
        // MARK: Save App State Values
        
        if let stored = UserDefaults.standard.object(forKey: Constant.Key.localAppVersion.rawValue) as? String {
            AppVersion.previousAppVersion = AppVersion(from: stored)
        }
        else {
            AppVersion.previousAppVersion = nil
        }
        
        // If the previousAppVersion is less than the oldestCompatibleAppVersion, the user's data is no longer compatible and therefore should be redownloaded.
        if AppVersion.isCompatible(previous: AppVersion.previousAppVersion) {
            // Clear out this stored data so the user can redownload from the server
            UserDefaults.standard.set(nil, forKey: Constant.Key.previousDogManagerSynchronization.rawValue)
            UserDefaults.standard.set(nil, forKey: Constant.Key.dogManager.rawValue)
        }
        
        UserDefaults.standard.set(AppVersion.current.rawValue, forKey: Constant.Key.localAppVersion.rawValue)
        
        UserDefaults.standard.set(true, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // MARK: Load App Information
        
        // GlobalTypes MUST come first, as otherwise other classes (e.g. dog/logs/reminder) that reference it will crash when they get a null reference for GlobalTypes.shared!
        GlobalTypes.load(fromUserDefaults: UserDefaults.standard)
        
        UserInformation.load(fromUserDefaults: UserDefaults.standard)
        
        FamilyInformation.load(fromUserDefaults: UserDefaults.standard)
        
        UserConfiguration.load(fromUserDefaults: UserDefaults.standard)
        
        LocalConfiguration.load(fromUserDefaults: UserDefaults.standard)
        
        OfflineModeManager.load(fromUserDefaults: UserDefaults.standard)
    }
    
    /// Called by App or Scene Delegate when entering the background, used to save information, can be called when terminating for a slightly modifed case.
    static func didEnterBackground(isTerminating: Bool) {
        // MARK: Loud Notifications and Silent Audio
        
        // Check to see if the user is eligible for loud notifications
        // Don't check for enabled reminders, as client could be out of sync with server
        if UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotificationEnabled {
            if isTerminating == true {
                // Send notification to user that their loud notifications won't work
                AlertRequest.create(forErrorAlert: .automaticallyAlertForNone, completionHandler: { _, _ in
                })
            }
            else {
                // app isn't terminating so add background silence
                AudioManager.stopAudio()
                AudioManager.playSilenceAudio()
            }
        }
        
        // MARK: Save App Information
        
        GlobalTypes.persist(toUserDefaults: UserDefaults.standard)
        
        UserInformation.persist(toUserDefaults: UserDefaults.standard)
        
        FamilyInformation.persist(toUserDefaults: UserDefaults.standard)
        
        UserConfiguration.persist(toUserDefaults: UserDefaults.standard)
        
        LocalConfiguration.persist(toUserDefaults: UserDefaults.standard)
        
        OfflineModeManager.persist(toUserDefaults: UserDefaults.standard)
    }
    
    static func didBecomeActive() {
        // Scene must be active for synchronizeReminderAlarmQueueIfNeeded to work
        ReminderAlarmManager.synchronizeReminderAlarmQueueIfNeeded()
        
        // If the app hasn't refreshed the dogManager for a given amount of time, then refresh the data.
        if let previousDogManagerSynchronization = LocalConfiguration.previousDogManagerSynchronization, previousDogManagerSynchronization.distance(to: Date()) >= 1 {
            MainTabBarController.shouldSilentlyRefreshDogManager = true
            MainTabBarController.shouldSilentlyRefreshFamily = true
        }
        else if LocalConfiguration.previousDogManagerSynchronization == nil {
            MainTabBarController.shouldSilentlyRefreshDogManager = true
            MainTabBarController.shouldSilentlyRefreshFamily = true
        }
    }
    
    static func willEnterForeground() {
        // Invocation of synchronizeNotificationAuthorization from willEnterForeground will only be accurate in conjuction with invocation of synchronizeNotificationAuthorization in viewIsAppearing of MainTabBarController. This makes it so every time Hound is opened, either from the background or from terminated, notifications are properly synced.
        // 1. Hound entering foreground from being terminated. willEnterForeground called upon initial launch of Hound although UserConfiguration (and notification settings) aren't loaded from the server, but viewIsAppearing MainTabBarController will catch as it's invoked once ServerSyncVC is done loading (and notification settings are loaded
        // 2. Hound entering foreground after entering background. viewIsAppearing MainTabBarController won't catch as MainTabBarController's view isn't appearing anymore but willEnterForeground will catch any imbalance as it's called once app is loaded to foreground
        NotificationPermissionsManager.synchronizeNotificationAuthorization()
        
        // stop any loud notifications that may have occured
        AudioManager.stopAudio()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    /// It is important to persist this value to memory immediately. Apple keeps track of when we ask the user for a rate review and we must keep accurate track. But, if Hound crashes before we can save an updated value of localPreviousDatesUserReviewRequested, then our value and Apple's true value is mismatched.
    static func persistRateReviewRequestedDates() {
        UserDefaults.standard.set(LocalConfiguration.localPreviousDatesUserReviewRequested, forKey: Constant.Key.localPreviousDatesUserReviewRequested.rawValue)
    }
    
    /// Removes values stored in the keychain and UserDefaults for userIdentifier and userId. Additionally, invokes clearStorageToRejoinFamily().
    static func clearStorageToReloginToAccount() {
        /// We write these changes to storage immediately. If not, could cause funky issues if not persisted.
        let keychain = KeychainSwift()
        
        // Clear userIdentifier out of storage so user is forced to login page again
        UserInformation.userIdentifier = nil
        keychain.delete(Constant.Key.userIdentifier.rawValue)
        UserDefaults.standard.removeObject(forKey: Constant.Key.userIdentifier.rawValue)
        
        UserInformation.userId = nil
        keychain.delete(Constant.Key.userId.rawValue)
        UserDefaults.standard.removeObject(forKey: Constant.Key.userId.rawValue)
        
        UserInformation.userAppAccountToken = nil
        UserDefaults.standard.removeObject(forKey: Constant.Key.userAppAccountToken.rawValue)
        
        UserInformation.userNotificationToken = nil
        UserDefaults.standard.removeObject(forKey: Constant.Key.userNotificationToken.rawValue)
        
        clearStorageToRejoinFamily()
    }
    
    /// Removes values stored in the keychain and UserDefaults for localHasCompletedHoundIntroductionViewController, localHasCompletedRemindersIntroductionViewController, localHasCompletedFamilyUpgradeIntroductionViewController, previousDogManagerSynchronization, and dogManager.
    static func clearStorageToRejoinFamily() {
        // We write these changes to storage immediately. If not, could cause funky issues if not persisted.
        
        // MARK: User Information
        
        UserInformation.familyId = nil
        UserDefaults.standard.removeObject(forKey: Constant.Key.familyId.rawValue)
        
        // MARK: Local Configuration
        LocalConfiguration.localHasCompletedHoundIntroductionViewController = false
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedHoundIntroductionViewController, forKey: Constant.Key.localHasCompletedHoundIntroductionViewController.rawValue)
        
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController = false
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedRemindersIntroductionViewController, forKey: Constant.Key.localHasCompletedRemindersIntroductionViewController.rawValue)
        
        LocalConfiguration.localHasCompletedFamilyUpgradeIntroductionViewController = false
        UserDefaults.standard.set(LocalConfiguration.localHasCompletedFamilyUpgradeIntroductionViewController, forKey: Constant.Key.localHasCompletedFamilyUpgradeIntroductionViewController.rawValue)
        
        clearDogManagerStorage()
    }
    
    static func clearDogManagerStorage() {
        LocalConfiguration.previousDogManagerSynchronization = nil
        UserDefaults.standard.removeObject(forKey: Constant.Key.previousDogManagerSynchronization.rawValue)
        DogManager.globalDogManager = nil
        UserDefaults.standard.removeObject(forKey: Constant.Key.dogManager.rawValue)
        OfflineModeManager.shared = OfflineModeManager()
        UserDefaults.standard.removeObject(forKey: Constant.Key.offlineModeManagerShared.rawValue)
    }
    
}
