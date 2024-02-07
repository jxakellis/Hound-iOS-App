//
//  LocalConfiguration.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import KeychainSwift
import StoreKit
import UIKit

/// Configuration that is local to the app only. If the app is reinstalled then this data should be fresh
enum LocalConfiguration {
    // MARK: Sync Related

    /// For our first every dogManager sync, we want to retrieve ever dog, reminder, and log (which can be a LOT of data as accounts accumlate logs over the years). To get everything the family has ever added, we set our last sync as far back in time as it will go. This will retrieve everything
    static var previousDogManagerSynchronization: Date?

    // MARK: Log Related

    /// An array storing the logCustomActionName input by the user. If the user selects a log as 'Custom' then puts in a custom name, it will be tracked here.
    static var localPreviousLogCustomActionNames: [PreviousLogCustomActionName] = []

    /// Add the custom log action name to the stored array of localPreviousLogCustomActionNames. If it is already present, then nothing changes, otherwise override the oldest one
    static func addLogCustomAction(forLogAction: LogAction, forLogCustomActionName: String) {
        // make sure its a valid custom type
        guard forLogAction == .medicine || forLogAction == .vaccine || forLogAction == .custom else {
            return
        }
        
        // make sure the name actually contains something
        guard forLogCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return
        }

        // Remove any identical records to this, as we want these to all be unique
        localPreviousLogCustomActionNames.removeAll { previousLogCustomActionName in
            return previousLogCustomActionName.logAction == forLogAction && previousLogCustomActionName.logCustomActionName == forLogCustomActionName
        }
        
        // Re-add at beginning of array
        localPreviousLogCustomActionNames.insert(PreviousLogCustomActionName(logAction: forLogAction, logCustomActionName: forLogCustomActionName), at: 0)
        
        // check to see if we are over capacity, if we are then remove the last item
        if localPreviousLogCustomActionNames.count > 5 {
            localPreviousLogCustomActionNames.removeLast()
        }
    }

    // MARK: Reminder Related

    /// An array storing the localPreviousReminderCustomActionNames input by the user. If the user selects a reminder as 'Custom' then puts in a custom name, it will be tracked here.
    static var localPreviousReminderCustomActionNames: [PreviousReminderCustomActionName] = []

    /// Add the custom reminder action name to the stored array of localPreviousReminderCustomActionNames. If it is already present, then nothing changes, otherwise override the oldest one
    static func addReminderCustomAction(forReminderAction: ReminderAction, forReminderCustomActionName: String) {
        // make sure its a valid custom type
        guard forReminderAction == .medicine || forReminderAction == .custom else {
            return
        }
        
        // make sure the name actually contains something
        guard forReminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return
        }

        // Remove any identical records to this, as we want these to all be unique
        localPreviousReminderCustomActionNames.removeAll { previousReminderCustomActionName in
            return previousReminderCustomActionName.reminderAction == forReminderAction && previousReminderCustomActionName.reminderCustomActionName == forReminderCustomActionName
        }
        
        // Re-add at beginning of array
        localPreviousReminderCustomActionNames.insert(PreviousReminderCustomActionName(reminderAction: forReminderAction, reminderCustomActionName: forReminderCustomActionName), at: 0)
        
        // check to see if we are over capacity, if we are then remove the last item
        if localPreviousReminderCustomActionNames.count > 5 {
            localPreviousReminderCustomActionNames.removeLast()
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
    static var localHasCompletedSettingsFamilyIntroductionViewController: Bool = false

    /// Keeps track of if the user has view AND completed the legacy subscription warning view controller (which warns users that the subscription they have is soon to be discontinued).
    static var localHasCompletedDepreciatedVersion1SubscriptionWarningAlertController: Bool = false

    /// Everytime Hound is restarted and entering from a terminated state, this value is set to Date(). Then when the app closes, it is set to Date() again. If Hound is closed for more than a certain time frame, using this variable to track how long it was closed, then we do certain actions, e.g. refresh the dog manager for new updates.
    static var localDateWhenAppLastEnteredBackground: Date = Date()
}
