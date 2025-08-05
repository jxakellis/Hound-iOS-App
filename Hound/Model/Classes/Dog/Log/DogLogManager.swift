//
//  DogLogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO support different sort methods: start, end, created, and modified date. this should be four presorted copies of dogLogs. when add/update/remove log called, then the presorted copies should be updated. dont store them tho. only dog logs is stored.

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
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDogLogs: [Log]? = aDecoder.decodeOptionalObject(forKey: Constant.Key.dogLogs.rawValue)
        self.init(forLogs: decodedDogLogs ?? [], forParentDog: nil)
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogLogs, forKey: Constant.Key.dogLogs.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var dogLogs: [Log] = []
    
    private var sortedDogLogsCreated: [Log]?
    private var sortedDogLogsModified: [Log]?
    private var sortedDogLogsStart: [Log]?
    private var sortedDogLogsEnd: [Log]?
    
    weak var parentDog: Dog?
    
    // MARK: - Main
    
    init(forLogs: [Log] = [], forParentDog: Dog?) {
        self.parentDog = forParentDog
        super.init()
        addLogs(forLogs: forLogs, invokeDogTriggers: false)
    }
    
    /// Provide an array of dictionary literal of log properties to instantiate dogLogs. Provide a logManager to have the dogLogs add themselves into, update themselves in, or delete themselves from.
    convenience init(fromLogBodies: [JSONResponseBody], dogLogManagerToOverride: DogLogManager?, forParentDog: Dog?) {
        self.init(forLogs: dogLogManagerToOverride?.dogLogs ?? [], forParentDog: forParentDog)
        
        for fromBody in fromLogBodies {
            // Don't pull logId or logIsDeleted from logToOverride. A valid fromBody needs to provide this itself
            let logId: Int? = fromBody[Constant.Key.logId.rawValue] as? Int
            let logUUID: UUID? = UUID.fromString(forUUIDString: fromBody[Constant.Key.logUUID.rawValue] as? String)
            let logIsDeleted: Bool? = fromBody[Constant.Key.logIsDeleted.rawValue] as? Bool
            
            guard logId != nil, let logUUID = logUUID, let logIsDeleted = logIsDeleted else {
                // couldn't construct essential components to intrepret log
                continue
            }
            
            guard logIsDeleted == false else {
                removeLog(forLogUUID: logUUID)
                continue
            }
            
            if let log = Log(fromBody: fromBody, logToOverride: findLog(forLogUUID: logUUID)) {
                addLog(forLog: log, invokeDogTriggers: false)
            }
        }
    }
    
    // MARK: - Functions
    
    /// finds and returns the reference of a log matching the given logUUID
    func findLog(forLogUUID: UUID) -> Log? {
        dogLogs.first(where: { $0.logUUID == forLogUUID })
    }
    
    func sortedDogLogs(sortField: LogsSortField, sortDirection: LogsSortDirection) -> [Log] {
        switch sortField {
        case .createdDate:
            if let existing = sortedDogLogsCreated {
                sortedDogLogsCreated = LogsSort.sort(existing, sortField: .createdDate, sortDirection: sortDirection)
            } else {
                sortedDogLogsCreated = LogsSort.sort(dogLogs, sortField: .createdDate, sortDirection: sortDirection)
            }
            return sortedDogLogsCreated ?? []
        case .modifiedDate:
            if let existing = sortedDogLogsModified {
                sortedDogLogsModified = LogsSort.sort(existing, sortField: .modifiedDate, sortDirection: sortDirection)
            } else {
                sortedDogLogsModified = LogsSort.sort(dogLogs, sortField: .modifiedDate, sortDirection: sortDirection)
            }
            return sortedDogLogsModified ?? []
        case .logStartDate:
            if let existing = sortedDogLogsStart {
                sortedDogLogsStart = LogsSort.sort(existing, sortField: .logStartDate, sortDirection: sortDirection)
            } else {
                sortedDogLogsStart = LogsSort.sort(dogLogs, sortField: .logStartDate, sortDirection: sortDirection)
            }
            return sortedDogLogsStart ?? []
        case .logEndDate:
            if let existing = sortedDogLogsEnd {
                sortedDogLogsEnd = LogsSort.sort(existing, sortField: .logEndDate, sortDirection: sortDirection)
            } else {
                sortedDogLogsEnd = LogsSort.sort(dogLogs, sortField: .logEndDate, sortDirection: sortDirection)
            }
            return sortedDogLogsEnd ?? []
        }
    }
    
    /// Adds a log to the dogLogs array and sorts. If invokeDogTriggers is true, it will the dog to see if any triggers are activated (and if so, generate reminders from them and return those reminders)
    @discardableResult
    func addLog(forLog: Log, invokeDogTriggers: Bool) -> [Reminder] {
        removeLog(forLogUUID: forLog.logUUID)
        
        dogLogs.append(forLog)
        sortedDogLogsCreated?.append(forLog)
        sortedDogLogsModified?.append(forLog)
        sortedDogLogsStart?.append(forLog)
        sortedDogLogsEnd?.append(forLog)
        
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
            else {
                HoundLogger.general.error("DogLogManager.addLog\t: Dog is nil & invokeDogTriggers is true, cannot invoke dog triggers for log: \(forLog.logUUID) \(forLog.logActionTypeId) \(forLog.logCustomActionName)")
            }
        }
        
        return generatedReminders
    }
    
    /// Adds a log to the dogLogs array and sorts. If invokeDogTriggers is true, it will the dog to see if any triggers are activated (and if so, generate reminders from them and return those reminders)
    @discardableResult
    func addLogs(forLogs: [Log], invokeDogTriggers: Bool) -> [Reminder] {
        removeLogs(forLogUUIDs: forLogs.map { $0.logUUID })
        
        dogLogs.append(contentsOf: forLogs)
        sortedDogLogsCreated?.append(contentsOf: forLogs)
        sortedDogLogsModified?.append(contentsOf: forLogs)
        sortedDogLogsStart?.append(contentsOf: forLogs)
        sortedDogLogsEnd?.append(contentsOf: forLogs)
        
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
    
    @discardableResult func removeLog(forLogUUID: UUID) -> Bool {
        var didRemoveObject = false
        
        dogLogs.removeAll { log in
            guard log.logUUID == forLogUUID else {
                return false
            }
            
            didRemoveObject = true
            return true
        }
        
        sortedDogLogsCreated?.removeAll(where: { $0.logUUID == forLogUUID })
        sortedDogLogsModified?.removeAll(where: { $0.logUUID == forLogUUID })
        sortedDogLogsStart?.removeAll(where: { $0.logUUID == forLogUUID })
        sortedDogLogsEnd?.removeAll(where: { $0.logUUID == forLogUUID })
        
        return didRemoveObject
    }
    
    @discardableResult func removeLogs(forLogUUIDs: [UUID]) -> Bool {
        var didRemoveObject = false
        
        dogLogs.removeAll { log in
            guard forLogUUIDs.contains(log.logUUID) else {
                return false
            }
            
            didRemoveObject = true
            return true
        }
        
        sortedDogLogsCreated?.removeAll(where: { forLogUUIDs.contains($0.logUUID) })
        sortedDogLogsModified?.removeAll(where: { forLogUUIDs.contains($0.logUUID) })
        sortedDogLogsStart?.removeAll(where: { forLogUUIDs.contains($0.logUUID) })
        sortedDogLogsEnd?.removeAll(where: { forLogUUIDs.contains($0.logUUID) })
        
        return didRemoveObject
    }
}
