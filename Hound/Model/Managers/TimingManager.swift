//
//  Timing.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol TimingManagerDelegate: AnyObject {
    func didAddReminder(sender: Sender, forDogUUID: UUID, forReminder: Reminder)
    func didRemoveReminder(sender: Sender, forDogUUID: UUID, forReminderUUID: UUID)
}

final class TimingManager {

    // MARK: - Properties

    static weak var delegate: TimingManagerDelegate!

    // MARK: - Main

    /// Initializes all reminder timers
    static func initializeReminderTimers(forDogManager dogManager: DogManager) {
        for dog in dogManager.dogs {
            for reminder in dog.dogReminders.reminders {
                // if the reminder has a execution date, then create its timers
                guard reminder.reminderIsEnabled == true, let reminderExecutionDate = reminder.reminderExecutionDate else {
                    // the reminder is disabled and can't have any timers, make sure that its timers are cleared as such
                    reminder.clearTimers()
                    continue
                }

                // if the reminder doesn't have a reminderAlarmTimer or the reminderAlarmTimer hasn't fired yet, assign the reminder a new reminderAlarmTimer. If the reminderAlarmTimer fireDate is nil but there exists a reminderAlarmTimer, that means there is a timer when one shouldn't exist. However, do nothing as this timer could be a placeholder preventing replication.
                if reminder.reminderAlarmTimer == nil || reminder.reminderAlarmTimer?.fireDate ?? Date(timeIntervalSince1970: 0.0) > Date() {
                    let reminderAlarmTimer = Timer(
                                      fireAt: reminderExecutionDate,
                                      interval: -1,
                                      target: self,
                                      selector: #selector(self.didExecuteReminderAlarmTimer(sender:)),
                                      userInfo: [
                                        KeyConstant.dogName.rawValue: dog.dogName,
                                        KeyConstant.dogUUID.rawValue: dog.dogUUID.uuidString,
                                        KeyConstant.reminder.rawValue: reminder
                                      ] as [String: Any],
                                      repeats: false)
                    reminder.reminderAlarmTimer = reminderAlarmTimer
                    RunLoop.main.add(reminderAlarmTimer, forMode: .common)
                }

                // Sets a timer that executes when the timer should go from isSkipping true -> false.
                // If the reminder doesn't have a reminderDisableIsSkippingTimer or the reminderDisableIsSkippingTimer hasn't fired yet, assign the reminder a new reminderDisableIsSkippingTimer.  If the reminderDisableIsSkippingTimer fireDate is nil but there exists a reminderDisableIsSkippingTimer, that means there is a timer when one shouldn't exist. However, do nothing as this timer could be a placeholder preventing replication.
                if reminder.reminderDisableIsSkippingTimer == nil || reminder.reminderDisableIsSkippingTimer?.fireDate ?? Date(timeIntervalSince1970: 0.0) > Date(), let disableIsSkippingDate = reminder.disableIsSkippingDate {
                    let reminderDisableIsSkippingTimer = Timer(fireAt: disableIsSkippingDate,
                                                   interval: -1,
                                                   target: self,
                                                   selector: #selector(didExecuteReminderDisableIsSkippingTimer(sender:)),
                                                   userInfo: [
                                                    KeyConstant.dogUUID.rawValue: dog.dogUUID.uuidString,
                                                        KeyConstant.reminder.rawValue: reminder
                                                   ] as [String: Any?],
                                                   repeats: false)
                    reminder.reminderDisableIsSkippingTimer = reminderDisableIsSkippingTimer
                    RunLoop.main.add(reminderDisableIsSkippingTimer, forMode: .common)
                }
            }
        }
    }

    // MARK: - Timer Actions

    /// Used as a selector when constructing timer in initializeReminderTimers. Invoke AlarmManager to show alart controller for reminder alarm
    @objc private static func didExecuteReminderAlarmTimer(sender: Timer) {
        // Parses the sender info needed to figure out which reminder's timer fired
        guard let userInfo = sender.userInfo as? [String: Any] else {
            return
        }

        let dogName: String? = userInfo[KeyConstant.dogName.rawValue] as? String
        let dogUUID: UUID? = UUID.fromString(forUUIDString: userInfo[KeyConstant.dogUUID.rawValue] as? String)
        let reminder: Reminder? = userInfo[KeyConstant.reminder.rawValue] as? Reminder

        guard let dogName = dogName, let dogUUID = dogUUID, let reminder = reminder else {
            return
        }

        AlarmManager.willShowAlarm(forDogName: dogName, forDogUUID: dogUUID, forReminder: reminder)
    }

    /// Used as a selector when constructing timer in initializeReminderTimers. It triggers when the current date passes the original reminderExecutionDate that was skipped, indicating the reminder should go back into regular, non-skipping mode. If assigning new timer, invalidates the current timer then assigns reminderDisableIsSkippingTimer to new timer.
    @objc private static func didExecuteReminderDisableIsSkippingTimer(sender: Timer) {
        guard let userInfo = sender.userInfo as? [String: Any] else {
            return
        }

        let forDogUUID: UUID? = UUID.fromString(forUUIDString: userInfo[KeyConstant.dogUUID.rawValue] as? String)
        let forReminder: Reminder? = userInfo[KeyConstant.reminder.rawValue] as? Reminder

        guard let forDogUUID = forDogUUID, let forReminder = forReminder else {
            return
        }

        RemindersRequest.get(invokeErrorManager: false, forDogUUID: forDogUUID, forReminder: forReminder) { reminder, responseStatusReminderGet, _ in
            guard responseStatusReminderGet != .failureResponse else {
                return
            }
            
            guard let reminder = reminder else {
                // If the response was successful but no reminder was returned, that means the reminder was deleted. Therefore, update the dogManager to indicate as such.
                    forReminder.clearTimers()
                self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forReminderUUID: forReminder.reminderUUID)
                return
            }

            reminder.resetForNextAlarm()

            RemindersRequest.update(invokeErrorManager: false, forDogUUID: forDogUUID, forReminders: [reminder]) { responseStatusReminderUpdate, _ in
                guard responseStatusReminderUpdate != .failureResponse else {
                    return
                }

                delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: forDogUUID, forReminder: reminder)
            }
        }
    }

}
