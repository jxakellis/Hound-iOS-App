//
//  ReminderAlarmManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/20/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol ReminderAlarmManagerDelegate: AnyObject {
    func didAddLog(sender: Sender, dogUUID: UUID, log: Log, invokeDogTriggers: Bool)
    func didAddReminder(sender: Sender, dogUUID: UUID, reminder: Reminder)
    func didRemoveReminder(sender: Sender, dogUUID: UUID, reminderUUID: UUID)
}

final class ReminderAlarmManager {
    private class AlarmQueueItem {
        private(set) var dogName: String
        private(set) var dogUUID: UUID
        private(set) var reminder: Reminder

        init(dogName: String, dogUUID: UUID, reminder: Reminder) {
            self.dogName = dogName
            self.dogUUID = dogUUID
            self.reminder = reminder
        }
    }
    static weak var delegate: ReminderAlarmManagerDelegate!

    /// If the globalPresenter is not loaded, indicating that the app is in the background, we store all willCreateAndShowReminderAlarm calls in this alarmQueue. This ensures that once the app is opened, the alarm queue is executed so that it refreshes the most current information from the server.
    private static var alarmQueue: [AlarmQueueItem] = []

    /// Creates HoundAlarmAlertController to show the user about their alarm going off. We query the server with the information provided first to make sure it is up to date.
    static func willCreateAndShowReminderAlarm(dogName: String, dogUUID: UUID, reminder: Reminder) {
        // If the app is in the background, add the willCreateAndShowReminderAlarm to the queue. Once the app is brought to the foreground, executes synchronizeReminderAlarmQueueIfNeeded to attempt to reshow all of these alarms. This ensures that when the alarms are presented, the app is open. Otherwise, we could refresh the information for an alarm and present it, only for it to sit in the background for an hour while the app is closed, making the alarm outdated.
        guard UIApplication.shared.applicationState != .background else {
            // make sure we don't have multiple of the same alarm in the alarm queue
            alarmQueue.removeAll { alarmQueueItem in
                alarmQueueItem.dogUUID == dogUUID && alarmQueueItem.reminder.reminderUUID == reminder.reminderUUID
            }
            alarmQueue.append(AlarmQueueItem(dogName: dogName, dogUUID: dogUUID, reminder: reminder))
            return
        }

        // before presenting alarm, make sure we are up to date locally
        RemindersRequest.get(errorAlert: .automaticallyAlertForNone, dogUUID: dogUUID, reminder: reminder) { responseReminder, responseStatus, _ in
            guard responseStatus != .failureResponse else {
                return
            }

            guard let responseReminder = responseReminder else {
                // If the response was successful but no reminder was returned, that means the reminder was deleted. Therefore, tell the delegate as such.
                delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), dogUUID: dogUUID, reminderUUID: reminder.reminderUUID)
                return
            }

            // reminderExecutionDate must not be nil, otherwise if reminderExecutionDate is nil then the reminder was potentially was disabled or the reminder's timing components are broken.
            // the distance from present to executionDate must be negitive, otherwise if the distance is negative then executionDate in past
            guard let reminderExecutionDate = responseReminder.reminderExecutionDate, Date().distance(to: reminderExecutionDate) < 0 else {
                // We were able to retrieve the reminder and something was wrong with it. Something was disabled, the reminder was pushed back to the future, or it simply just has invalid timing components.
                // MARK: IMPORTANT - Do not try to refresh DogManager as that can (and does) cause an infinite loop. The reminder can exist but for some reason have invalid data leading to a nil executionDate. If we refresh the DogManager, we could retrieve the same invalid reminder data which leads back to this statement (and thus starts the infinite loop)

                self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), dogUUID: dogUUID, reminder: responseReminder)
                return
            }

            // the reminder exists, its executionDate exists, and its executionDate is in the past (meaning it should be valid).

            // the dogUUID and reminderUUID exist if we got a reminder back
            let title = "\(responseReminder.reminderActionType.convertToReadableName(customActionName: responseReminder.reminderCustomActionName)) - \(dogName)"

            let alarmAlertController = HoundAlarmAlertController(
                title: title,
                message: nil,
                preferredStyle: .alert)
            alarmAlertController.setup(dogUUID: dogUUID, reminder: responseReminder)

            var alertActionsForLog: [UIAlertAction] = []

            // Cant convert a reminderActionType of potty directly to logActionType, as it has serveral possible outcomes. Otherwise, logActionType and reminderActionType 1:1
            let logActionTypes: [LogActionType] = responseReminder.reminderActionType.associatedLogActionTypes

            for logActionType in logActionTypes {
                let logAlertAction = UIAlertAction(
                    title: "Log \(logActionType.convertToReadableName(customActionName: responseReminder.reminderCustomActionName))",
                    style: .default,
                    handler: { _ in
                        // alarmAlertController could have been absorbed into another alarmAlertController
                        let alartController = alarmAlertController.absorbedIntoAlarmAlertController ?? alarmAlertController

                        guard let alarmReminders = alartController.reminders else {
                            return
                        }

                        for alarmReminder in alarmReminders {
                            ReminderAlarmManager.userSelectedLogAlarm(dogUUID: dogUUID, reminder: alarmReminder, logActionType: logActionType)
                            ReminderTimingManager.didCompleteForReminderTimer(reminderUUID: alarmReminder.reminderUUID, type: .alarmTimer)
                        }
                        
                        ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
                    })
                alertActionsForLog.append(logAlertAction)
            }

            let snoozeAlertAction = UIAlertAction(
                title: "Snooze for \(UserConfiguration.snoozeLength.readable(capitalizeWords: false, abbreviationLevel: .short))",
                style: .default,
                handler: { (_: UIAlertAction!)  in
                    // alarmAlertController could have been absorbed into another alarmAlertController
                    let alartController = alarmAlertController.absorbedIntoAlarmAlertController ?? alarmAlertController

                    guard let alarmReminders = alartController.reminders else {
                        return
                    }

                    for alarmReminder in alarmReminders {
                        ReminderAlarmManager.userSelectedSnoozeAlarm(dogUUID: dogUUID, reminder: alarmReminder)
                        ReminderTimingManager.didCompleteForReminderTimer(reminderUUID: alarmReminder.reminderUUID, type: .alarmTimer)
                    }
                    
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
                        ReminderAlarmManager.userSelectedDismissAlarm(dogUUID: dogUUID, reminder: alarmReminder)
                        ReminderTimingManager.didCompleteForReminderTimer(reminderUUID: alarmReminder.reminderUUID, type: .alarmTimer)
                    }
                    
                    ShowBonusInformationManager.requestSurveyAppExperienceIfNeeded()
                })

            for logAlertAction in alertActionsForLog {
                alarmAlertController.addAction(logAlertAction)
            }
            
            alarmAlertController.addAction(snoozeAlertAction)
            alarmAlertController.addAction(dismissAlertAction)

            delegate.didAddReminder(sender: Sender(origin: self, localized: self), dogUUID: dogUUID, reminder: responseReminder)
            
            PresentationManager.enqueueAlert(alarmAlertController)
        }
    }

    /// Once the app is brought back into the foreground, meaning the alarms in the alarm queue can be presented, call this function to iterate through and present any alarms in the alarm queue
    static func synchronizeReminderAlarmQueueIfNeeded() {

        // Only attempt to show the alarms if the app isn't in the background
        guard UIApplication.shared.applicationState != .background else { return }

        let copiedAlarmQueue = alarmQueue
        alarmQueue = []

        // We can't iterate over alarmQueue as willCreateAndShowReminderAlarm could potentially add items to alarmQueue. That means we need to empty alarmQueue before iterating over to avoid mixing.
        for (index, alarmQueueItem) in copiedAlarmQueue.enumerated() {
            // First alarm (at front of queue... should come first): execute queries right now
            // Second alarm: execute queries after 25 ms to help ensure it comes second
            // Thirds alarm: execute queries after 50 ms to help ensure it comes third
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.05 * Double(index)), execute: {
                willCreateAndShowReminderAlarm(dogName: alarmQueueItem.dogName, dogUUID: alarmQueueItem.dogUUID, reminder: alarmQueueItem.reminder)
            })
        }
    }
    
    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Snooze' the reminder. Therefore we modify the timing data so the reminder turns into .snooze mode, alerting them again soon. We don't add a log
    private static func userSelectedSnoozeAlarm(dogUUID: UUID, reminder: Reminder) {
        reminder.resetForNextAlarm()
        reminder.snoozeComponents.changeExecutionInterval(UserConfiguration.snoozeLength)

        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, reminders: [reminder]) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                return
            }

            delegate.didAddReminder(sender: Sender(origin: self, localized: self), dogUUID: dogUUID, reminder: reminder)
        }

    }

    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Dismiss' the reminder. Therefore we reset the timing data and don't add a log.
    private static func userSelectedDismissAlarm(dogUUID: UUID, reminder: Reminder) {
        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // just make request to delete reminder for oneTime remidner
            RemindersRequest.delete(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, reminderUUIDs: [reminder.reminderUUID]) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    return
                }

                delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), dogUUID: dogUUID, reminderUUID: reminder.reminderUUID)
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            // the reminder just executed an alarm/alert, so we want to reset its stuff
            reminder.resetForNextAlarm()

            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, reminders: [reminder]) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    return
                }

                delegate.didAddReminder(sender: Sender(origin: self, localized: self), dogUUID: dogUUID, reminder: reminder)
            }
        }

    }

    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Log' the reminder. Therefore we reset the timing data and add a log.
    private static func userSelectedLogAlarm(dogUUID: UUID, reminder: Reminder, logActionType: LogActionType) {
        let log = Log(logCreatedByReminderUUID: reminder.reminderUUID)
        log.logActionTypeId = logActionType.logActionTypeId
        log.logCustomActionName = reminder.reminderCustomActionName
        log.changeLogDate(logStartDate: Date(), logEndDate: nil)

        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // make request to add log, then (if successful) make request to delete reminder

            // delete the reminder on the server
            RemindersRequest.delete(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, reminderUUIDs: [reminder.reminderUUID]) { responseStatusReminderDelete, _ in
                guard responseStatusReminderDelete != .failureResponse else {
                    return
                }

                delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), dogUUID: dogUUID, reminderUUID: reminder.reminderUUID)
                // create log on the server and then assign it the logUUID and then add it to the dog
                LogsRequest.create(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, log: log) { responseStatusLogCreate, _ in
                    guard responseStatusLogCreate != .failureResponse else {
                        return
                    }

                    delegate.didAddLog(sender: Sender(origin: self, localized: self), dogUUID: dogUUID, log: log, invokeDogTriggers: reminder.reminderIsTriggerResult == false)
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            // the reminder just executed an alarm/alert, so we want to reset its stuff
            reminder.resetForNextAlarm()

            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, reminders: [reminder]) { responseStatusReminderUpdate, _ in
                guard responseStatusReminderUpdate != .failureResponse else {
                    return
                }

                delegate.didAddReminder(sender: Sender(origin: self, localized: self), dogUUID: dogUUID, reminder: reminder)
                // we need to persist a log as well
                LogsRequest.create(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, log: log) { responseStatusLogCreate, _ in
                    guard responseStatusLogCreate != .failureResponse else {
                        return
                    }

                    delegate.didAddLog(sender: Sender(origin: self, localized: self), dogUUID: dogUUID, log: log, invokeDogTriggers: reminder.reminderIsTriggerResult == false)
                }
            }
        }

    }
}
