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
        guard let dogTriggers: [Trigger] = aDecoder.decodeOptionalObject(forKey: Constant.Key.dogTriggers.rawValue) else {
            return nil
        }
        
        self.init(forDogTriggers: dogTriggers)
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogTriggers,
                      forKey: Constant.Key.dogTriggers.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var dogTriggers: [Trigger] = []
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    init(forDogTriggers: [Trigger] = []) {
        super.init()
        addTriggers(forDogTriggers: forDogTriggers)
    }
    
    convenience init(
        fromTriggerBodies: [JSONResponseBody],
        dogTriggerManagerToOverride: DogTriggerManager?
    ) {
        self.init(forDogTriggers:
                    dogTriggerManagerToOverride?.dogTriggers ?? []
        )
        
        for fromBody in fromTriggerBodies {
            let triggerId = fromBody[Constant.Key.triggerId.rawValue] as? Int
            let triggerUUID = UUID.fromString(
                forUUIDString: fromBody[Constant.Key.triggerUUID.rawValue] as? String
            )
            let triggerIsDeleted = fromBody[Constant.Key.triggerIsDeleted.rawValue] as? Bool
            
            guard triggerId != nil,
                  let triggerUUID = triggerUUID,
                  let triggerIsDeleted = triggerIsDeleted
            else {
                continue
            }
            
            guard triggerIsDeleted == false else {
                removeTrigger(forTriggerUUID: triggerUUID)
                continue
            }
            
            if let trigger = Trigger(
                fromBody: fromBody,
                triggerToOverride: findTrigger(forTriggerUUID: triggerUUID)
            ) {
                addTrigger(forTrigger: trigger)
            }
        }
    }
    
    // MARK: - Functions
    
    /// finds and returns the reference of a trigger matching the given UUID
    func findTrigger(
        forTriggerUUID: UUID
    ) -> Trigger? {
        dogTriggers.first {
            $0.triggerUUID == forTriggerUUID
        }
    }
    
    /// Helper function: remove existing then append without sorting
    private func addTriggerWithoutSorting(
        forTrigger: Trigger
    ) {
        dogTriggers.removeAll {
            $0.triggerUUID == forTrigger.triggerUUID
        }
        dogTriggers.append(forTrigger)
    }
    
    /// If a trigger with the same UUID exists, replaces it, then sorts
    func addTrigger(forTrigger: Trigger) {
        addTriggerWithoutSorting(forTrigger: forTrigger)
        dogTriggers.sort(by: { $0 <= $1 })
    }
    
    /// Invokes addTrigger(forTrigger:) for each, sorting once
    func addTriggers(
        forDogTriggers: [Trigger]
    ) {
        for trigger in forDogTriggers {
            addTriggerWithoutSorting(forTrigger: trigger)
        }
        dogTriggers.sort(by: { $0 <= $1 })
    }
    
    /// Returns true if at least one trigger was removed by UUID
    @discardableResult
    func removeTrigger(
        forTriggerUUID: UUID
    ) -> Bool {
        var didRemoveObject = false
        /// finds and returns the reference of a trigger matching the given UUID
        dogTriggers.removeAll { trigger in
            guard trigger.triggerUUID == forTriggerUUID else {
                return false
            }
            didRemoveObject = true
            return true
        }
        
        return didRemoveObject
    }
    
    func matchingActivatedTriggers(forLog log: Log) -> [Trigger] {
        return dogTriggers.filter { trigger in trigger.shouldActivateTrigger(forLog: log) }
    }
}
