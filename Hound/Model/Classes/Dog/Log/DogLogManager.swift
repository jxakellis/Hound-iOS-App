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
        let copy = DogLogManager()
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
    convenience init(fromLogBodies: [[String: Any?]], dogLogManagerToOverride: DogLogManager?) {
        self.init(forLogs: dogLogManagerToOverride?.logs ?? [])

        for fromLogBody in fromLogBodies {
            // Don't pull logId or logIsDeleted from logToOverride. A valid fromLogBody needs to provide this itself
            let logId: Int? = fromLogBody[KeyConstant.logId.rawValue] as? Int
            let logUUID: UUID? = UUID.fromString(forUUIDString: fromLogBody[KeyConstant.logUUID.rawValue] as? String)
            let logIsDeleted: Bool? = fromLogBody[KeyConstant.logIsDeleted.rawValue] as? Bool

            guard logId != nil, let logUUID = logUUID, let logIsDeleted = logIsDeleted else {
                // couldn't construct essential components to intrepret log
                continue
            }

            guard logIsDeleted == false else {
                removeLog(forLogUUID: logUUID)
                continue
            }

            if let log = Log(fromLogBody: fromLogBody, logToOverride: findLog(forLogUUID: logUUID)) {
                addLog(forLog: log)
            }
        }
    }

    // MARK: - Functions
    
    /// finds and returns the reference of a log matching the given logUUID
    func findLog(forLogUUID: UUID) -> Log? {
        logs.first(where: { $0.logUUID == forLogUUID })
    }

    /// Helper function allows us to use the same logic for addLog and addLogs and allows us to only sort at the end. Without this function, addLogs would invoke addLog repeadly and sortLogs() with each call.
    private func addLogWithoutSorting(forLog: Log) {
        removeLog(forLogUUID: forLog.logUUID)

        logs.append(forLog)
    }

    func addLog(forLog: Log) {
        addLogWithoutSorting(forLog: forLog)

        logs.sort(by: { $0 <= $1 })
    }

    func addLogs(forLogs: [Log]) {
        for forLog in forLogs {
            addLogWithoutSorting(forLog: forLog)
        }

        logs.sort(by: { $0 <= $1 })
    }

    /// Returns true if it removed at least one log with the same logUUID
    @discardableResult func removeLog(forLogUUID: UUID) -> Bool {
        var didRemoveObject = false
        
        logs.removeAll { log in
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
        guard forIndex >= 0 && forIndex < logs.count  else {
            return false
        }

        logs.remove(at: forIndex)
        return true
    }
}
