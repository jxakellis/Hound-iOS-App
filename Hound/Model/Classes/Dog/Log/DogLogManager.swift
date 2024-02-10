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
    convenience init(fromLogBodies logBodies: [[String: PrimativeTypeProtocol?]], overrideDogLogManager: DogLogManager?) {
        self.init(forLogs: overrideDogLogManager?.logs ?? [])

        for logBody in logBodies {
            // Don't pull logId or logIsDeleted from overrideLog. A valid logBody needs to provide this itself
            let logId: Int? = logBody[KeyConstant.logId.rawValue] as? Int
            let logUUID: UUID? = UUID.fromString(forUUIDString: logBody[KeyConstant.logUUID.rawValue] as? String)
            let logIsDeleted: Bool? = logBody[KeyConstant.logIsDeleted.rawValue] as? Bool

            guard logId != nil, let logUUID = logUUID, let logIsDeleted = logIsDeleted else {
                // couldn't construct essential components to intrepret log
                continue
            }

            guard logIsDeleted == false else {
                removeLog(forLogUUID: logUUID)
                continue
            }

            if let log = Log(forLogBody: logBody, overrideLog: findLog(forLogUUID: logUUID)) {
                addLog(forLog: log)
            }
        }
    }

    // MARK: - Functions

    /// Helper function allows us to use the same logic for addLog and addLogs and allows us to only sort at the end. Without this function, addLogs would invoke addLog repeadly and sortLogs() with each call.
    private func addLogWithoutSorting(forLog: Log) {
        // removes any existing logs that have the same logUUID as they would cause problems.
        logs.removeAll { log in
            return log.logUUID == forLog.logUUID
        }

        logs.append(forLog)
    }
    
    private func sortLogs() {
        logs.sort(by: { $0 <= $1 })
    }

    func addLog(forLog log: Log) {
        addLogWithoutSorting(forLog: log)

        sortLogs()
    }

    func addLogs(forLogs logs: [Log]) {
        for log in logs {
            addLogWithoutSorting(forLog: log)
        }

        sortLogs()
    }

    func removeLog(forLogUUID: UUID) {
        logs.removeAll { log in
            return log.logUUID == forLogUUID
        }
    }

    func removeLog(forIndex index: Int) {
        // Make sure the index is valid
        guard index >= 0 && index < logs.count  else {
            return
        }

        logs.remove(at: index)
    }
}

extension DogLogManager {

    // MARK: Locate

    /// finds and returns the reference of a log matching the given logUUID
    func findLog(forLogUUID: UUID) -> Log? {
        logs.first(where: { $0.logUUID == forLogUUID })
    }
}
