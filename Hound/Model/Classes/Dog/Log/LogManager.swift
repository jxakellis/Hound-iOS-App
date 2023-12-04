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
        return copy
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        logs = aDecoder.decodeObject(forKey: KeyConstant.logs.rawValue) as? [Log] ?? logs
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(logs, forKey: KeyConstant.logs.rawValue)
    }

    // MARK: - Properties
    private(set) var logs: [Log] = []

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
    }
    
    private func sortLogs() {
        logs.sort(by: { $0 <= $1 })
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

    func removeLog(forLogId logId: Int) {
        // check to find the index of targetted log
        let logIndex: Int? = logs.firstIndex { log in
            log.logId == logId
        }

        guard let logIndex = logIndex else {
            return
        }

        logs.remove(at: logIndex)
    }

    func removeLog(forIndex index: Int) {
        // Make sure the index is valid
        guard logs.count > index else {
            return
        }

        logs.remove(at: index)
    }
}

extension LogManager {

    // MARK: Locate

    /// finds and returns the reference of a log matching the given logId
    func findLog(forLogId logId: Int) -> Log? {
        logs.first(where: { $0.logId == logId })
    }
}
