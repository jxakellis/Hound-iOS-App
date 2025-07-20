//
//  LocalConfiguration.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import StoreKit
import UIKit

/// Configuration that is local to the app only. If the app is reinstalled then this data should be fresh
final class LocalConfiguration: UserDefaultPersistable {
    
    // MARK: - UserDefaultPersistable
    
    /// Persists all of the LocalConfiguration variables and the globalDogManager to the specified UserDefaults
    static func persist(toUserDefaults: UserDefaults) {
        toUserDefaults.set(LocalConfiguration.previousDogManagerSynchronization, forKey: Constant.Key.previousDogManagerSynchronization.rawValue)
        
        if let dogManager = DogManager.globalDogManager, let dataDogManager = try? NSKeyedArchiver.archivedData(withRootObject: dogManager, requiringSecureCoding: false) {
            toUserDefaults.set(dataDogManager, forKey: Constant.Key.dogManager.rawValue)
        }
        
        if let dataLocalPreviousLogCustomActionNames = try? NSKeyedArchiver.archivedData(withRootObject: LocalConfiguration.localPreviousLogCustomActionNames, requiringSecureCoding: false) {
            toUserDefaults.set(dataLocalPreviousLogCustomActionNames, forKey: Constant.Key.localPreviousLogCustomActionNames.rawValue)
        }
        if let dataLocalPreviousReminderCustomActionNames = try? NSKeyedArchiver.archivedData(withRootObject: LocalConfiguration.localPreviousReminderCustomActionNames, requiringSecureCoding: false) {
            toUserDefaults.set(dataLocalPreviousReminderCustomActionNames, forKey: Constant.Key.localPreviousReminderCustomActionNames.rawValue)
        }
        
        toUserDefaults.set(LocalConfiguration.localIsNotificationAuthorized, forKey: Constant.Key.localIsNotificationAuthorized.rawValue)
        
        toUserDefaults.set(LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested, forKey: Constant.Key.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.rawValue)
        
        toUserDefaults.set(LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted, forKey: Constant.Key.localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted.rawValue)
        
        toUserDefaults.set(LocalConfiguration.localAppVersionsWithReleaseNotesShown, forKey: Constant.Key.localAppVersionsWithReleaseNotesShown.rawValue)
        
        toUserDefaults.set(LocalConfiguration.localHasCompletedHoundIntroductionViewController, forKey: Constant.Key.localHasCompletedHoundIntroductionViewController.rawValue)
        toUserDefaults.set(LocalConfiguration.localHasCompletedRemindersIntroductionViewController, forKey: Constant.Key.localHasCompletedRemindersIntroductionViewController.rawValue)
        toUserDefaults.set(LocalConfiguration.localHasCompletedFamilyUpgradeIntroductionViewController, forKey: Constant.Key.localHasCompletedFamilyUpgradeIntroductionViewController.rawValue)
        
        // Don't persist value. This is purposefully reset everytime the app reopens
        LocalConfiguration.localDateWhenAppLastEnteredBackground = Date()
    }
    
    /// Load all of the LocalConfiguration variables and the globalDogManager from the specified UserDefaults
    static func load(fromUserDefaults: UserDefaults) {
        LocalConfiguration.previousDogManagerSynchronization = fromUserDefaults.value(forKey: Constant.Key.previousDogManagerSynchronization.rawValue) as? Date ?? LocalConfiguration.previousDogManagerSynchronization
        
        if let dataDogManager: Data = UserDefaults.standard.data(forKey: Constant.Key.dogManager.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataDogManager) {
            unarchiver.requiresSecureCoding = false
            
            if let dogManager = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? DogManager {
                DogManager.globalDogManager = dogManager
            }
            else {
                // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refresh from the server
                HoundLogger.general.error("Failed to decode dogManager with unarchiver")
                DogManager.globalDogManager = nil
                LocalConfiguration.previousDogManagerSynchronization = nil
            }
        }
        else {
            // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refresh from the server
            HoundLogger.general.error("Failed to construct dataDogManager or construct unarchiver for dogManager")
            DogManager.globalDogManager = nil
            LocalConfiguration.previousDogManagerSynchronization = nil
        }
        
        if let dataLocalPreviousLogCustomActionNames: Data = fromUserDefaults.data(forKey: Constant.Key.localPreviousLogCustomActionNames.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataLocalPreviousLogCustomActionNames) {
            unarchiver.requiresSecureCoding = false
            
            LocalConfiguration.localPreviousLogCustomActionNames = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [PreviousLogCustomActionName] ?? LocalConfiguration.localPreviousLogCustomActionNames
        }
        
        if let dataLocalPreviousReminderCustomActionNames: Data = fromUserDefaults.data(forKey: Constant.Key.localPreviousReminderCustomActionNames.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataLocalPreviousReminderCustomActionNames) {
            unarchiver.requiresSecureCoding = false
            
            LocalConfiguration.localPreviousReminderCustomActionNames = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [PreviousReminderCustomActionName] ?? LocalConfiguration.localPreviousReminderCustomActionNames
        }
        
        LocalConfiguration.localIsNotificationAuthorized =
        fromUserDefaults.value(forKey: Constant.Key.localIsNotificationAuthorized.rawValue) as? Bool
        ?? LocalConfiguration.localIsNotificationAuthorized
        
        LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested =
        fromUserDefaults.value(forKey: Constant.Key.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.rawValue) as? [Date]
        ?? LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested
        
        LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted =
        fromUserDefaults.value(forKey: Constant.Key.localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted.rawValue) as? [Date]
        ?? LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted
        
        LocalConfiguration.localPreviousDatesUserReviewRequested =
        fromUserDefaults.value(forKey: Constant.Key.localPreviousDatesUserReviewRequested.rawValue) as? [Date] ?? LocalConfiguration.localPreviousDatesUserReviewRequested
        
        LocalConfiguration.localAppVersionsWithReleaseNotesShown =
        fromUserDefaults.value(forKey: Constant.Key.localAppVersionsWithReleaseNotesShown.rawValue) as? [String]
        ?? LocalConfiguration.localAppVersionsWithReleaseNotesShown
        
        LocalConfiguration.localHasCompletedHoundIntroductionViewController =
        fromUserDefaults.value(forKey: Constant.Key.localHasCompletedHoundIntroductionViewController.rawValue) as? Bool
        ?? LocalConfiguration.localHasCompletedHoundIntroductionViewController
        
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController =
        fromUserDefaults.value(forKey: Constant.Key.localHasCompletedRemindersIntroductionViewController.rawValue) as? Bool
        ?? LocalConfiguration.localHasCompletedRemindersIntroductionViewController
        
        // Before 3.5.0 "localHasCompletedFamilyUpgradeIntroductionViewController" was "localHasCompletedSettingsFamilyIntroductionViewController"
        if let legacyValue = fromUserDefaults.value(forKey: "localHasCompletedSettingsFamilyIntroductionViewController") as? Bool {
            fromUserDefaults.set(legacyValue, forKey: Constant.Key.localHasCompletedFamilyUpgradeIntroductionViewController.rawValue)
            fromUserDefaults.removeObject(forKey: "localHasCompletedSettingsFamilyIntroductionViewController")
        }
        LocalConfiguration.localHasCompletedFamilyUpgradeIntroductionViewController =
        fromUserDefaults.value(forKey: Constant.Key.localHasCompletedFamilyUpgradeIntroductionViewController.rawValue) as? Bool ?? LocalConfiguration.localHasCompletedFamilyUpgradeIntroductionViewController
    }
    
    // MARK: Sync Related
    
    /// For our first every dogManager sync, we want to retrieve ever dog, reminder, and log (which can be a LOT of data as accounts accumlate logs over the years). To get everything the family has ever added, we set our last sync as far back in time as it will go. This will retrieve everything
    static var previousDogManagerSynchronization: Date?
    
    // MARK: Log Related
    
    /// An array storing the logCustomActionName input by the user. If the user selects a log as 'Custom' then puts in a custom name, it will be tracked here.
    static var localPreviousLogCustomActionNames: [PreviousLogCustomActionName] = []
    
    /// Add the custom log action name to the stored array of localPreviousLogCustomActionNames. If it is already present, then nothing changes, otherwise override the oldest one
    static func addLogCustomAction(forLogActionType: LogActionType, forLogCustomActionName: String) {
        // make sure its a valid custom type
        guard forLogActionType.allowsCustom else { return }
        
        // make sure the name actually contains something
        guard forLogCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else { return }
        
        // Remove any identical records to this, as we want these to all be unique
        localPreviousLogCustomActionNames.removeAll { previousLogCustomActionName in
            return previousLogCustomActionName.logActionTypeId == forLogActionType.logActionTypeId && previousLogCustomActionName.logCustomActionName == forLogCustomActionName
        }
        
        // Re-add at beginning of array
        localPreviousLogCustomActionNames.insert(
            PreviousLogCustomActionName(
                logActionTypeId: forLogActionType.logActionTypeId,
                logCustomActionName: forLogCustomActionName
            ),
            at: 0
        )
        
        // check to see if we are over capacity for this specific action type
        var countForType = 0
        for (index, element) in localPreviousLogCustomActionNames.enumerated().reversed() where element.logActionTypeId == forLogActionType.logActionTypeId {
            countForType += 1
            if countForType > 5 {
                localPreviousLogCustomActionNames.remove(at: index)
            }
            
        }
    }
    
    // MARK: Reminder Related
    
    /// An array storing the localPreviousReminderCustomActionNames input by the user. If the user selects a reminder as 'Custom' then puts in a custom name, it will be tracked here.
    static var localPreviousReminderCustomActionNames: [PreviousReminderCustomActionName] = []
    
    /// Add the custom reminder action name to the stored array of localPreviousReminderCustomActionNames. If it is already present, then nothing changes, otherwise override the oldest one
    static func addReminderCustomAction(forReminderActionType: ReminderActionType, forReminderCustomActionName: String) {
        // make sure its a valid custom type
        guard forReminderActionType.allowsCustom else { return }
        
        // make sure the name actually contains something
        guard forReminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else { return }
        
        // Remove any identical records to this, as we want these to all be unique
        localPreviousReminderCustomActionNames.removeAll { previousReminderCustomActionName in
            return previousReminderCustomActionName.reminderActionTypeId == forReminderActionType.reminderActionTypeId && previousReminderCustomActionName.reminderCustomActionName == forReminderCustomActionName
        }
        
        // Re-add at beginning of array
        localPreviousReminderCustomActionNames.insert(
            PreviousReminderCustomActionName(
                reminderActionTypeId: forReminderActionType.reminderActionTypeId,
                reminderCustomActionName: forReminderCustomActionName
            ),
            at: 0
        )
        
        // check to see if we are over capacity for this specific action type
        var countForType = 0
        for (index, element) in localPreviousReminderCustomActionNames.enumerated().reversed() where element.reminderActionTypeId == forReminderActionType.reminderActionTypeId {
            countForType += 1
            if countForType > 5 {
                localPreviousReminderCustomActionNames.remove(at: index)
            }
        }
    }
    
    // MARK: iOS Notification Related
    
    static var localIsNotificationAuthorized: Bool = false
    
    // MARK: Alert Related
    
    /// Used to track when the user was last asked to give survey feedback on their experience with Hound. We add a Date() to the array by default to signify when the app was installed (or the update for this feature was installed)
    static var localPreviousDatesUserSurveyFeedbackAppExperienceRequested: [Date] = []
    
    /// Used to track when the user last provided the survey feedback on their experience with Hound
    static var localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted: [Date] = []
    
    /// Used to track when the user was shown Apple's request review pop-up that allows the user to one to five star Hound
    static var localPreviousDatesUserReviewRequested: [Date] = []
    
    /// Keeps track of what Hound versions the release notes have been shown for. For example, if we show the release notes for Hound 2.0.0, then we will store 2.0.0 in the array. This makes sure the release notes are only shown once for a given update
    static var localAppVersionsWithReleaseNotesShown: [String] = []
    
    /// Keeps track of if the user has viewed AND completed the family introduction view controller (which helps the user setup their first dog)
    static var localHasCompletedHoundIntroductionViewController: Bool = false
    
    /// Keeps track of if the user has viewed AND completed the reminders introduction view controller (which helps the user setup their first reminders)
    static var localHasCompletedRemindersIntroductionViewController: Bool = false
    
    /// Keeps track of if the user has viewed AND completed the settings family introduction view controller (which helps notify the user of their family limits)
    static var localHasCompletedFamilyUpgradeIntroductionViewController: Bool = false
    
    /// Everytime Hound is restarted and entering from a terminated state, this value is set to Date(). Then when the app closes, it is set to Date() again. If Hound is closed for more than a certain time frame, using this variable to track how long it was closed, then we do certain actions, e.g. refresh the dog manager for new updates.
    static var localDateWhenAppLastEnteredBackground: Date = Date()
}
