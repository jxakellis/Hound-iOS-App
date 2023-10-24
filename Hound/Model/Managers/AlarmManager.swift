//
//  AlarmManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/20/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol AlarmManagerDelegate: AnyObject {
    func didAddLog(sender: Sender, forDogId: Int, forLog: Log)
    func didRemoveLog(sender: Sender, forDogId: Int, forLogId: Int)
    func didAddReminder(sender: Sender, forDogId: Int, forReminder: Reminder)
    func didRemoveReminder(sender: Sender, forDogId: Int, forReminderId: Int)
}

final class AlarmManager {
    private class AlarmQueueItem {
        private(set) var dogName: String
        private(set) var dogId: Int
        private(set) var reminder: Reminder

        init(dogName: String, dogId: Int, reminder: Reminder) {
            self.dogName = dogName
            self.dogId = dogId
            self.reminder = reminder
        }
    }
    static weak var delegate: AlarmManagerDelegate!

    /// If the globalPresenter is not loaded, indicating that the app is in the background, we store all willShowAlarm calls in this alarmQueue. This ensures that once the app is opened, the alarm queue is executed so that it refreshes the most current information from the server.
    private static var alarmQueue: [AlarmQueueItem] = []

    /// Creates AlarmUIAlertController to show the user about their alarm going off. We query the server with the information provided first to make sure it is up to date.
    static func willShowAlarm(forDogName: String, forDogId: Int, forReminder: Reminder) {
        // If the app is in the background, add the willShowAlarm to the queue. Once the app is brought to the foreground, executes synchronizeAlarmQueue to attempt to reshow all of these alarms. This ensures that when the alarms are presented, the app is open. Otherwise, we could refresh the information for an alarm and present it, only for it to sit in the background for an hour while the app is closed, making the alarm outdated.
        guard UIApplication.shared.applicationState != .background else {
            // make sure we don't have multiple of the same alarm in the alarm queue
            alarmQueue.removeAll { alarmQueueItem in
                alarmQueueItem.dogId == forDogId && alarmQueueItem.reminder.reminderId == forReminder.reminderId
            }
            alarmQueue.append(AlarmQueueItem(dogName: forDogName, dogId: forDogId, reminder: forReminder))
            return
        }

        // before presenting alarm, make sure we are up to date locally
        RemindersRequest.get(invokeErrorManager: false, forDogId: forDogId, forReminder: forReminder) { reminder, responseStatus, _ in

            // If we got no response, then halt here as we were unable to retrieve the updated reminder
            guard responseStatus != .noResponse else {
                return
            }

            guard let reminder = reminder else {
                if responseStatus == .successResponse {
                    // If the response was successful but no reminder was returned, that means the reminder was deleted. Therefore, tell the delegate as such. Don't clearTimers() as this reminder should never have a timer again due to being deleted.
                    delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: forDogId, forReminderId: forReminder.reminderId)
                }
                return
            }

            // reminderExecutionDate must not be nil, otherwise if reminderExecutionDate is nil then the reminder was potentially was disabled or the reminder's timing components are broken.
            // the distance from present to executionDate must be negitive, otherwise if the distance is negative then executionDate in past
            guard let reminderExecutionDate = reminder.reminderExecutionDate, Date().distance(to: reminderExecutionDate) < 0 else {
                // We were able to retrieve the reminder and something was wrong with it. Something was disabled, the reminder was pushed back to the future, or it simply just has invalid timing components.
                // MARK: IMPORTANT - Do not try to refresh DogManager as that can (and does) cause an infinite loop. The reminder can exist but for some reason have invalid data leading to a nil executionDate. If we refresh the DogManager, we could retrieve the same invalid reminder data which leads back to this statement (and thus starts the infinite loop)
                // safe to clearTimers. If reminderExecutionDate is nil, then TimingManager won't assign the reminder a new timer. Otherwise, TimingManager will assign the reminder a
                reminder.clearTimers()

                self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: forDogId, forReminder: reminder)
                return
            }

            // the reminder exists, its executionDate exists, and its executionDate is in the past (meaning it should be valid).

            // the dogId and reminderId exist if we got a reminder back
            let title = "\(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName)) - \(forDogName)"

            let alarmAlertController = AlarmUIAlertController(
                title: title,
                message: nil,
                preferredStyle: .alert)
            alarmAlertController.setup(forDogId: forDogId, forReminder: reminder)

            var alertActionsForLog: [UIAlertAction] = []

            // Cant convert a reminderAction of potty directly to logAction, as it has serveral possible outcomes. Otherwise, logAction and reminderAction 1:1
            let logActions: [LogAction] = reminder.reminderAction == .potty ? [.pee, .poo, .both, .neither, .accident] : [LogAction(rawValue: reminder.reminderAction.rawValue) ?? ClassConstant.LogConstant.defaultLogAction]

            for logAction in logActions {
                let logAlertAction = UIAlertAction(
                    title: "Log \(logAction.displayActionName(logCustomActionName: reminder.reminderCustomActionName))",
                    style: .default,
                    handler: { _ in
                        // alarmAlertController could have been absorbed into another alarmAlertController
                        let alartController = alarmAlertController.absorbedIntoAlarmAlertController ?? alarmAlertController

                        guard let alarmReminders = alartController.reminders else {
                            return
                        }

                        for alarmReminder in alarmReminders {
                            AlarmManager.willLogAlarm(forDogId: forDogId, forReminder: alarmReminder, forLogAction: logAction)
                        }
                        CheckManager.checkForReview()
                        CheckManager.checkForShareHound()
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
                        AlarmManager.willSnoozeAlarm(forDogId: forDogId, forReminder: alarmReminder)
                    }
                    CheckManager.checkForReview()
                    CheckManager.checkForShareHound()
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
                        AlarmManager.willDismissAlarm(forDogId: forDogId, forReminder: alarmReminder)
                    }
                    CheckManager.checkForReview()
                    CheckManager.checkForShareHound()
                })

            for logAlertAction in alertActionsForLog {
                alarmAlertController.addAction(logAlertAction)
            }
            alarmAlertController.addAction(snoozeAlertAction)
            alarmAlertController.addAction(dismissAlertAction)

            // Don't clearTimers. The timer is the marker that this reminder has its alerts handled. Clearing timers would cause an infinite loop.
            // The delegate is safe to call at this point in time. Any other reminders which have executed and called didExecuteReminderAlarmTimer are locked, TimingManager can't affect their timers.

            delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: forDogId, forReminder: reminder)

            PresentationManager.enqueueAlert(alarmAlertController)
        }
    }

    /// Once the app is brought back into the foreground, meaning the alarms in the alarm queue can be presented, call this function to iterate through and present any alarms in the alarm queue
    static func synchronizeAlarmQueue() {

        // Only attempt to show the alarms if the app isn't in the background
        guard UIApplication.shared.applicationState != .background else {
            return
        }

        let copiedAlarmQueue = alarmQueue
        alarmQueue = []

        // We can't iterate over alarmQueue as willShowAlarm could potentially add items to alarmQueue. That means we need to empty alarmQueue before iterating over to avoid mixing.
        for (index, alarmQueueItem) in copiedAlarmQueue.enumerated() {
            // First alarm (at front of queue... should come first): execute queries right now
            // Second alarm: execute queries after 25 ms to help ensure it comes second
            // Thirds alarm: execute queries after 50 ms to help ensure it comes third
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.05 * Double(index)), execute: {
                willShowAlarm(forDogName: alarmQueueItem.dogName, forDogId: alarmQueueItem.dogId, forReminder: alarmQueueItem.reminder)
            })
        }
    }
    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Snooze' the reminder. Therefore we modify the timing data so the reminder turns into .snooze mode, alerting them again soon. We don't add a log
    private static func willSnoozeAlarm(forDogId dogId: Int, forReminder reminder: Reminder) {
        // update information
        reminder.resetForNextAlarm()

        reminder.snoozeComponents.executionInterval = UserConfiguration.snoozeLength

        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _, _ in
            guard requestWasSuccessful else {
                return
            }

            delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
        }

    }

    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Dismiss' the reminder. Therefore we reset the timing data and don't add a log.
    private static func willDismissAlarm(forDogId dogId: Int, forReminder reminder: Reminder) {
        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // just make request to delete reminder for oneTime remidner
            RemindersRequest.delete(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _, _ in
                guard requestWasSuccessful else {
                    return
                }

                delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminderId: reminder.reminderId)
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            // the reminder just executed an alarm/alert, so we want to reset its stuff
            reminder.resetForNextAlarm()

            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _, _ in
                guard requestWasSuccessful else {
                    return
                }

                delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
            }
        }

    }

    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Log' the reminder. Therefore we reset the timing data and add a log.
    private static func willLogAlarm(forDogId dogId: Int, forReminder reminder: Reminder, forLogAction logAction: LogAction) {
        let log = Log()
        log.changeLogAction(forLogAction: logAction)
        try? log.changeLogCustomActionName(forLogCustomActionName: reminder.reminderCustomActionName)
        log.logDate = Date()

        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // make request to add log, then (if successful) make request to delete reminder

            // delete the reminder on the server
            RemindersRequest.delete(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { reminderRequestWasSuccessful, _, _ in
                guard reminderRequestWasSuccessful else {
                    return
                }

                delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminderId: reminder.reminderId)
                // create log on the server and then assign it the logId and then add it to the dog
                LogsRequest.create(invokeErrorManager: true, forDogId: dogId, forLog: log) { logRequestWasSuccessful, _, _ in
                    guard logRequestWasSuccessful else {
                        return
                    }

                    delegate.didAddLog(sender: Sender(origin: self, localized: self), forDogId: dogId, forLog: log)
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            // the reminder just executed an alarm/alert, so we want to reset its stuff
            reminder.resetForNextAlarm()

            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { reminderRequestWasSuccessful, _, _ in
                guard reminderRequestWasSuccessful else {
                    return
                }

                delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
                // we need to persist a log as well
                LogsRequest.create(invokeErrorManager: true, forDogId: dogId, forLog: log) { logRequestWasSuccessful, _, _ in
                    guard logRequestWasSuccessful else {
                        return
                    }

                    delegate.didAddLog(sender: Sender(origin: self, localized: self), forDogId: dogId, forLog: log)
                }
            }
        }

    }

    /// The user went to log/skip a reminder on the reminders page. Must updating skipping data and add a log. Only provide a UIViewController if you wish the spinning checkmark animation to happen.
    static func willSkipReminder(forDogId dogId: Int, forReminder reminder: Reminder, forLogAction logAction: LogAction) {
        let log = Log()
        log.changeLogAction(forLogAction: logAction)
        try? log.changeLogCustomActionName(forLogCustomActionName: reminder.reminderCustomActionName)
        log.logDate = Date()

        // special case. Once a oneTime reminder executes/ is skipped, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // make request to add log, then (if successful) make request to delete reminder

            // delete the reminder on the server
            RemindersRequest.delete(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { reminderRequestWasSuccessful, _, _ in
                guard reminderRequestWasSuccessful else {
                    return
                }

                delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminderId: reminder.reminderId)
                // create log on the server and then assign it the logId and then add it to the dog
                LogsRequest.create(invokeErrorManager: true, forDogId: dogId, forLog: log) { logRequestWasSuccessful, _, _ in
                    guard logRequestWasSuccessful else {
                        return
                    }

                    delegate.didAddLog(sender: Sender(origin: self, localized: self), forDogId: dogId, forLog: log)
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            reminder.enableIsSkipping(forSkippedDate: Date())

            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { reminderRequestWasSuccessful, _, _ in
                guard reminderRequestWasSuccessful else {
                    return
                }

                delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
                // we need to persist a log as well
                LogsRequest.create(invokeErrorManager: true, forDogId: dogId, forLog: log) { logRequestWasSuccessful, _, _ in
                    guard logRequestWasSuccessful else {
                        return
                    }

                    delegate.didAddLog(sender: Sender(origin: self, localized: self), forDogId: dogId, forLog: log)
                }
            }
        }
    }

    /// The user went to unlog/unskip a reminder on the reminders page. Must update skipping information. Note: only weekly/monthly reminders can be skipped therefore only they can be unskipped.
    static func willUnskipReminder(forDog dog: Dog, forReminder reminder: Reminder) {

        // we can only unskip a weekly/monthly reminder that is currently isSkipping == true
        guard (reminder.reminderType == .weekly && reminder.weeklyComponents.isSkipping == true) || (reminder.reminderType == .monthly && reminder.monthlyComponents.isSkipping == true) else {
            return
        }

        // this is the time that the reminder's next alarm was skipped. at this same moment, a log was added. If this log is still there, with it's date unmodified by the user, then we remove it.
        let dateOfLogToRemove: Date = {
            if reminder.reminderType == .weekly {
                return reminder.weeklyComponents.skippedDate ?? ClassConstant.DateConstant.default1970Date
            }
            else if reminder.reminderType == .monthly {
                return reminder.monthlyComponents.skippedDate ?? ClassConstant.DateConstant.default1970Date
            }
            else {
                return ClassConstant.DateConstant.default1970Date
            }
        }()

        reminder.disableIsSkipping()

        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(invokeErrorManager: true, forDogId: dog.dogId, forReminder: reminder) { requestWasSuccessful1, _, _ in
            guard requestWasSuccessful1 else {
                return
            }

            delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: dog.dogId, forReminder: reminder)

            // find log that is incredibly close the time where the reminder was skipped, once found, then we delete it.
            var logToRemove: Log?
            
            for log in dog.dogLogs.logs where abs(dateOfLogToRemove.distance(to: log.logDate)) < 0.001 {
                logToRemove = log
                break
            }

            guard let logToRemove = logToRemove else {
                return
            }

            // log to remove from unlog event. Attempt to delete the log server side
            LogsRequest.delete(invokeErrorManager: true, forDogId: dog.dogId, forLogId: logToRemove.logId) { requestWasSuccessful2, _, _ in
                guard requestWasSuccessful2 else {
                    return
                }

                delegate.didRemoveLog(sender: Sender(origin: self, localized: self), forDogId: dog.dogId, forLogId: logToRemove.logId)
            }

        }
    }
}
