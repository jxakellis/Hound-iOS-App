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
        for dogReminder in dogReminders {
            if let reminderCopy = dogReminder.copy() as? Reminder {
                copy.dogReminders.append(reminderCopy)            }
        }
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        dogReminders = aDecoder.decodeOptionalObject(forKey: Constant.Key.dogReminders.rawValue) ?? dogReminders
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogReminders, forKey: Constant.Key.dogReminders.rawValue)
    }
    
    // MARK: - Properties
    
    /// Array of dogReminders
    private(set) var dogReminders: [Reminder] = []
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    init(reminders: [Reminder] = []) {
        super.init()
        addReminders(reminders: reminders)
    }
    
    /// Provide an array of dictionary literal of reminder properties to instantiate dogReminders. Provide a reminderManager to have the dogReminders add themselves into, update themselves in, or delete themselves from.
    convenience init(fromReminderBodies: [JSONResponseBody], dogReminderManagerToOverride: DogReminderManager?) {
        self.init(reminders: dogReminderManagerToOverride?.dogReminders ?? [])
        
        for fromBody in fromReminderBodies {
            // Don't pull properties from reminderToOverride. A valid fromBody needs to provide this itself
            let reminderId = fromBody[Constant.Key.reminderId.rawValue] as? Int
            let reminderUUID = UUID.fromString(UUIDString: fromBody[Constant.Key.reminderUUID.rawValue] as? String)
            let reminderIsDeleted = fromBody[Constant.Key.reminderIsDeleted.rawValue] as? Bool
            
            guard reminderId != nil, let reminderUUID = reminderUUID, let reminderIsDeleted = reminderIsDeleted else {
                // couldn't construct essential components to intrepret reminder
                continue
            }
            
            guard reminderIsDeleted == false else {
                removeReminder(reminderUUID: reminderUUID)
                continue
            }
            
            if let reminder = Reminder(fromBody: fromBody, reminderToOverride: findReminder(reminderUUID: reminderUUID)) {
                addReminder(reminder: reminder)
            }
        }
    }
    
    // MARK: - Functions
    
    /// finds and returns the reference of a reminder matching the given reminderUUID
    func findReminder(reminderUUID: UUID) -> Reminder? {
        dogReminders.first(where: { $0.reminderUUID == reminderUUID })
    }
    
    /// Helper function allows us to use the same logic for addReminder and addReminders and allows us to only sort at the end. Without this function, addReminders would invoke addReminder repeadly and sortReminders() with each call.
    private func addReminderWithoutSorting(reminder: Reminder) {
        dogReminders.removeAll { r in
            return r.reminderUUID == reminder.reminderUUID
        }
        
        dogReminders.append(reminder)
    }
    
    /// If a reminder with the same UUID is already present, removes it. Then adds the new dogReminders
    func addReminder(reminder: Reminder) {
        
        addReminderWithoutSorting(reminder: reminder)
        
        dogReminders.sort(by: { $0 <= $1 })
    }
    
    /// Invokes addReminder(reminder: Reminder) for newReminder.count times (but only sorts once at the end to be more efficent)
    func addReminders(reminders: [Reminder]) {
        for reminder in reminders {
            addReminderWithoutSorting(reminder: reminder)
        }
        
        dogReminders.sort(by: { $0 <= $1 })
    }
    
    /// Returns true if it removed at least one reminder with the same reminderUUID
    @discardableResult func removeReminder(reminderUUID: UUID) -> Bool {
        var didRemoveObject = false
        
        dogReminders.removeAll { r in
            guard r.reminderUUID == reminderUUID else {
                return false
            }
            
            didRemoveObject = true
            return true
        }
        
        return didRemoveObject
    }
}
