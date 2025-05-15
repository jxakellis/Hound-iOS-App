//
//  DogReminderTriggerManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogReminderTriggerManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogReminderTriggerManager()
        for trigger in reminderTriggers {
            if let triggerCopy = trigger.copy() as? ReminderTrigger {
                copy.reminderTriggers.append(triggerCopy)
            }
        }
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        reminderTriggers = aDecoder
            .decodeObject(forKey: KeyConstant.reminderTriggers.rawValue)
        as? [ReminderTrigger] ?? reminderTriggers
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(reminderTriggers,
                      forKey: KeyConstant.reminderTriggers.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var reminderTriggers: [ReminderTrigger] = []
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    init(forReminderTriggers: [ReminderTrigger] = []) {
        super.init()
        addReminderTriggers(forReminderTriggers: forReminderTriggers)
    }
    
    convenience init(
        fromReminderTriggerBodies: [[String: Any?]],
        dogReminderTriggerManagerToOverride: DogReminderTriggerManager?
    ) {
        self.init(forReminderTriggers:
                    dogReminderTriggerManagerToOverride?.reminderTriggers ?? []
        )
        
        for fromBody in fromReminderTriggerBodies {
            let reminderTriggerId = fromBody[KeyConstant.reminderTriggerId.rawValue] as? Int
            let reminderTriggerUUID = UUID.fromString(
                forUUIDString: fromBody[KeyConstant.reminderTriggerUUID.rawValue] as? String
            )
            let reminderTriggerIsDeleted = fromBody[KeyConstant.reminderTriggerIsDeleted.rawValue] as? Bool
            
            guard reminderTriggerId != nil,
                  let reminderTriggerUUID = reminderTriggerUUID,
                  let reminderTriggerIsDeleted = reminderTriggerIsDeleted
            else {
                continue
            }
            
            guard reminderTriggerIsDeleted == false else {
                removeReminderTrigger(forReminderTriggerUUID: reminderTriggerUUID)
                continue
            }
            
            if let reminderTrigger = ReminderTrigger(
                fromReminderTriggerBody: fromBody,
                reminderTriggerToOverride: findReminderTrigger(forReminderTriggerUUID: reminderTriggerUUID)
            ) {
                addReminderTrigger(forReminderTrigger: reminderTrigger)
            }
        }
    }
    
    /// finds and returns the reference of a trigger matching the given UUID
    func findReminderTrigger(
        forReminderTriggerUUID: UUID
    ) -> ReminderTrigger? {
        reminderTriggers.first {
            $0.reminderTriggerUUID == forReminderTriggerUUID
        }
    }
    
    /// Helper function: remove existing then append without sorting
    private func addReminderTriggerWithoutSorting(
        forReminderTrigger: ReminderTrigger
    ) {
        reminderTriggers.removeAll {
            $0.reminderTriggerUUID == forReminderTrigger.reminderTriggerUUID
        }
        reminderTriggers.append(forReminderTrigger)
    }
    
    /// If a trigger with the same UUID exists, replaces it, then sorts
    func addReminderTrigger(forReminderTrigger: ReminderTrigger) {
        addReminderTriggerWithoutSorting(forReminderTrigger: forReminderTrigger)
        reminderTriggers.sort(by: { $0 <= $1 })
    }
    
    /// Invokes addReminderTrigger(forReminderTrigger:) for each, sorting once
    func addReminderTriggers(
        forReminderTriggers: [ReminderTrigger]
    ) {
        for trigger in forReminderTriggers {
            addReminderTriggerWithoutSorting(forReminderTrigger: trigger)
        }
        reminderTriggers.sort(by: { $0 <= $1 })
    }
    
    /// Returns true if at least one trigger was removed by UUID
    @discardableResult
    func removeReminderTrigger(
        forReminderTriggerUUID: UUID
    ) -> Bool {
        var didRemoveObject = false
        /// finds and returns the reference of a trigger matching the given UUID
        reminderTriggers.removeAll { trigger in
            guard trigger.reminderTriggerUUID == forReminderTriggerUUID else {
                return false
            }
            didRemoveObject = true
            return true
        }
        
        return didRemoveObject
    }
}
