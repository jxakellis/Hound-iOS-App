//
//  Reminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class ReminderManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ReminderManager()
        for reminder in reminders {
            if let reminderCopy = reminder.copy() as? Reminder {
                copy.reminders.append(reminderCopy)            }
        }
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        reminders = aDecoder.decodeObject(forKey: KeyConstant.reminders.rawValue) as? [Reminder] ?? reminders
        // If multiple reminders have the same placeholder id (e.g. migrating from Hound 1.3.5 to 2.0.0), shift the dogIds so they all have a unique placeholder id
        var lowestPlaceholderId: Int = Int.max
        for reminder in reminders where reminder.reminderId <= -1 && reminder.reminderId >= lowestPlaceholderId {
            // the currently iterated over reminder has a placeholder id that overlaps with another placeholder id
            reminder.reminderId = lowestPlaceholderId - 1
            lowestPlaceholderId = reminder.reminderId
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(reminders, forKey: KeyConstant.reminders.rawValue)
    }
    
    // MARK: - Main
    
    init(forReminders: [Reminder] = []) {
        super.init()
        addReminders(forReminders: forReminders)
    }
    
    /// Provide an array of dictionary literal of reminder properties to instantiate reminders. Provide a reminderManager to have the reminders add themselves into, update themselves in, or delete themselves from.
    convenience init(fromReminderBodies reminderBodies: [[String: Any]], overrideReminderManager: ReminderManager?) {
        self.init(forReminders: overrideReminderManager?.reminders ?? [])
        
        for reminderBody in reminderBodies {
            // Don't pull reminderId or reminderIsDeleted from overrideReminder. A valid reminderBody needs to provide this itself
            let reminderId = reminderBody[KeyConstant.reminderId.rawValue] as? Int
            let reminderIsDeleted = reminderBody[KeyConstant.reminderIsDeleted.rawValue] as? Bool
            
            guard let reminderId = reminderId, let reminderIsDeleted = reminderIsDeleted else {
                // couldn't construct essential components to intrepret reminder
                continue
            }
            
            guard reminderIsDeleted == false else {
                removeReminder(forReminderId: reminderId)
                continue
            }
            
            if let reminder = Reminder(forReminderBody: reminderBody, overrideReminder: findReminder(forReminderId: reminderId)) {
                addReminder(forReminder: reminder)
            }
        }
    }
    
    // MARK: Properties
    
    /// Array of reminders
    private(set) var reminders: [Reminder] = []
    
    // MARK: Functions
    
    /// finds and returns the reference of a reminder matching the given reminderId
    func findReminder(forReminderId reminderId: Int) -> Reminder? {
        return reminders.first(where: { $0.reminderId == reminderId })
    }
    
    /// Helper function allows us to use the same logic for addReminder and addReminders and allows us to only sort at the end. Without this function, addReminders would invoke addReminder repeadly and sortReminders() with each call.
    private func addReminderWithoutSorting(forReminder newReminder: Reminder, shouldOverrideReminderWithSamePlaceholderId: Bool) {
        
        // removes any existing reminders that have the same reminderId as they would cause problems.
        reminders.removeAll { oldReminder in
            guard oldReminder.reminderId == newReminder.reminderId else {
                return false
            }
            
            guard (shouldOverrideReminderWithSamePlaceholderId == true) ||
                    (shouldOverrideReminderWithSamePlaceholderId == false && oldReminder.reminderId >= 0) else {
                return false
            }
            
            // if oldReminder's timers don't reference newReminder's timers, then oldReminder's timer is invalidated and removed.
            oldReminder.reminderAlarmTimer = newReminder.reminderAlarmTimer
            oldReminder.reminderDisableIsSkippingTimer = newReminder.reminderDisableIsSkippingTimer
            
            return true
        }
        
        // check to see if we are dealing with a placeholder id reminder
        if newReminder.reminderId < 0 {
            // If there are multiple reminders with placeholder ids, set the new reminder's placeholder id to the lowest possible, therefore no overlap.
            var lowestReminderId = Int.max
            reminders.forEach { reminder in
                if reminder.reminderId < lowestReminderId {
                    lowestReminderId = reminder.reminderId
                }
            }
            
            // the lowest reminder is is <0 so there are other placeholder reminders, that means we should set our new reminder to a placeholder id that is 1 below the lowest (making this reminder the new lowest)
            if lowestReminderId < 0 {
                newReminder.reminderId = lowestReminderId - 1
            }
        }
        
        reminders.append(newReminder)
    }
    
    /// Checks to see if a reminder is already present. If its reminderId is, then is removes the old one and replaces it with the new. However, if the reminders have placeholderIds and shouldOverrideReminderWithSamePlaceholderId is false, then the newReminder's placeholderId is shifted to a different placeholderId and both reminders are retained.
    func addReminder(forReminder reminder: Reminder, shouldOverrideReminderWithSamePlaceholderId: Bool = false) {
        
        addReminderWithoutSorting(forReminder: reminder, shouldOverrideReminderWithSamePlaceholderId: shouldOverrideReminderWithSamePlaceholderId)
        
        sortReminders()
    }
    
    /// Invokes addReminder(forReminder: Reminder) for newReminder.count times (but only sorts once at the end to be more efficent)
    func addReminders(forReminders reminders: [Reminder]) {
        for reminder in reminders {
            addReminderWithoutSorting(forReminder: reminder, shouldOverrideReminderWithSamePlaceholderId: false)
        }
        
        sortReminders()
    }
    
    private func sortReminders() {
        // Returns true if reminderId1 should come before reminderId2, taking into account placeholderIds.
        func compareReminderIds(reminderId1: Int, reminderId2: Int) -> Bool {
            
            // both real id from the server, make the one that is lower (aka older) come first
            if reminderId1 > 0 && reminderId2 > 0 {
                return reminderId1 < reminderId2
            }
            // both placeholder ids until there is server contact to create the reminders
            else if reminderId1 < 0 && reminderId2 < 0 {
                // the placeholder that is close to 0 / is a larger value (the older one) should come first
                return reminderId1 > reminderId2
            }
            // one of them is a placeholder id
            else {
                // if reminderId1 is >0 then it is the real id and should come first, otherwise reminderId2 is the real id and should come first
                return reminderId1 > 0
            }
        }
        reminders.sort { (reminder1, reminder2) -> Bool in
            // both countdown
            if reminder1.reminderType == .countdown && reminder2.reminderType == .countdown {
                let reminder1ExecutionInterval = reminder1.countdownComponents.executionInterval
                let reminder2ExecutionInterval = reminder2.countdownComponents.executionInterval
                
                guard reminder1ExecutionInterval != reminder2ExecutionInterval else {
                    // if equal, then smaller reminderId comes first
                    return compareReminderIds(reminderId1: reminder1.reminderId, reminderId2: reminder2.reminderId)
                }
                // shorter executionInterval comes first
                return reminder1ExecutionInterval < reminder2ExecutionInterval
            }
            // both weekly
            else if reminder1.reminderType == .weekly && reminder2.reminderType == .weekly {
                // earlier in the day is listed first
                let reminder1Hour = reminder1.weeklyComponents.localHour
                let reminder2Hour = reminder2.weeklyComponents.localHour
                
                guard reminder1Hour != reminder2Hour else {
                    // hours are equal
                    let reminder1Minute = reminder1.weeklyComponents.localMinute
                    let reminder2Minute = reminder2.weeklyComponents.localMinute
                    
                    guard reminder1Minute != reminder2Minute else {
                        // if equal, then smaller reminderId comes first
                        return compareReminderIds(reminderId1: reminder1.reminderId, reminderId2: reminder2.reminderId)
                    }
                    
                    // smaller minute comes first
                    return reminder1Minute < reminder2Minute
                }
                
                // smaller hour comes first
                return reminder1Hour < reminder2Hour
            }
            // both monthly
            else if reminder1.reminderType == .monthly && reminder2.reminderType == .monthly {
                let reminder1Day = reminder1.monthlyComponents.UTCDay
                let reminder2Day = reminder2.monthlyComponents.UTCDay
                
                guard reminder1Day != reminder2Day else {
                    // earliest in day comes first if same days
                    let reminder1Hour = reminder1.monthlyComponents.localHour
                    let reminder2Hour = reminder2.monthlyComponents.localHour
                    
                    guard reminder1Hour != reminder2Hour else {
                        // earliest in hour comes first if same hour
                        let reminder1Minute = reminder1.monthlyComponents.localMinute
                        let reminder2Minute = reminder2.monthlyComponents.localMinute
                        
                        guard reminder1Minute != reminder2Minute else {
                            // smaller remidnerId comes first
                            return compareReminderIds(reminderId1: reminder1.reminderId, reminderId2: reminder2.reminderId)
                        }
                        // smaller minute comes first
                        return reminder1Minute < reminder2Minute
                    }
                    
                    // smaller hour comes first
                    return reminder1Hour < reminder2Hour
                }
                // smaller day comes first
                return reminder1Day < reminder2Day
            }
            else if reminder1.reminderType == .oneTime && reminder2.reminderType == .oneTime {
                let reminder1DistanceToPast = Date().distance(to: reminder1.oneTimeComponents.oneTimeDate)
                let reminder2DistanceToPast = Date().distance(to: reminder2.oneTimeComponents.oneTimeDate)
                
                guard reminder1DistanceToPast != reminder2DistanceToPast else {
                    // if equal, then smaller reminderId comes first
                    return compareReminderIds(reminderId1: reminder1.reminderId, reminderId2: reminder2.reminderId)
                }
                // not equal, the oldest one comes first
                return reminder1DistanceToPast < reminder2DistanceToPast
            }
            // different timing styles
            else {
                // reminder1 and reminder2 are known to be different styles
                switch reminder1.reminderType {
                case .countdown:
                    // reminder2 can't be .countdown and .countdown always comes first, so reminder1 comes first
                    return true
                case .weekly:
                    // reminder2 can't be weekly. Therefore, the only way it can come before is if its .countdown
                    return (reminder2.reminderType == .countdown) ? false : true
                case .monthly:
                    // reminder2 can't be weekly. Therefore, the only way it can come before is if its .countdown or .weekly
                    return (reminder2.reminderType == .countdown || reminder2.reminderType == .weekly) ? false : true
                case .oneTime:
                    // reminder2 can't be oneTime. Therefore, it will come before as it has to be one of the other types
                    return false
                }
                
            }
        }
    }
    
    /// Tries to find a reminder with the matching reminderId, if found then it removes the reminder, if not found then throws error
    func removeReminder(forReminderId reminderId: Int) {
        // finds index of given reminder (through reminder name), returns nil if not found
        
        let removedReminderIndex: Int? = reminders.firstIndex { reminder in
            return reminder.reminderId == reminderId
            
        }
        
        guard let removedReminderIndex = removedReminderIndex else {
            return
        }
        
        // don't clearTimers() for reminder. we can't be sure what is invoking this function and we don't want to accidentily invalidate the timers. Therefore, leave the timers in place. If the timers are left over and after the reminder is deleted, then they will fail the server query willShowAlarm and be disregarded. If the timers are still valid, then all continues as normal
        
        reminders.remove(at: removedReminderIndex)
    }
}
