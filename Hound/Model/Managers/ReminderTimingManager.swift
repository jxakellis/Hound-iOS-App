//
//  Timing.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol ReminderTimingManagerDelegate: AnyObject {
    func didAddReminder(sender: Sender, dogUUID: UUID, reminder: Reminder)
    func didRemoveReminder(sender: Sender, dogUUID: UUID, reminderUUID: UUID)
}

final class ReminderTimingManager {
    
    enum ReminderTimerTypes {
        /// Represents a Timer that is used for managing a reminder's alarms (which trigger an alert / alarm for when the reminder is scheduled)
        case alarmTimer
        /// Represents a Timer that is used to change a reminder from isSkipping true to false. This triggers when the current date passes the original reminderExecutionDate that was skipped, indicating the reminder should go back into regular, non-skipping mode.
        case disableIsSkippingTimer
    }
    
    class ReminderTimer {
        var timer: Timer
        var type: ReminderTimerTypes
        var dogName: String
        var dogUUID: UUID
        var reminder: Reminder
        
        init(timer: Timer, type: ReminderTimerTypes, dogName: String, dogUUID: UUID, reminder: Reminder) {
            self.timer = timer
            self.type = type
            self.dogName = dogName
            self.dogUUID = dogUUID
            self.reminder = reminder
        }
    }

    // MARK: - Properties

    static weak var delegate: ReminderTimingManagerDelegate!
    
    private static var reminderTimers: [ReminderTimer] = []

    // MARK: - Main

    /// Initializes all reminder timers
    static func initializeReminderTimers(dogManager: DogManager) {
        removeTimersForDeletedReminders(dogManager: dogManager)
        
        for dog in dogManager.dogs {
            for reminder in dog.dogReminders.dogReminders {
                // if the reminder has a execution date, then create its timers
                guard reminder.reminderIsEnabled == true, let reminderExecutionDate = reminder.reminderExecutionDate else {
                    // The reminder is disabled and can't have any timers
                    removeTimer(reminderUUID: reminder.reminderUUID, type: .alarmTimer)
                    removeTimer(reminderUUID: reminder.reminderUUID, type: .disableIsSkippingTimer)
                    continue
                }
                
                // If the reminder doesn't have a reminderAlarmTimer or the reminderAlarmTimer hasn't fired yet, assign the reminder a new reminderAlarmTimer.
                // If reminderAlarmTimer isn't nil and it has already fired, don't overwrite it. It probably is waiting for a user to response to the HoundAlarmAlertController.
                let reminderAlarmTimer = findTimer(reminderUUID: reminder.reminderUUID, type: .alarmTimer)
                if reminderAlarmTimer == nil || reminderAlarmTimer?.timer.fireDate ?? Date(timeIntervalSince1970: 0.0) > Date() {
                    // Remove the existing timer now that we want to replace it
                    removeTimer(reminderUUID: reminder.reminderUUID, type: .alarmTimer)
                    
                    let reminderAlarmTimer = Timer(
                                      fireAt: reminderExecutionDate,
                                      interval: -1,
                                      target: self,
                                      selector: #selector(self.didExecuteReminderAlarmTimer(sender:)),
                                      userInfo: nil,
                                      repeats: false)
                    reminderTimers.append(
                        ReminderTimer(timer: reminderAlarmTimer,
                                      type: .alarmTimer,
                                      dogName: dog.dogName,
                                      dogUUID: dog.dogUUID,
                                      reminder: reminder)
                    )
                    RunLoop.main.add(reminderAlarmTimer, forMode: .common)
                }

                // Sets a timer that executes when the timer should go from isSkipping true -> false.
                // If the reminder doesn't have a reminderDisableIsSkippingTimer or the reminderDisableIsSkippingTimer hasn't fired yet, assign the reminder a new reminderDisableIsSkippingTimer.
                // If reminderDisableIsSkippingTimer isn't nil and it has already fired, don't overwrite it.
                let reminderDisableIsSkippingTimer = findTimer(reminderUUID: reminder.reminderUUID, type: .disableIsSkippingTimer)
                if reminderDisableIsSkippingTimer == nil
                    || reminderDisableIsSkippingTimer?.timer.fireDate ?? Date(timeIntervalSince1970: 0.0) > Date(), let disableIsSkippingDate = reminder.disableIsSkippingDate {
                    // Remove the existing timer now that we want to replace it
                    removeTimer(reminderUUID: reminder.reminderUUID, type: .disableIsSkippingTimer)
                    
                    let reminderDisableIsSkippingTimer = Timer(fireAt: disableIsSkippingDate,
                                                   interval: -1,
                                                   target: self,
                                                   selector: #selector(didExecuteReminderDisableIsSkippingTimer(sender:)),
                                                   userInfo: nil,
                                                   repeats: false)
                    reminderTimers.append(
                        ReminderTimer(timer: reminderDisableIsSkippingTimer,
                                      type: .disableIsSkippingTimer,
                                      dogName: dog.dogName,
                                      dogUUID: dog.dogUUID,
                                      reminder: reminder)
                    )
                    RunLoop.main.add(reminderDisableIsSkippingTimer, forMode: .common)
                }
            }
        }
    }
    
    // MARK: - Functions
    
    /// For a given reminderUUID, find the first occurance in reminderAlarmTimers of a ReminderTimer with the same reminderUUID.
    private static func findTimer(reminderUUID: UUID, type: ReminderTimerTypes) -> ReminderTimer? {
        return reminderTimers.first { reminderTimer in
            guard reminderTimer.type == type else {
                return false
            }
            
            return reminderTimer.reminder.reminderUUID == reminderUUID
        }
    }
    
    /// Removes all reminderTimers with the same reminderUUID from reminderAlarmTimers, invalidating their timers in the process
    private static func removeTimer(reminderUUID: UUID, type: ReminderTimerTypes) {
        reminderTimers.removeAll { rt in
            guard rt.type == type else {
                return false
            }
            
            guard rt.reminder.reminderUUID == reminderUUID else {
                return false
            }
            
            rt.timer.invalidate()
            return true
        }
    }
    
    private static func removeTimersForDeletedReminders(dogManager: DogManager) {
        reminderTimers.forEach { reminderTimer in
            let dogUUID = reminderTimer.dogUUID
            let reminderUUID = reminderTimer.reminder.reminderUUID
            
            // If the dog or reminder no longer exists, then we have a timer for nothing. Therefore, we should remove it
            if dogManager.findDog(dogUUID: dogUUID)?.dogReminders.findReminder(reminderUUID: reminderUUID) == nil {
                removeTimer(reminderUUID: reminderUUID, type: .alarmTimer)
                removeTimer(reminderUUID: reminderUUID, type: .disableIsSkippingTimer)
            }
        }
    }
    
    /// When a reminderAlarmTimer executes, it invokes ReminderAlarmManager.willCreateAndShowReminderAlarm. This timer stays in the array of timers until the user responds to the alert, otherwise ReminderTimingManager would create more timers which would create more alerts for the user to click through. Therefore, we only remove the timer once the user has responded to the alert.
    static func didCompleteForReminderTimer(reminderUUID: UUID, type: ReminderTimerTypes) {
        removeTimer(reminderUUID: reminderUUID, type: type)
    }

    // MARK: - Timer Actions

    /// Used as a selector when constructing timer in initializeReminderTimers. Invoke ReminderAlarmManager to show alart controller for reminder alarm
    @objc private static func didExecuteReminderAlarmTimer(sender: Timer) {
        guard let reminderTimer = reminderTimers.first(where: { reminderTimer in
            return reminderTimer.timer == sender
        }) else { return }
        
        ReminderAlarmManager.willCreateAndShowReminderAlarm(dogName: reminderTimer.dogName, dogUUID: reminderTimer.dogUUID, reminder: reminderTimer.reminder)
    }

    /// Used as a selector when constructing timer in initializeReminderTimers. It triggers when the current date passes the original reminderExecutionDate that was skipped, indicating the reminder should go back into regular, non-skipping mode. If assigning new timer, invalidates the current timer then assigns reminderDisableIsSkippingTimer to new timer.
    @objc private static func didExecuteReminderDisableIsSkippingTimer(sender: Timer) {
        guard let reminderTimer = reminderTimers.first(where: { reminderTimer in
            return reminderTimer.timer == sender
        }) else { return }
        
        RemindersRequest.get(errorAlert: .automaticallyAlertForNone, dogUUID: reminderTimer.dogUUID, reminder: reminderTimer.reminder) { reminder, responseStatusReminderGet, _ in
            guard responseStatusReminderGet != .failureResponse else {
                return
            }
            
            guard let reminder = reminder else {
                // If the response was successful but no reminder was returned, that means the reminder was deleted. Therefore, update the dogManager to indicate as such.
                self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), dogUUID: reminderTimer.dogUUID, reminderUUID: reminderTimer.reminder.reminderUUID)
                return
            }

            reminder.resetForNextAlarm()
            didCompleteForReminderTimer(reminderUUID: reminder.reminderUUID, type: .disableIsSkippingTimer)

            RemindersRequest.update(errorAlert: .automaticallyAlertForNone, dogUUID: reminderTimer.dogUUID, reminders: [reminder]) { responseStatusReminderUpdate, _ in
                guard responseStatusReminderUpdate != .failureResponse else {
                    return
                }

                delegate.didAddReminder(sender: Sender(origin: self, localized: self), dogUUID: reminderTimer.dogUUID, reminder: reminder)
            }
        }
    }
}
