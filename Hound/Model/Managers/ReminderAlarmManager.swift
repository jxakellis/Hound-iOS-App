//
//  ReminderAlarmManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/20/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol ReminderAlarmManagerDelegate: AnyObject {
    func didAddLog(sender: Sender, forDogUUID: UUID, forLog: Log)
    func didAddReminder(sender: Sender, forDogUUID: UUID, forReminder: Reminder)
    func didRemoveReminder(sender: Sender, forDogUUID: UUID, forReminderUUID: UUID)
}

final class ReminderAlarmManager {
    private class AlarmQueueItem {
        private(set) var dogName: String
        private(set) var dogUUID: UUID
        private(set) var reminder: Reminder

        init(forDogName: String, forDogUUID: UUID, forReminder: Reminder) {
            self.dogName = forDogName
            self.dogUUID = forDogUUID
            self.reminder = forReminder
        }
    }
    static private weak var delegate: ReminderAlarmManagerDelegate!

    /// If the globalPresenter is not loaded, indicating that the app is in the background, we store all willCreateAndShowReminderAlarm calls in this alarmQueue. This ensures that once the app is opened, the alarm queue is executed so that it refreshes the most current information from the server.
    private static var alarmQueue: [AlarmQueueItem] = []

    /// Creates AlarmUIAlertController to show the user about their alarm going off. We query the server with the information provided first to make sure it is up to date.
    static func willCreateAndShowReminderAlarm(forDogName: String, forDogUUID: UUID, forReminder: Reminder) {
        // If the app is in the background, add the willCreateAndShowReminderAlarm to the queue. Once the app is brought to the foreground, executes synchronizeReminderAlarmQueueIfNeeded to attempt to reshow all of these alarms. This ensures that when the alarms are presented, the app is open. Otherwise, we could refresh the information for an alarm and present it, only for it to sit in the background for an hour while the app is closed, making the alarm outdated.
        guard UIApplication.shared.applicationState != .background else {
            // make sure we don't have multiple of the same alarm in the alarm queue
            alarmQueue.removeAll { alarmQueueItem in
                alarmQueueItem.dogUUID == forDogUUID && alarmQueueItem.reminder.reminderUUID == forReminder.reminderUUID
            }
            alarmQueue.append(AlarmQueueItem(forDogName: forDogName, forDogUUID: forDogUUID, forReminder: forReminder))
            return
        }

        // before presenting alarm, make sure we are up to date locally
        RemindersRequest.get(forErrorAlert: .automaticallyAlertForNone, forDogUUID: forDogUUID, forReminder: forReminder) { reminder, responseStatus, _ in
            guard responseStatus != .failureResponse else {
                return
            }

            guard let reminder = reminder else {
                // If the response was successful but no reminder was returned, that means the reminder was deleted. Therefore, tell the delegate as such.
                delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forReminderUUID: forReminder.reminderUUID)
                return
            }

            // reminderExecutionDate must not be nil, otherwise if reminderExecutionDate is nil then the reminder was potentially was disabled or the reminder's timing components are broken.
            // the distance from present to executionDate must be negitive, otherwise if the distance is negative then executionDate in past
            guard let reminderExecutionDate = reminder.reminderExecutionDate, Date().distance(to: reminderExecutionDate) < 0 else {
                // We were able to retrieve the reminder and something was wrong with it. Something was disabled, the reminder was pushed back to the future, or it simply just has invalid timing components.
                // MARK: IMPORTANT - Do not try to refresh DogManager as that can (and does) cause an infinite loop. The reminder can exist but for some reason have invalid data leading to a nil executionDate. If we refresh the DogManager, we could retrieve the same invalid reminder data which leads back to this statement (and thus starts the infinite loop)

                self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forReminder: forReminder)
                return
            }

            // the reminder exists, its executionDate exists, and its executionDate is in the past (meaning it should be valid).

            // the dogUUID and reminderUUID exist if we got a reminder back
            let title = "\(reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName)) - \(forDogName)"

            let alarmAlertController = AlarmUIAlertController(
                title: title,
                message: nil,
                preferredStyle: .alert)
            alarmAlertController.setup(forDogUUID: forDogUUID, forReminder: reminder)

            var alertActionsForLog: [UIAlertAction] = []

            // Cant convert a reminderActionType of potty directly to logActionType, as it has serveral possible outcomes. Otherwise, logActionType and reminderActionType 1:1
            let logActionTypes: [LogActionType] = reminder.reminderActionType.associatedLogActionTypes

            for logActionType in logActionTypes {
                let logAlertAction = UIAlertAction(
                    title: "Log \(logActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName))",
                    style: .default,
                    handler: { _ in
                        // alarmAlertController could have been absorbed into another alarmAlertController
                        let alartController = alarmAlertController.absorbedIntoAlarmAlertController ?? alarmAlertController

                        guard let alarmReminders = alartController.reminders else {
                            return
                        }

                        for alarmReminder in alarmReminders {
                            ReminderAlarmManager.userSelectedLogAlarm(forDogUUID: forDogUUID, forReminder: alarmReminder, forLogActionType: logActionType)
                            ReminderTimingManager.didCompleteForReminderTimer(forReminderUUID: alarmReminder.reminderUUID, forType: .alarmTimer)
                        }
                        
                        ShowBonusInformationManager.requestAppStoreReviewIfNeeded()
                        ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
                    })
                alertActionsForLog.append(logAlertAction)
            }

            let snoozeAlertAction = UIAlertAction(
                title: "Snooze",
                style: .default,
                handler: { (_: UIAlertAction!)  in
                    // alarmAlertController could have been absorbed into another alarmAlertController
                    let alartController = alarmAlertController.absorbedIntoAlarmAlertController ?? alarmAlertController

                    guard let alarmReminders = alartController.reminders else {
                        return
                    }

                    for alarmReminder in alarmReminders {
                        ReminderAlarmManager.userSelectedSnoozeAlarm(forDogUUID: forDogUUID, forReminder: alarmReminder)
                        ReminderTimingManager.didCompleteForReminderTimer(forReminderUUID: alarmReminder.reminderUUID, forType: .alarmTimer)
                    }
                    
                    ShowBonusInformationManager.requestAppStoreReviewIfNeeded()
                    ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
                })

            let dismissAlertAction = UIAlertAction(
                title: "Dismiss",
                style: .cancel,
                handler: { (_: UIAlertAction!)  in
                    // alarmAlertController could have been absorbed into another alarmAlertController
                    let alartController = alarmAlertController.absorbedIntoAlarmAlertController ?? alarmAlertController

                    guard let alarmReminders = alartController.reminders else {
                        return
                    }

                    for alarmReminder in alarmReminders {
                        ReminderAlarmManager.userSelectedDismissAlarm(forDogUUID: forDogUUID, forReminder: alarmReminder)
                        ReminderTimingManager.didCompleteForReminderTimer(forReminderUUID: alarmReminder.reminderUUID, forType: .alarmTimer)
                    }
                    
                    ShowBonusInformationManager.requestAppStoreReviewIfNeeded()
                    ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
                })

            for logAlertAction in alertActionsForLog {
                alarmAlertController.addAction(logAlertAction)
            }
            
            alarmAlertController.addAction(snoozeAlertAction)
            alarmAlertController.addAction(dismissAlertAction)

            delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forReminder: reminder)
            
            PresentationManager.enqueueAlert(alarmAlertController)
        }
    }

    /// Once the app is brought back into the foreground, meaning the alarms in the alarm queue can be presented, call this function to iterate through and present any alarms in the alarm queue
    static func synchronizeReminderAlarmQueueIfNeeded() {

        // Only attempt to show the alarms if the app isn't in the background
        guard UIApplication.shared.applicationState != .background else {
            return
        }

        let copiedAlarmQueue = alarmQueue
        alarmQueue = []

        // We can't iterate over alarmQueue as willCreateAndShowReminderAlarm could potentially add items to alarmQueue. That means we need to empty alarmQueue before iterating over to avoid mixing.
        for (index, alarmQueueItem) in copiedAlarmQueue.enumerated() {
            // First alarm (at front of queue... should come first): execute queries right now
            // Second alarm: execute queries after 25 ms to help ensure it comes second
            // Thirds alarm: execute queries after 50 ms to help ensure it comes third
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.05 * Double(index)), execute: {
                willCreateAndShowReminderAlarm(forDogName: alarmQueueItem.dogName, forDogUUID: alarmQueueItem.dogUUID, forReminder: alarmQueueItem.reminder)
            })
        }
    }
    
    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Snooze' the reminder. Therefore we modify the timing data so the reminder turns into .snooze mode, alerting them again soon. We don't add a log
    private static func userSelectedSnoozeAlarm(forDogUUID: UUID, forReminder: Reminder) {
        forReminder.resetForNextAlarm()
        forReminder.snoozeComponents.executionInterval = UserConfiguration.snoozeLength

        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forReminders: [forReminder]) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                return
            }

            delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forReminder: forReminder)
        }

    }

    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Dismiss' the reminder. Therefore we reset the timing data and don't add a log.
    private static func userSelectedDismissAlarm(forDogUUID: UUID, forReminder: Reminder) {
        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if forReminder.reminderType == .oneTime {
            // just make request to delete reminder for oneTime remidner
            RemindersRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forReminderUUIDs: [forReminder.reminderUUID]) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    return
                }

                delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forReminderUUID: forReminder.reminderUUID)
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            // the reminder just executed an alarm/alert, so we want to reset its stuff
            forReminder.resetForNextAlarm()

            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forReminders: [forReminder]) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    return
                }

                delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forReminder: forReminder)
            }
        }

    }

    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Log' the reminder. Therefore we reset the timing data and add a log.
    private static func userSelectedLogAlarm(forDogUUID: UUID, forReminder: Reminder, forLogActionType: LogActionType) {
        let log = Log()
        log.logActionTypeId = forLogActionType.logActionTypeId
        log.logCustomActionName = forReminder.reminderCustomActionName
        log.changeLogDate(forLogStartDate: Date(), forLogEndDate: nil)

        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if forReminder.reminderType == .oneTime {
            // make request to add log, then (if successful) make request to delete reminder

            // delete the reminder on the server
            RemindersRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forReminderUUIDs: [forReminder.reminderUUID]) { responseStatusReminderDelete, _ in
                guard responseStatusReminderDelete != .failureResponse else {
                    return
                }

                delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forReminderUUID: forReminder.reminderUUID)
                // create log on the server and then assign it the logUUID and then add it to the dog
                LogsRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forLog: log) { responseStatusLogCreate, _ in
                    guard responseStatusLogCreate != .failureResponse else {
                        return
                    }

                    delegate.didAddLog(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forLog: log)
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            // the reminder just executed an alarm/alert, so we want to reset its stuff
            forReminder.resetForNextAlarm()

            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forReminders: [forReminder]) { responseStatusReminderUpdate, _ in
                guard responseStatusReminderUpdate != .failureResponse else {
                    return
                }

                delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forReminder: forReminder)
                // we need to persist a log as well
                LogsRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forLog: log) { responseStatusLogCreate, _ in
                    guard responseStatusLogCreate != .failureResponse else {
                        return
                    }

                    delegate.didAddLog(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forLog: log)
                }
            }
        }

    }
}
