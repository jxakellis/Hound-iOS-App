//
//  LogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = LogManager()
        for log in logs {
            if let logCopy = log.copy() as? Log {
                copy.logs.append(logCopy)
            }
        }
        if let uniqueLogActionsResult = uniqueLogActionsResult {
            copy.uniqueLogActionsResult = []
            for uniqueLogActionCopy in uniqueLogActionsResult {
                copy.uniqueLogActionsResult?.append(uniqueLogActionCopy)
            }
        }
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        logs = aDecoder.decodeObject(forKey: KeyConstant.logs.rawValue) as? [Log] ?? logs
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(logs, forKey: KeyConstant.logs.rawValue)
    }
    
    // MARK: - Main
    override init() {
        super.init()
    }
    
    init(forLogs: [Log] = []) {
        super.init()
        addLogs(forLogs: forLogs)
    }
    
    /// Provide an array of dictionary literal of log properties to instantiate logs. Provide a logManager to have the logs add themselves into, update themselves in, or delete themselves from.
    convenience init(fromLogBodies logBodies: [[String: Any]], overrideLogManager: LogManager?) {
        self.init(forLogs: overrideLogManager?.logs ?? [])
        
        for logBody in logBodies {
            // Don't pull logId or logIsDeleted from overrideLog. A valid logBody needs to provide this itself
            let logId: Int? = logBody[KeyConstant.logId.rawValue] as? Int
            let logIsDeleted: Bool? = logBody[KeyConstant.logIsDeleted.rawValue] as? Bool
            
            guard let logId = logId, let logIsDeleted = logIsDeleted else {
                // couldn't construct essential components to intrepret log
                continue
            }
            
            guard logIsDeleted == false else {
                removeLog(forLogId: logId)
                continue
            }
            
            if let log = Log(forLogBody: logBody, overrideLog: findLog(forLogId: logId)) {
                addLog(forLog: log)
            }
        }
    }
    
    // MARK: - Properties
    private (set) var logs: [Log] = []
    
    // Stores the result of uniqueLogActions. This increases efficency as if uniqueLogActions is called multiple times, without the logs array changing, we return this same stored value. If the logs array is updated, then we invalidate the stored value so its recalculated next time
    private var uniqueLogActionsResult: [LogAction]?
    
    // MARK: - Functions
    
    /// Helper function allows us to use the same logic for addLog and addLogs and allows us to only sort at the end. Without this function, addLogs would invoke addLog repeadly and sortLogs() with each call.
    private func addLogWithoutSorting(forLog newLog: Log, shouldOverridePlaceholderLog: Bool) {
        // removes any existing logs that have the same logId as they would cause problems.
        logs.removeAll { oldLog in
            guard oldLog.logId == newLog.logId else {
                return false
            }
            
            guard (shouldOverridePlaceholderLog == true) || (shouldOverridePlaceholderLog == false && oldLog.logId >= 0) else {
                return false
            }
            
            return true
        }
        
        // check to see if we are dealing with a placeholder id log
        if newLog.logId < 0 {
            // If there are multiple logs with placeholder ids, set the new log's placeholder id to the lowest possible, therefore no overlap.
            var lowestLogId = Int.max
            logs.forEach { log in
                if log.logId < lowestLogId {
                    lowestLogId = log.logId
                }
            }
            
            // the lowest log is is <0 so there are other placeholder logs, that means we should set our new log to a placeholder id that is 1 below the lowest (making this log the new lowest)
            if lowestLogId < 0 {
                newLog.logId = lowestLogId - 1
            }
        }
        
        logs.append(newLog)
        
        uniqueLogActionsResult = nil
    }
    
    func addLog(forLog log: Log, shouldOverridePlaceholderLog: Bool = false) {
        
        addLogWithoutSorting(forLog: log, shouldOverridePlaceholderLog: shouldOverridePlaceholderLog)
        
        sortLogs()
        
    }
    
    func addLogs(forLogs logs: [Log]) {
        for log in logs {
            addLogWithoutSorting(forLog: log, shouldOverridePlaceholderLog: false)
        }
        
        sortLogs()
        
    }
    
    private func sortLogs() {
        logs.sort { (log1, log2) -> Bool in
            // Returning true means item1 comes before item2, false means item2 before item1
            
            // Returns true if var1's log1 is earlier in time than var2's log2
            
            // If date1's distance to date2 is positive, i.e. date2 is later in time, returns false as date2 should be ordered first (most recent (to current Date()) dates first)
            // If date1 is later in time than date2, returns true as it should come before date2
            return log1.logDate.distance(to: log2.logDate) <= 0
        }
    }
    
    func removeLog(forLogId logId: Int) {
        // check to find the index of targetted log
        let logIndex: Int? = logs.firstIndex { log in
            return log.logId == logId
        }
        
        guard let logIndex = logIndex else {
            return
        }
        
        logs.remove(at: logIndex)
        uniqueLogActionsResult = nil
    }
    
    func removeLog(forIndex index: Int) {
        // Make sure the index is valid
        guard logs.count > index else {
            return
        }
        
        logs.remove(at: index)
        uniqueLogActionsResult = nil
    }
    
    // MARK: Information
    
    /// Returns an array of known log actions. Each known log action has an array of logs attached to it. This means you can find every log for a given log action
    var uniqueLogActions: [LogAction] {
        // If we have the output of this calculated property stored, return it. Increases efficency by not doing calculation multiple times. Stored property is set to nil if any logs change, so in that case we would recalculate
        if let uniqueLogActionsResult = uniqueLogActionsResult {
            return uniqueLogActionsResult
        }
        
        var logActions: [LogAction] = []
        
        // find all unique logActions
        for dogLog in logs where logActions.contains(dogLog.logAction) == false {
            // If we have added all of the logActions possible, then stop the loop as there is no point for more iteration
            guard logActions.count != LogAction.allCases.count else {
                break
            }
            logActions.append(dogLog.logAction)
        }
        
        // sorts by the order defined by the enum, so whatever case is first in the code of the enum that is the order of the uniqueLogActions
        logActions.sort { logAction1, logAction2 in
            
            // finds corrosponding indexs
            let logAction1Index: Int! = LogAction.allCases.firstIndex(of: logAction1)
            let logAction2Index: Int! = LogAction.allCases.firstIndex(of: logAction2)
            
            return logAction1Index <= logAction2Index
        }
        
        uniqueLogActionsResult = logActions
        return logActions
    }
    
}

extension LogManager {
    
    // MARK: Locate
    
    /// finds and returns the reference of a log matching the given logId
    func findLog(forLogId logId: Int) -> Log? {
        return logs.first(where: { $0.logId == logId })
    }
}
