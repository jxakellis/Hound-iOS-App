//
//  ReminderLog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class Log: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Log()
        copy.logId = self.logId
        copy.userId = self.userId
        copy.logAction = self.logAction
        copy.logCustomActionName = self.logCustomActionName
        copy.logDate = self.logDate
        copy.logNote = self.logNote
        copy.logUnit = self.logUnit
        copy.logNumberOfLogUnits = self.logNumberOfLogUnits
        return copy
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        logId = aDecoder.decodeInteger(forKey: KeyConstant.logId.rawValue)
        // shift logId of 0 to proper placeholder of -1
        logId = logId >= 1 ? logId : -1

        userId = aDecoder.decodeObject(forKey: KeyConstant.userId.rawValue) as? String ?? userId
        logAction = LogAction(rawValue: aDecoder.decodeObject(forKey: KeyConstant.logAction.rawValue) as? String ?? ClassConstant.LogConstant.defaultLogAction.rawValue) ?? logAction
        logCustomActionName = aDecoder.decodeObject(forKey: KeyConstant.logCustomActionName.rawValue) as? String ?? logCustomActionName
        logDate = aDecoder.decodeObject(forKey: KeyConstant.logDate.rawValue) as? Date ?? logDate
        logNote = aDecoder.decodeObject(forKey: KeyConstant.logNote.rawValue) as? String ?? logNote
        logUnit = {
            let logUnitString = aDecoder.decodeObject(forKey: KeyConstant.logUnit.rawValue) as? String
            if let logUnitString = logUnitString {
                return LogUnit(rawValue: logUnitString)
            }
            else {
                return nil
            }
        }()
        logNumberOfLogUnits = aDecoder.decodeObject(forKey: KeyConstant.logNumberOfLogUnits.rawValue) as? Double ?? logNumberOfLogUnits
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(logId, forKey: KeyConstant.logId.rawValue)
        aCoder.encode(userId, forKey: KeyConstant.userId.rawValue)
        aCoder.encode(logAction.rawValue, forKey: KeyConstant.logAction.rawValue)
        aCoder.encode(logCustomActionName, forKey: KeyConstant.logCustomActionName.rawValue)
        aCoder.encode(logDate, forKey: KeyConstant.logDate.rawValue)
        aCoder.encode(logNote, forKey: KeyConstant.logNote.rawValue)
        aCoder.encode(logUnit?.rawValue, forKey: KeyConstant.logUnit.rawValue)
        aCoder.encode(logNumberOfLogUnits, forKey: KeyConstant.logNumberOfLogUnits.rawValue)
    }

    // MARK: - Properties

    var logId: Int = ClassConstant.LogConstant.defaultLogId

    var userId: String = ClassConstant.LogConstant.defaultUserId

    private(set) var logAction: LogAction = ClassConstant.LogConstant.defaultLogAction
    func changeLogAction(forLogAction: LogAction) {
        logAction = forLogAction
        
        // Check to see if logUnit are compatible with the new logAction
        let logUnits = LogUnit.logUnits(forLogAction: logAction)
        
        guard let logUnits = logUnits, let logUnit = logUnit else {
            self.logNumberOfLogUnits = nil
            self.logUnit = nil
            return
        }
        
        if logUnits.contains(logUnit) == false {
            self.logNumberOfLogUnits = nil
            self.logUnit = nil
        }
    }

    private(set) var logCustomActionName: String = ClassConstant.LogConstant.defaultLogCustomActionName
    func changeLogCustomActionName(forLogCustomActionName: String) throws {
        guard forLogCustomActionName.count <= ClassConstant.LogConstant.logCustomActionNameCharacterLimit else {
            throw ErrorConstant.LogError.logCustomActionNameCharacterLimitExceeded()
        }

        logCustomActionName = forLogCustomActionName
    }
    
    var logDate: Date = ClassConstant.LogConstant.defaultLogDate

    private(set) var logNote: String = ClassConstant.LogConstant.defaultLogNote
    func changeLogNote(forLogNote: String) throws {
        guard forLogNote.count <= ClassConstant.LogConstant.logNoteCharacterLimit else {
            throw ErrorConstant.LogError.logNoteCharacterLimitExceeded()
        }

        logNote = forLogNote
    }
    
    private(set) var logNumberOfLogUnits: Double?
    private(set) var logUnit: LogUnit?
    /// If forNumberOfUnits or forLogUnit is nil, both are set to nil. The forLogUnit provided must be in the array of LogUnits that are valid for this log's logAction.
    func changeLogUnit(forNumberOfUnits: Double?, forLogUnit: LogUnit?) throws {
        guard let forNumberOfUnits = forNumberOfUnits, let forLogUnit = forLogUnit else {
            logNumberOfLogUnits = nil
            logUnit = nil
            return
        }
        
        guard let logUnits = LogUnit.logUnits(forLogAction: logAction), logUnits.contains(forLogUnit) else {
            throw ErrorConstant.LogError.logUnitIncompatibleWithLogAction()
        }
        
        logNumberOfLogUnits = forNumberOfUnits
        logUnit = forLogUnit
    }
    
    // MARK: - Main

    override init() {
        super.init()
    }

    /// Provide a dictionary literal of log properties to instantiate log. Optionally, provide a log to override with new properties from logBody.
    convenience init?(forLogBody logBody: [String: Any], overrideLog: Log?) {
        // Don't pull logId or logIsDeleted from overrideLog. A valid logBody needs to provide this itself
        let logId: Int? = logBody[KeyConstant.logId.rawValue] as? Int
        let logIsDeleted: Bool? = logBody[KeyConstant.logIsDeleted.rawValue] as? Bool

        // a log body needs a log and logIsDeleted to be intrepeted as same, updated, or deleted
        guard let logId = logId, let logIsDeleted = logIsDeleted else {
            // couldn't construct essential components to intrepret log
            return nil
        }

        guard logIsDeleted == false else {
            // the log has been deleted
            return nil
        }

        // if the log is the same, then we pull values from overrideLog
        // if the log is updated, then we pull values from logBody
        let userId: String? = logBody[KeyConstant.userId.rawValue] as? String ?? overrideLog?.userId
        
        let logAction: LogAction? = {
            guard let logActionString = logBody[KeyConstant.logAction.rawValue] as? String else {
                return nil
            }
            return LogAction(rawValue: logActionString)
        }() ?? overrideLog?.logAction
        
        let logCustomActionName: String? = logBody[KeyConstant.logCustomActionName.rawValue] as? String ?? overrideLog?.logCustomActionName
        
        let logDate: Date? = {
            if let logDateString = logBody[KeyConstant.logDate.rawValue] as? String {
                return logDateString.formatISO8601IntoDate()
            }
            return nil
        }() ?? overrideLog?.logDate
        
        let logNote: String? = logBody[KeyConstant.logNote.rawValue] as? String ?? overrideLog?.logNote
        
        let logUnit: LogUnit? = {
            guard let logUnitString = logBody[KeyConstant.logUnit.rawValue] as? String else {
                return nil
            }
            return LogUnit(rawValue: logUnitString)
        }() ?? overrideLog?.logUnit
        
        let logNumberOfLogUnits: Double? = logBody[KeyConstant.logNumberOfLogUnits.rawValue] as? Double ?? overrideLog?.logNumberOfLogUnits

        // no properties should be nil. Either a complete logBody should be provided (i.e. no previousDogManagerSynchronization was used in query) or a potentially partial logBody (i.e. previousDogManagerSynchronization used in query) should be passed with an overrideLogManager
        guard let userId = userId, let logAction = logAction, let logCustomActionName = logCustomActionName, let logDate = logDate, let logNote = logNote else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }

        self.init()
        self.logId = logId
        self.userId = userId
        self.logAction = logAction
        self.logCustomActionName = logCustomActionName
        self.logDate = logDate
        self.logNote = logNote
        self.logUnit = logUnit
        self.logNumberOfLogUnits = logNumberOfLogUnits
    }

}

extension Log {
    // MARK: - Request

    /// Returns an array literal of the logs's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody(forDogId dogId: Int) -> [String: Any] {
        var body: [String: Any] = [:]
        body[KeyConstant.dogId.rawValue] = dogId
        body[KeyConstant.logId.rawValue] = logId
        body[KeyConstant.logAction.rawValue] = logAction.rawValue
        body[KeyConstant.logCustomActionName.rawValue] = logCustomActionName
        body[KeyConstant.logDate.rawValue] = logDate.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.logNote.rawValue] = logNote
        body[KeyConstant.logUnit.rawValue] = logUnit?.rawValue
        body[KeyConstant.logNumberOfLogUnits.rawValue] = logNumberOfLogUnits
        return body

    }
}
