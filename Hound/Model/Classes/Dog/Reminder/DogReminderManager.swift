//
//  Reminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogReminderManager: NSObject, NSCoding, NSCopying {

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogReminderManager()
        for reminder in reminders {
            if let reminderCopy = reminder.copy() as? Reminder {
                copy.reminders.append(reminderCopy)            }
        }
        return copy
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        reminders = aDecoder.decodeObject(forKey: KeyConstant.reminders.rawValue) as? [Reminder] ?? reminders
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeInteger, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        aCoder.encode(reminders, forKey: KeyConstant.reminders.rawValue)
    }

    // MARK: - Properties

    /// Array of reminders
    private(set) var reminders: [Reminder] = []

    // MARK: - Main

    override init() {
        super.init()
    }

    init(forReminders: [Reminder] = []) {
        super.init()
        addReminders(forReminders: forReminders)
    }

    /// Provide an array of dictionary literal of reminder properties to instantiate reminders. Provide a reminderManager to have the reminders add themselves into, update themselves in, or delete themselves from.
    convenience init(fromReminderBodies: [[String: Any?]], dogReminderManagerToOverride: DogReminderManager?) {
        self.init(forReminders: dogReminderManagerToOverride?.reminders ?? [])

        for fromReminderBody in fromReminderBodies {
            // Don't pull properties from reminderToOverride. A valid fromReminderBody needs to provide this itself
            let reminderId = fromReminderBody[KeyConstant.reminderId.rawValue] as? Int
            let reminderUUID = UUID.fromString(forUUIDString: fromReminderBody[KeyConstant.reminderUUID.rawValue] as? String)
            let reminderIsDeleted = fromReminderBody[KeyConstant.reminderIsDeleted.rawValue] as? Bool

            guard reminderId != nil, let reminderUUID = reminderUUID, let reminderIsDeleted = reminderIsDeleted else {
                // couldn't construct essential components to intrepret reminder
                continue
            }

            guard reminderIsDeleted == false else {
                removeReminder(forReminderUUID: reminderUUID)
                continue
            }

            if let reminder = Reminder(fromReminderBody: fromReminderBody, reminderToOverride: findReminder(forReminderUUID: reminderUUID)) {
                addReminder(forReminder: reminder)
            }
        }
    }

    // MARK: - Functions
    
    /// finds and returns the reference of a reminder matching the given forReminderUUID
    func findReminder(forReminderUUID: UUID) -> Reminder? {
        reminders.first(where: { $0.reminderUUID == forReminderUUID })
    }

    /// Helper function allows us to use the same logic for addReminder and addReminders and allows us to only sort at the end. Without this function, addReminders would invoke addReminder repeadly and sortReminders() with each call.
    private func addReminderWithoutSorting(forReminder: Reminder) {

        // Remove any copies of the same reminders. Use UUID as id could be nil because reminder isn't created yet
        reminders.removeAll { reminder in
            guard reminder.reminderUUID == forReminder.reminderUUID else {
                return false
            }

            // if oldReminder's timers don't reference newReminder's timers, then oldReminder's timer is invalidated and removed.
            reminder.reminderAlarmTimer = forReminder.reminderAlarmTimer
            reminder.reminderDisableIsSkippingTimer = forReminder.reminderDisableIsSkippingTimer

            return true
        }

        reminders.append(forReminder)
    }

    /// If a reminder with the same UUID is already present, removes it. Then adds the new reminders
    func addReminder(forReminder: Reminder) {

        addReminderWithoutSorting(forReminder: forReminder)

        reminders.sort(by: { $0 <= $1 })
    }

    /// Invokes addReminder(forReminder: Reminder) for newReminder.count times (but only sorts once at the end to be more efficent)
    func addReminders(forReminders: [Reminder]) {
        for forReminder in forReminders {
            addReminderWithoutSorting(forReminder: forReminder)
        }

        reminders.sort(by: { $0 <= $1 })
    }

    /// Returns true if it removed at least one reminder with the same reminderUUID
    @discardableResult func removeReminder(forReminderUUID: UUID) -> Bool {
        var didRemoveObject = false
        
        reminders.removeAll { reminder in
            guard reminder.reminderUUID == forReminderUUID else {
                return false
            }
            
            // TODO TEST if this breaks logic within Hound. Normally, when a server request deletes a reminder, we clear the reminder there. However, that code is less clean. This would be a more appropiate spot.
            
            // ORIGINAL NOTE BEFORE WE CHANGED THIS CODE: don't clearTimers() for reminder. we can't be sure what is invoking this function and we don't want to accidentily invalidate the timers. Therefore, leave the timers in place. If the timers are left over and after the reminder is deleted, then they will fail the server query willShowAlarm and be disregarded. If the timers are still valid, then all continues as normal
            reminder.clearTimers()
            didRemoveObject = true
            return true
        }
        
        return didRemoveObject
    }
}
