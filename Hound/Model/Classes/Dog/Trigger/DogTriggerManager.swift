//
//  DogTriggerManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogTriggerManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogTriggerManager()
        for trigger in dogTriggers {
            if let triggerCopy = trigger.copy() as? Trigger {
                copy.dogTriggers.append(triggerCopy)
            }
        }
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let dogTriggers: [Trigger] = aDecoder.decodeOptionalObject(forKey: KeyConstant.dogTriggers.rawValue) else {
            return nil
        }
        
        self.init(dogTriggers: dogTriggers)
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogTriggers,
                      forKey: KeyConstant.dogTriggers.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var dogTriggers: [Trigger] = []
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    init(dogTriggers: [Trigger] = []) {
        super.init()
        addTriggers(dogTriggers: dogTriggers)
    }
    
    convenience init(
        fromTriggerBodies: [JSONResponseBody],
        dogTriggerManagerToOverride: DogTriggerManager?
    ) {
        self.init(dogTriggers:
                    dogTriggerManagerToOverride?.dogTriggers ?? []
        )
        
        for fromBody in fromTriggerBodies {
            let triggerId = fromBody[KeyConstant.triggerId.rawValue] as? Int
            let triggerUUID = UUID.fromString(
                UUIDString: fromBody[KeyConstant.triggerUUID.rawValue] as? String
            )
            let triggerIsDeleted = fromBody[KeyConstant.triggerIsDeleted.rawValue] as? Bool
            
            guard triggerId != nil,
                  let triggerUUID = triggerUUID,
                  let triggerIsDeleted = triggerIsDeleted
            else {
                continue
            }
            
            guard triggerIsDeleted == false else {
                removeTrigger(triggerUUID: triggerUUID)
                continue
            }
            
            if let trigger = Trigger(
                fromBody: fromBody,
                triggerToOverride: findTrigger(triggerUUID: triggerUUID)
            ) {
                addTrigger(trigger: trigger)
            }
        }
    }
    
    // MARK: - Functions
    
    /// finds and returns the reference of a trigger matching the given UUID
    func findTrigger(
        triggerUUID: UUID
    ) -> Trigger? {
        dogTriggers.first {
            $0.triggerUUID == triggerUUID
        }
    }
    
    /// Helper function: remove existing then append without sorting
    private func addTriggerWithoutSorting(
        trigger: Trigger
    ) {
        dogTriggers.removeAll {
            $0.triggerUUID == trigger.triggerUUID
        }
        dogTriggers.append(trigger)
    }
    
    /// If a trigger with the same UUID exists, replaces it, then sorts
    func addTrigger(trigger: Trigger) {
        addTriggerWithoutSorting(trigger: trigger)
        dogTriggers.sort(by: { $0 <= $1 })
    }
    
    /// Invokes addTrigger(trigger:) for each, sorting once
    func addTriggers(
        dogTriggers: [Trigger]
    ) {
        for trigger in dogTriggers {
            addTriggerWithoutSorting(trigger: trigger)
        }
        self.dogTriggers.sort(by: { $0 <= $1 })
    }
    
    /// Returns true if at least one trigger was removed by UUID
    @discardableResult
    func removeTrigger(
        triggerUUID: UUID
    ) -> Bool {
        var didRemoveObject = false
        /// finds and returns the reference of a trigger matching the given UUID
        dogTriggers.removeAll { trigger in
            guard trigger.triggerUUID == triggerUUID else {
                return false
            }
            didRemoveObject = true
            return true
        }
        
        return didRemoveObject
    }
    
    func matchingActivatedTriggers(log: Log) -> [Trigger] {
        return dogTriggers.filter { trigger in trigger.shouldActivateTrigger(log: log) }
    }
}
