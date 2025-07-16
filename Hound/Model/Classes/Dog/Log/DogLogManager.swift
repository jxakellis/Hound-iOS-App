//
//  DogLogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogLogManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogLogManager(forParentDog: parentDog)
        for dogLog in dogLogs {
            if let logCopy = dogLog.copy() as? Log {
                copy.dogLogs.append(logCopy)
            }
        }
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        let decodedDogLogs: [Log]? = aDecoder.decodeOptionalObject(forKey: KeyConstant.dogLogs.rawValue)
        dogLogs = decodedDogLogs ?? dogLogs
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogLogs, forKey: KeyConstant.dogLogs.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var dogLogs: [Log] = []
    
    weak var parentDog: Dog?
    
    // MARK: - Main
    
    init(forLogs: [Log] = [], forParentDog: Dog?) {
        self.parentDog = forParentDog
        super.init()
        addLogs(forLogs: forLogs)
    }
    
    /// Provide an array of dictionary literal of log properties to instantiate dogLogs. Provide a logManager to have the dogLogs add themselves into, update themselves in, or delete themselves from.
    convenience init(fromLogBodies: [[String: Any?]], dogLogManagerToOverride: DogLogManager?, forParentDog: Dog?) {
        self.init(forLogs: dogLogManagerToOverride?.dogLogs ?? [], forParentDog: forParentDog)
        
        for fromBody in fromLogBodies {
            // Don't pull logId or logIsDeleted from logToOverride. A valid fromBody needs to provide this itself
            let logId: Int? = fromBody[KeyConstant.logId.rawValue] as? Int
            let logUUID: UUID? = UUID.fromString(forUUIDString: fromBody[KeyConstant.logUUID.rawValue] as? String)
            let logIsDeleted: Bool? = fromBody[KeyConstant.logIsDeleted.rawValue] as? Bool
            
            guard logId != nil, let logUUID = logUUID, let logIsDeleted = logIsDeleted else {
                // couldn't construct essential components to intrepret log
                continue
            }
            
            guard logIsDeleted == false else {
                removeLog(forLogUUID: logUUID)
                continue
            }
            
            if let log = Log(fromBody: fromBody, logToOverride: findLog(forLogUUID: logUUID)) {
                addLog(forLog: log)
            }
        }
    }
    
    // MARK: - Functions
    
    /// finds and returns the reference of a log matching the given logUUID
    func findLog(forLogUUID: UUID) -> Log? {
        dogLogs.first(where: { $0.logUUID == forLogUUID })
    }
    
    /// Helper function allows us to use the same logic for addLog and addLogs and allows us to only sort at the end. Without this function, addLogs would invoke addLog repeadly and sortLogs() with each call.
    private func addLogWithoutSorting(forLog: Log) {
        removeLog(forLogUUID: forLog.logUUID)
        
        dogLogs.append(forLog)
    }
    
    @discardableResult
    func addLog(forLog: Log, invokeDogTriggers: Bool = true) -> [Reminder] {
        addLogWithoutSorting(forLog: forLog)
        
        dogLogs.sort(by: { $0 <= $1 })
        
        var generatedReminders: [Reminder] = []
        if invokeDogTriggers {
            if let dog = parentDog {
                let triggers = dog.dogTriggers.matchingActivatedTriggers(forLog: forLog)
                for trigger in triggers {
                    if let reminder = trigger.createTriggerResultReminder(afterLog: forLog) {
                        generatedReminders.append(reminder)
                    }
                }
            }
            
        }
        
        return generatedReminders
    }
    
    @discardableResult
    func addLogs(forLogs: [Log], invokeDogTriggers: Bool = true) -> [Reminder] {
        for forLog in forLogs {
            addLogWithoutSorting(forLog: forLog)
        }
        
        dogLogs.sort(by: { $0 <= $1 })
        
        var generatedReminders: [Reminder] = []
        if invokeDogTriggers {
            if let dog = parentDog {
                for log in forLogs {
                    let triggers = dog.dogTriggers.matchingActivatedTriggers(forLog: log)
                    for trigger in triggers {
                        if let reminder = trigger.createTriggerResultReminder(afterLog: log) {
                            generatedReminders.append(reminder)
                        }
                    }
                }
            }
        }
        
        return generatedReminders
    }
    
    /// Returns true if it removed at least one log with the same logUUID
    @discardableResult func removeLog(forLogUUID: UUID) -> Bool {
        var didRemoveObject = false
        
        dogLogs.removeAll { log in
            guard log.logUUID == forLogUUID else {
                return false
            }
            
            didRemoveObject = true
            return true
        }
        
        return didRemoveObject
    }
    
    /// Returns true if it removed at least a log at the specified index
    @discardableResult func removeLog(forIndex: Int) -> Bool {
        // Make sure the index is valid
        guard forIndex >= 0 && forIndex < dogLogs.count  else {
            return false
        }
        
        dogLogs.remove(at: forIndex)
        return true
    }
}
