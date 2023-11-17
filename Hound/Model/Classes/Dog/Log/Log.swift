//
//  ReminderLog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class Log: NSObject, NSCoding, NSCopying {

    // MARK: - Properties

    private var storedLogId: Int = ClassConstant.LogConstant.defaultLogId
    var logId: Int {
        get {
            return storedLogId
        }
        set {
            storedLogId = newValue >= 1 ? newValue : -1
        }
    }

    var userId: String = ClassConstant.LogConstant.defaultUserId

    var logAction: LogAction = ClassConstant.LogConstant.defaultLogAction {
        didSet {
            // Check to see if logUnit are compatible with the new logAction
            let logUnits = LogUnit.logUnits(forLogAction: logAction)
            
            guard let logUnit = logUnit else {
                self.logNumberOfLogUnits = nil
                self.logUnit = nil
                return
            }
            
            if logUnits.contains(logUnit) == false {
                self.logNumberOfLogUnits = nil
                self.logUnit = nil
            }
        }
    }

    private var storedLogCustomActionName: String = ""
    var logCustomActionName: String {
        get {
            return storedLogCustomActionName
        }
        set {
            storedLogCustomActionName = String(newValue.prefix(ClassConstant.LogConstant.logCustomActionNameCharacterLimit))
        }
    }
    
    private(set) var logStartDate: Date = ClassConstant.LogConstant.defaultLogStartDate
    private(set) var logEndDate: Date?
    
    /// logStartDate takes precendence over logEndDate. Therefore, if the times overlap incorrectly, i.e. logStartDate is after logEndDate, then logStartDate is set its value, then logEndDate is adjusted so that it is later than logStartDate.
    func changeLogDate(forLogStartDate: Date, forLogEndDate: Date?) {
        logStartDate = forLogStartDate
        
        if let forLogEndDate = forLogEndDate {
            // If logEndDate is before logStartDate, that is incorrect. Therefore, disregard it
            logEndDate = forLogStartDate.distance(to: forLogEndDate) < 0.0 ? nil : logEndDate
        }
        else {
            logEndDate = nil
        }
        
    }

    private var storedLogNote: String = ""
    var logNote: String {
        get {
            return storedLogNote
        }
        set {
            storedLogNote = String(newValue.prefix(ClassConstant.LogConstant.logNoteCharacterLimit))
        }
    }
    
    private(set) var logUnit: LogUnit?
    private(set) var logNumberOfLogUnits: Double?
    
    /// If forNumberOfUnits or forLogUnit is nil, both are set to nil. The forLogUnit provided must be in the array of LogUnits that are valid for this log's logAction.
    func changeLogUnit(forLogUnit: LogUnit?, forLogNumberOfLogUnits: Double?) {
        guard let forLogUnit = forLogUnit, let forLogNumberOfLogUnits = forLogNumberOfLogUnits else {
            logNumberOfLogUnits = nil
            logUnit = nil
            return
        }
        
        guard LogUnit.logUnits(forLogAction: logAction).contains(forLogUnit) == true else {
            logNumberOfLogUnits = nil
            logUnit = nil
            return
        }
        
        logNumberOfLogUnits = round(forLogNumberOfLogUnits * 100.0) / 100.0
        logUnit = forLogUnit
    }
    
    // MARK: - Main

    init(
        forLogId: Int? = nil,
        forUserId: String? = nil,
        forLogAction: LogAction? = nil,
        forLogCustomActionName: String? = nil,
        forLogStartDate: Date? = nil,
        forLogEndDate: Date? = nil,
        forLogNote: String? = nil,
        forLogUnit: LogUnit? = nil,
        forLogNumberOfUnits: Double? = nil
    ) {
        super.init()
        self.logId = forLogId ?? logId
        self.userId = forUserId ?? userId
        self.logAction = forLogAction ?? logAction
        self.logCustomActionName = forLogCustomActionName ?? logCustomActionName
        self.logStartDate = forLogStartDate ?? logStartDate
        self.logEndDate = forLogEndDate
        self.logNote = forLogNote ?? logNote
        self.changeLogUnit(forLogUnit: forLogUnit, forLogNumberOfLogUnits: forLogNumberOfUnits)
    }

    /// Provide a dictionary literal of log properties to instantiate log. Optionally, provide a log to override with new properties from logBody.
    convenience init?(forLogBody logBody: [String: Any], overrideLog: Log?) {
        // Don't pull logId or logIsDeleted from overrideLog. A valid logBody needs to provide this itself
        let logId: Int? = logBody[KeyConstant.logId.rawValue] as? Int
        let logIsDeleted: Bool? = logBody[KeyConstant.logIsDeleted.rawValue] as? Bool

        guard let logId = logId, let logIsDeleted = logIsDeleted, logIsDeleted == false else {
            // the log is missing required components or has been deleted
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
        
        let logStartDate: Date? = {
            if let logStartDateString = logBody[KeyConstant.logStartDate.rawValue] as? String {
                return logStartDateString.formatISO8601IntoDate()
            }
            return nil
        }() ?? overrideLog?.logStartDate
        
        let logEndDate: Date? = {
            if let logEndDateString = logBody[KeyConstant.logEndDate.rawValue] as? String {
                return logEndDateString.formatISO8601IntoDate()
            }
            return nil
        }() ?? overrideLog?.logEndDate
        
        let logNote: String? = logBody[KeyConstant.logNote.rawValue] as? String ?? overrideLog?.logNote
        
        let logUnit: LogUnit? = {
            guard let logUnitString = logBody[KeyConstant.logUnit.rawValue] as? String else {
                return nil
            }
            return LogUnit(rawValue: logUnitString)
        }() ?? overrideLog?.logUnit
        
        let logNumberOfLogUnits: Double? = logBody[KeyConstant.logNumberOfLogUnits.rawValue] as? Double ?? overrideLog?.logNumberOfLogUnits

        self.init(
            forLogId: logId,
            forUserId: userId,
            forLogAction: logAction,
            forLogCustomActionName: logCustomActionName,
            forLogStartDate: logStartDate,
            forLogEndDate: logEndDate,
            forLogNote: logNote,
            forLogUnit: logUnit,
            forLogNumberOfUnits: logNumberOfLogUnits
        )
    }
    
    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Log()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        copy.storedLogId = self.logId
        copy.userId = self.userId
        copy.logAction = self.logAction
        copy.storedLogCustomActionName = self.logCustomActionName
        copy.logStartDate = self.logStartDate
        copy.logEndDate = self.logEndDate
        copy.storedLogNote = self.logNote
        copy.logUnit = self.logUnit
        copy.logNumberOfLogUnits = self.logNumberOfLogUnits
        return copy
    }

    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        let decodedLogId = aDecoder.decodeInteger(forKey: KeyConstant.logId.rawValue)
        let decodedUserId = aDecoder.decodeObject(forKey: KeyConstant.userId.rawValue) as? String
        let decodedLogAction = LogAction(rawValue: aDecoder.decodeObject(forKey: KeyConstant.logAction.rawValue) as? String ?? ClassConstant.LogConstant.defaultLogAction.rawValue)
        let decodedLogCustomActionName = aDecoder.decodeObject(forKey: KeyConstant.logCustomActionName.rawValue) as? String
        // <= 3.1.0 logDate
        let decodedLogStartDate = aDecoder.decodeObject(forKey: KeyConstant.logStartDate.rawValue) as? Date ?? aDecoder.decodeObject(forKey: "logDate") as? Date
        let decodedLogEndDate = aDecoder.decodeObject(forKey: KeyConstant.logEndDate.rawValue) as? Date
        let decodedLogNote = aDecoder.decodeObject(forKey: KeyConstant.logNote.rawValue) as? String
        let decodedLogUnit = {
            let logUnitString = aDecoder.decodeObject(forKey: KeyConstant.logUnit.rawValue) as? String
            if let logUnitString = logUnitString {
                return LogUnit(rawValue: logUnitString)
            }
            else {
                return nil
            }
        }()
        let decodedLogNumberOfLogUnits = aDecoder.decodeObject(forKey: KeyConstant.logNumberOfLogUnits.rawValue) as? Double
        
        self.init(
            forLogId: decodedLogId,
            forUserId: decodedUserId,
            forLogAction: decodedLogAction,
            forLogCustomActionName: decodedLogCustomActionName,
            forLogStartDate: decodedLogStartDate,
            forLogEndDate: decodedLogEndDate,
            forLogNote: decodedLogNote,
            forLogUnit: decodedLogUnit,
            forLogNumberOfUnits: decodedLogNumberOfLogUnits
        )
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(logId, forKey: KeyConstant.logId.rawValue)
        aCoder.encode(userId, forKey: KeyConstant.userId.rawValue)
        aCoder.encode(logAction.rawValue, forKey: KeyConstant.logAction.rawValue)
        aCoder.encode(logCustomActionName, forKey: KeyConstant.logCustomActionName.rawValue)
        aCoder.encode(logStartDate, forKey: KeyConstant.logStartDate.rawValue)
        aCoder.encode(logEndDate, forKey: KeyConstant.logEndDate.rawValue)
        aCoder.encode(logNote, forKey: KeyConstant.logNote.rawValue)
        aCoder.encode(logUnit?.rawValue, forKey: KeyConstant.logUnit.rawValue)
        aCoder.encode(logNumberOfLogUnits, forKey: KeyConstant.logNumberOfLogUnits.rawValue)
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
        body[KeyConstant.logStartDate.rawValue] = logStartDate.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.logEndDate.rawValue] = logEndDate?.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.logNote.rawValue] = logNote
        body[KeyConstant.logUnit.rawValue] = logUnit?.rawValue
        body[KeyConstant.logNumberOfLogUnits.rawValue] = logNumberOfLogUnits
        return body

    }
}
