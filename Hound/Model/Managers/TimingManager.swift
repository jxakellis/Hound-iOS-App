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
        
        init(forTimer: Timer, forType: ReminderTimerTypes, forDogName: String, forDogUUID: UUID, forReminder: Reminder) {
            self.timer = forTimer
            self.type = forType
            self.dogName = forDogName
            self.dogUUID = forDogUUID
            self.reminder = forReminder
        }
    }

    // MARK: - Properties

    static weak var delegate: TimingManagerDelegate!
    
    private static var reminderTimers: [ReminderTimer] = []

    // MARK: - Main

    /// Initializes all reminder timers
    static func initializeReminderTimers(forDogManager dogManager: DogManager) {
        for dog in dogManager.dogs {
            for reminder in dog.dogReminders.reminders {
                // if the reminder has a execution date, then create its timers
                guard reminder.reminderIsEnabled == true, let reminderExecutionDate = reminder.reminderExecutionDate else {
                    // The reminder is disabled and can't have any timers
                    continue
                }
                
                
                // If the reminder doesn't have a reminderAlarmTimer or the reminderAlarmTimer hasn't fired yet, assign the reminder a new reminderAlarmTimer.
                // If reminderAlarmTimer isn't nil and it has already fired, don't overwrite it. It probably is waiting for a user to response to the AlarmUIAlertController.
                let reminderAlarmTimer = findReminderTimer(forReminderUUID: reminder.reminderUUID, forType: .alarmTimer)
                if reminderAlarmTimer == nil || reminderAlarmTimer?.timer.fireDate ?? Date(timeIntervalSince1970: 0.0) > Date() {
                    // Remove the existing timer now that we want to replace it
                    removeReminderAlarmTimer(forReminderUUID: reminder.reminderUUID, forType: .alarmTimer)
                    
                    let reminderAlarmTimer = Timer(
                                      fireAt: reminderExecutionDate,
                                      interval: -1,
                                      target: self,
                                      selector: #selector(self.didExecuteReminderAlarmTimer(sender:)),
                                      userInfo: nil,
                                      repeats: false)
                    reminderTimers.append(
                        ReminderTimer(forTimer: reminderAlarmTimer,
                                      forType: .alarmTimer,
                                      forDogName: dog.dogName,
                                      forDogUUID: dog.dogUUID,
                                      forReminder: reminder)
                    )
                    RunLoop.main.add(reminderAlarmTimer, forMode: .common)
                }

                // Sets a timer that executes when the timer should go from isSkipping true -> false.
                // If the reminder doesn't have a reminderDisableIsSkippingTimer or the reminderDisableIsSkippingTimer hasn't fired yet, assign the reminder a new reminderDisableIsSkippingTimer.
                // If reminderDisableIsSkippingTimer isn't nil and it has already fired, don't overwrite it.
                let reminderDisableIsSkippingTimer = findReminderTimer(forReminderUUID: reminder.reminderUUID, forType: .disableIsSkippingTimer)
                if reminderDisableIsSkippingTimer == nil
                    || reminderDisableIsSkippingTimer?.timer.fireDate ?? Date(timeIntervalSince1970: 0.0) > Date(), let disableIsSkippingDate = reminder.disableIsSkippingDate {
                    // Remove the existing timer now that we want to replace it
                    removeReminderAlarmTimer(forReminderUUID: reminder.reminderUUID, forType: .disableIsSkippingTimer)
                    
                    let reminderDisableIsSkippingTimer = Timer(fireAt: disableIsSkippingDate,
                                                   interval: -1,
                                                   target: self,
                                                   selector: #selector(didExecuteReminderDisableIsSkippingTimer(sender:)),
                                                   userInfo: nil,
                                                   repeats: false)
                    reminderTimers.append(
                        ReminderTimer(forTimer: reminderDisableIsSkippingTimer,
                                      forType: .disableIsSkippingTimer,
                                      forDogName: dog.dogName,
                                      forDogUUID: dog.dogUUID,
                                      forReminder: reminder)
                    )
                    RunLoop.main.add(reminderDisableIsSkippingTimer, forMode: .common)
                }
            }
        }
    }
    
    // MARK: - Functions
    
    /// For a given forReminderUUID, find the first occurance in reminderAlarmTimers of a ReminderTimer with the same reminderUUID.
    private static func findReminderTimer(forReminderUUID: UUID, forType: ReminderTimerTypes) -> ReminderTimer? {
        return reminderTimers.first { reminderTimer in
            guard reminderTimer.type == forType else {
                return false
            }
            
            return reminderTimer.reminder.reminderUUID == forReminderUUID
        }
    }
    
    /// Removes all reminderTimers with the same forReminderUUID from reminderAlarmTimers, invalidating their timers in the process
    private static func removeReminderAlarmTimer(forReminderUUID: UUID, forType: ReminderTimerTypes) {
        reminderTimers.removeAll { reminderTimer in
            guard reminderTimer.type == forType else {
                return false
            }
            
            guard reminderTimer.reminder.reminderUUID == forReminderUUID else {
                return false
            }
            
            reminderTimer.timer.invalidate()
            return true
        }
    }
    
    /// When a reminderAlarmTimer executes, it invokes AlarmManager.willCreateAndShowAlarm. This timer stays in the array of timers until the user responds to the alert, otherwise TimingManager would create more timers which would create more alerts for the user to click through. Therefore, we only remove the timer once the user has responded to the alert.
    static func didCompleteForTimer(forReminderUUID: UUID, forType: ReminderTimerTypes) {
        removeReminderAlarmTimer(forReminderUUID: forReminderUUID, forType: forType)
    }

    // MARK: - Timer Actions

    /// Used as a selector when constructing timer in initializeReminderTimers. Invoke AlarmManager to show alart controller for reminder alarm
    @objc private static func didExecuteReminderAlarmTimer(sender: Timer) {
        guard let reminderTimer = reminderTimers.first(where: { reminderTimer in
            return reminderTimer.timer == sender
        }) else {
            return
        }
        
        AlarmManager.willCreateAndShowAlarm(forDogName: reminderTimer.dogName, forDogUUID: reminderTimer.dogUUID, forReminder: reminderTimer.reminder)
    }

    /// Used as a selector when constructing timer in initializeReminderTimers. It triggers when the current date passes the original reminderExecutionDate that was skipped, indicating the reminder should go back into regular, non-skipping mode. If assigning new timer, invalidates the current timer then assigns reminderDisableIsSkippingTimer to new timer.
    @objc private static func didExecuteReminderDisableIsSkippingTimer(sender: Timer) {
        guard let reminderTimer = reminderTimers.first(where: { reminderTimer in
            return reminderTimer.timer == sender
        }) else {
            return
        }
        
        RemindersRequest.get(forErrorAlert: .automaticallyAlertForNone, forDogUUID: reminderTimer.dogUUID, forReminder: reminderTimer.reminder) { reminder, responseStatusReminderGet, _ in
            guard responseStatusReminderGet != .failureResponse else {
                return
            }
            
            guard let reminder = reminder else {
                // If the response was successful but no reminder was returned, that means the reminder was deleted. Therefore, update the dogManager to indicate as such.
                self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogUUID: reminderTimer.dogUUID, forReminderUUID: reminderTimer.reminder.reminderUUID)
                return
            }

            reminder.resetForNextAlarm()
            didCompleteForTimer(forReminderUUID: reminder.reminderUUID, forType: .disableIsSkippingTimer)

            RemindersRequest.update(forErrorAlert: .automaticallyAlertForNone, forDogUUID: reminderTimer.dogUUID, forReminders: [reminder]) { responseStatusReminderUpdate, _ in
                guard responseStatusReminderUpdate != .failureResponse else {
                    return
                }

                delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: reminderTimer.dogUUID, forReminder: reminder)
            }
        }
    }
}
