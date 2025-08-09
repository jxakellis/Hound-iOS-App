//
//  DogLogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Manages a collection of logs for a dog and provides efficient sorted access.
/// Sorted arrays are cached and only rebuilt when the underlying data changes.
final class DogLogManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogLogManager(parentDog: parentDog)
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
        self.init(logs: decodedDogLogs ?? [], parentDog: nil)
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
    
    init(logs: [Log] = [], parentDog: Dog?) {
        self.parentDog = parentDog
        super.init()
        _ = addLogs(logs: logs, invokeDogTriggers: false)
    }
    
    /// Provide an array of dictionary literal of log properties to instantiate dogLogs. Provide a logManager to have the dogLogs add themselves into, update themselves in, or delete themselves from.
    convenience init(fromLogBodies: [JSONResponseBody], dogLogManagerToOverride: DogLogManager?, parentDog: Dog?) {
        self.init(logs: dogLogManagerToOverride?.dogLogs ?? [], parentDog: parentDog)
        
        for fromBody in fromLogBodies {
            // Don't pull logId or logIsDeleted from logToOverride. A valid fromBody needs to provide this itself
            let logId: Int? = fromBody[Constant.Key.logId.rawValue] as? Int
            let logUUID: UUID? = UUID.fromString(UUIDString: fromBody[Constant.Key.logUUID.rawValue] as? String)
            let logIsDeleted: Bool? = fromBody[Constant.Key.logIsDeleted.rawValue] as? Bool
            
            guard logId != nil, let logUUID = logUUID, let logIsDeleted = logIsDeleted else {
                // couldn't construct essential components to intrepret log
                continue
            }
            
            guard logIsDeleted == false else {
                removeLog(logUUID: logUUID)
                continue
            }
            
            if let log = Log(fromBody: fromBody, logToOverride: findLog(logUUID: logUUID)) {
                _ = addLog(log: log, invokeDogTriggers: false)
            }
        }
    }
    
    // MARK: - Functions
    
    /// finds and returns the reference of a log matching the given logUUID
    func findLog(logUUID: UUID) -> Log? {
        dogLogs.first(where: { $0.logUUID == logUUID })
    }
    
    private func invalidateSortedCaches() {
        sortedDogLogsCreated = nil
        sortedDogLogsModified = nil
        sortedDogLogsStart = nil
        sortedDogLogsEnd = nil
    }
    
    func sortedDogLogs(dateType: LogsDateType, sortDirection: LogsSortDirection) -> [Log] {
        let ascendingLogs: [Log]
        switch dateType {
        case .createdDate:
            if sortedDogLogsCreated == nil {
                sortedDogLogsCreated = LogsSort.sort(dogLogs, dateType: .createdDate, sortDirection: .ascending)
            }
            ascendingLogs = sortedDogLogsCreated ?? []
        case .modifiedDate:
            if sortedDogLogsModified == nil {
                sortedDogLogsModified = LogsSort.sort(dogLogs, dateType: .modifiedDate, sortDirection: .ascending)
            }
            ascendingLogs = sortedDogLogsModified ?? []
        case .logStartDate:
            if sortedDogLogsStart == nil {
                sortedDogLogsStart = LogsSort.sort(dogLogs, dateType: .logStartDate, sortDirection: .ascending)
            }
            ascendingLogs = sortedDogLogsStart ?? []
        case .logEndDate:
            if sortedDogLogsEnd == nil {
                sortedDogLogsEnd = LogsSort.sort(dogLogs, dateType: .logEndDate, sortDirection: .ascending)
            }
            ascendingLogs = sortedDogLogsEnd ?? []
        }
        
        return sortDirection == .ascending ? ascendingLogs : Array(ascendingLogs.reversed())
    }
    
    /// Adds a log to the dogLogs array and sorts. If invokeDogTriggers is true, it will the dog to see if any triggers are activated (and if so, generate reminders from them and return those reminders)
    @discardableResult
    func addLog(log: Log, invokeDogTriggers: Bool) -> ([Reminder], [Trigger]) {
        removeLog(logUUID: log.logUUID)
        
        dogLogs.append(log)
        invalidateSortedCaches()
        
        var generatedReminders: [Reminder] = []
        var activatedTriggers: [Trigger] = []
        if invokeDogTriggers {
            if let dog = parentDog {
                let triggers = dog.dogTriggers.matchingActivatedTriggers(log: log)
                for trigger in triggers {
                    if let reminder = trigger.createTriggerResultReminder(afterLog: log) {
                        generatedReminders.append(reminder)
                        activatedTriggers.append(trigger)
                    }
                }
            }
            else {
                HoundLogger.general.error("DogLogManager.addLog\t: Dog is nil & invokeDogTriggers is true, cannot invoke dog triggers for log: \(log.logUUID) \(log.logActionTypeId) \(log.logCustomActionName)")
            }
        }
        
        return (generatedReminders, activatedTriggers)
    }
    
    /// Adds a log to the dogLogs array and sorts. If invokeDogTriggers is true, it will the dog to see if any triggers are activated (and if so, generate reminders from them and return those reminders)
    @discardableResult
    func addLogs(logs: [Log], invokeDogTriggers: Bool) -> ([Reminder], [Trigger]) {
        removeLogs(logUUIDs: logs.map { $0.logUUID })
        
        dogLogs.append(contentsOf: logs)
        invalidateSortedCaches()
        
        var generatedReminders: [Reminder] = []
        var activatedTriggers: [Trigger] = []
        if invokeDogTriggers {
            if let dog = parentDog {
                for log in logs {
                    let triggers = dog.dogTriggers.matchingActivatedTriggers(log: log)
                    for trigger in triggers {
                        if let reminder = trigger.createTriggerResultReminder(afterLog: log) {
                            generatedReminders.append(reminder)
                            activatedTriggers.append(trigger)
                        }
                    }
                }
            }
        }
        
        return (generatedReminders, activatedTriggers)
    }
    
    @discardableResult func removeLog(logUUID: UUID) -> Bool {
        var didRemoveObject = false
        
        dogLogs.removeAll { log in
            guard log.logUUID == logUUID else {
                return false
            }
            
            didRemoveObject = true
            return true
        }
        
        if didRemoveObject {
            invalidateSortedCaches()
        }
        
        return didRemoveObject
    }
    
    @discardableResult func removeLogs(logUUIDs: [UUID]) -> Bool {
        var didRemoveObject = false
        
        dogLogs.removeAll { l in
            guard logUUIDs.contains(l.logUUID) else {
                return false
            }
            
            didRemoveObject = true
            return true
        }
        
        if didRemoveObject {
            invalidateSortedCaches()
        }
        
        return didRemoveObject
    }
}
