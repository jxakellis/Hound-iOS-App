//
//  ReminderLog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class Log: NSObject, NSCoding, NSCopying, Comparable {
    
    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Log()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        copy.logId = self.logId
        copy.logUUID = self.logUUID
        copy.userId = self.userId
        copy.logAction = self.logAction
        copy.storedLogCustomActionName = self.logCustomActionName
        copy.logStartDate = self.logStartDate
        copy.logEndDate = self.logEndDate
        copy.storedLogNote = self.logNote
        copy.logUnit = self.logUnit
        copy.logNumberOfLogUnits = self.logNumberOfLogUnits
        copy.offlineModeComponents = self.offlineModeComponents.copy() as? OfflineModeComponents ?? OfflineModeComponents()
        
        return copy
    }

    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        let decodedLogId = aDecoder.decodeObject(forKey: KeyConstant.logId.rawValue) as? Int
        let decodedLogUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeObject(forKey: KeyConstant.logUUID.rawValue) as? String)
        let decodedUserId = aDecoder.decodeObject(forKey: KeyConstant.userId.rawValue) as? String
        let decodedLogAction = LogAction(internalValue: aDecoder.decodeObject(forKey: KeyConstant.logAction.rawValue) as? String ?? ClassConstant.LogConstant.defaultLogAction.internalValue)
        let decodedLogCustomActionName = aDecoder.decodeObject(forKey: KeyConstant.logCustomActionName.rawValue) as? String
        let decodedLogStartDate = aDecoder.decodeObject(forKey: KeyConstant.logStartDate.rawValue) as? Date
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
        let decodedOfflineModeComponents = aDecoder.decodeObject(forKey: KeyConstant.offlineModeComponents.rawValue) as? OfflineModeComponents
        
        self.init(
            forLogId: decodedLogId,
            forLogUUID: decodedLogUUID,
            forUserId: decodedUserId,
            forLogAction: decodedLogAction,
            forLogCustomActionName: decodedLogCustomActionName,
            forLogStartDate: decodedLogStartDate,
            forLogEndDate: decodedLogEndDate,
            forLogNote: decodedLogNote,
            forLogUnit: decodedLogUnit,
            forLogNumberOfUnits: decodedLogNumberOfLogUnits,
            forOfflineModeComponents: decodedOfflineModeComponents
        )
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(logId, forKey: KeyConstant.logId.rawValue)
        aCoder.encode(logUUID.uuidString, forKey: KeyConstant.logUUID.rawValue)
        aCoder.encode(userId, forKey: KeyConstant.userId.rawValue)
        aCoder.encode(logAction.internalValue, forKey: KeyConstant.logAction.rawValue)
        aCoder.encode(logCustomActionName, forKey: KeyConstant.logCustomActionName.rawValue)
        aCoder.encode(logStartDate, forKey: KeyConstant.logStartDate.rawValue)
        aCoder.encode(logEndDate, forKey: KeyConstant.logEndDate.rawValue)
        aCoder.encode(logNote, forKey: KeyConstant.logNote.rawValue)
        aCoder.encode(logUnit?.rawValue, forKey: KeyConstant.logUnit.rawValue)
        aCoder.encode(logNumberOfLogUnits, forKey: KeyConstant.logNumberOfLogUnits.rawValue)
        aCoder.encode(offlineModeComponents, forKey: KeyConstant.offlineModeComponents.rawValue)
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Log, rhs: Log) -> Bool {
        guard lhs.logStartDate != rhs.logStartDate else {
            // If same logStartDate, then one with lesser logId comes first
            guard let lhsLogId = lhs.logId else {
                guard rhs.logId != nil else {
                    // Neither have an id
                    return lhs.logUUID.uuidString < rhs.logUUID.uuidString
                }
                
                // lhs doesn't have a logId but rhs does. rhs should come first
                return false
            }
            
            guard let rhsLogId = rhs.logId else {
                // lhs has a logId but rhs doesn't. lhs should come first
                return true
            }
            
            return lhsLogId <= rhsLogId
        }
        // Returning true means item1 comes before item2, false means item2 before item1

        // Returns true if lhs is earlier in time than rhs

        // If lhs's distance to date2 is positive, i.e. rhs is later in time, returns false as date2 should be ordered first (most recent (to current Date()) dates first)
        // If date1 is later in time than date2, returns true as it should come before date2
        return lhs.logStartDate.distance(to: rhs.logStartDate) <= 0
    }

    // MARK: - Properties

    /// The logId given to this log from the Hound database
    var logId: Int?
    
    /// The UUID of this log that is generated locally upon creation. Useful in identifying the log before/in the process of creating it
    var logUUID: UUID = UUID()

    /// The userId of the user that created this log
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
            storedLogCustomActionName = String((newValue.trimmingCharacters(in: .whitespacesAndNewlines)).prefix(ClassConstant.LogConstant.logCustomActionNameCharacterLimit))
        }
    }
    
    private(set) var logStartDate: Date = ClassConstant.LogConstant.defaultLogStartDate
    private(set) var logEndDate: Date?

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
    
    /// Components that are used to track an object to determine whether it was synced with the Hound server and whether it needs to be when the device comes back online
    private(set) var offlineModeComponents: OfflineModeComponents = OfflineModeComponents()
    
    // MARK: - Main
    
    init(
        forLogId: Int? = nil,
        forLogUUID: UUID? = nil,
        forUserId: String? = nil,
        forLogAction: LogAction? = nil,
        forLogCustomActionName: String? = nil,
        forLogStartDate: Date? = nil,
        forLogEndDate: Date? = nil,
        forLogNote: String? = nil,
        forLogUnit: LogUnit? = nil,
        forLogNumberOfUnits: Double? = nil,
        forOfflineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        self.logId = forLogId ?? logId
        self.logUUID = forLogUUID ?? logUUID
        self.userId = forUserId ?? userId
        self.logAction = forLogAction ?? logAction
        self.logCustomActionName = forLogCustomActionName ?? logCustomActionName
        self.logStartDate = forLogStartDate ?? logStartDate
        self.logEndDate = forLogEndDate
        self.logNote = forLogNote ?? logNote
        self.changeLogUnit(forLogUnit: forLogUnit, forLogNumberOfLogUnits: forLogNumberOfUnits)
        self.offlineModeComponents = forOfflineModeComponents ?? offlineModeComponents
    }

    /// Provide a dictionary literal of log properties to instantiate log. Optionally, provide a log to override with new properties from fromLogBody.
    convenience init?(fromLogBody: [String: Any?], logToOverride: Log?) {
        // Don't pull logId or logIsDeleted from logToOverride. A valid fromLogBody needs to provide this itself
        let logId: Int? = fromLogBody[KeyConstant.logId.rawValue] as? Int
        let logUUID: UUID? = UUID.fromString(forUUIDString: fromLogBody[KeyConstant.logUUID.rawValue] as? String)
        let logLastModified: Date? = (fromLogBody[KeyConstant.logLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        let logIsDeleted: Bool? = fromLogBody[KeyConstant.logIsDeleted.rawValue] as? Bool

        // The body needs an id, uuid, and isDeleted to be intrepreted as same, updated, or deleted. Otherwise, it is invalid
        guard let logId = logId, let logUUID = logUUID, let logLastModified = logLastModified, let logIsDeleted = logIsDeleted else {
            return nil
        }
        
        guard logIsDeleted == false else {
            // The log has been deleted. Doesn't matter if our offline mode made any changes
            return nil
        }
        
        // If we have pulled an update from the server which is more outdated than our local change, then ignore the data from the server. Otherwise, the newer server update takes precedence over our offline update
        if let logToOverride = logToOverride, let initialAttemptedSyncDate = logToOverride.offlineModeComponents.initialAttemptedSyncDate, initialAttemptedSyncDate >= logLastModified {
            self.init(
                forLogId: logToOverride.logId,
                forLogUUID: logToOverride.logUUID,
                forUserId: logToOverride.userId,
                forLogAction: logToOverride.logAction,
                forLogCustomActionName: logToOverride.logCustomActionName,
                forLogStartDate: logToOverride.logStartDate,
                forLogEndDate: logToOverride.logEndDate,
                forLogNote: logToOverride.logNote,
                forLogUnit: logToOverride.logUnit,
                forLogNumberOfUnits: logToOverride.logNumberOfLogUnits,
                forOfflineModeComponents: logToOverride.offlineModeComponents
            )
            return
        }

        // if the log is the same, then we pull values from logToOverride
        // if the log is updated, then we pull values from fromLogBody
        let userId: String? = fromLogBody[KeyConstant.userId.rawValue] as? String ?? logToOverride?.userId
        
        let logAction: LogAction? = {
            guard let logActionString = fromLogBody[KeyConstant.logAction.rawValue] as? String else {
                return nil
            }
            return LogAction(internalValue: logActionString)
        }() ?? logToOverride?.logAction
        
        let logCustomActionName: String? = fromLogBody[KeyConstant.logCustomActionName.rawValue] as? String ?? logToOverride?.logCustomActionName
        
        let logStartDate: Date? = {
            if let logStartDateString = fromLogBody[KeyConstant.logStartDate.rawValue] as? String {
                return logStartDateString.formatISO8601IntoDate()
            }
            return nil
        }() ?? logToOverride?.logStartDate
        
        let logEndDate: Date? = {
            if let logEndDateString = fromLogBody[KeyConstant.logEndDate.rawValue] as? String {
                return logEndDateString.formatISO8601IntoDate()
            }
            return nil
        }() ?? logToOverride?.logEndDate
        
        let logNote: String? = fromLogBody[KeyConstant.logNote.rawValue] as? String ?? logToOverride?.logNote
        
        let logUnit: LogUnit? = {
            guard let logUnitString = fromLogBody[KeyConstant.logUnit.rawValue] as? String else {
                return nil
            }
            return LogUnit(rawValue: logUnitString)
        }() ?? logToOverride?.logUnit
        
        let logNumberOfLogUnits: Double? = fromLogBody[KeyConstant.logNumberOfLogUnits.rawValue] as? Double ?? logToOverride?.logNumberOfLogUnits

        self.init(
            forLogId: logId,
            forLogUUID: logUUID,
            forUserId: userId,
            forLogAction: logAction,
            forLogCustomActionName: logCustomActionName,
            forLogStartDate: logStartDate,
            forLogEndDate: logEndDate,
            forLogNote: logNote,
            forLogUnit: logUnit,
            forLogNumberOfUnits: logNumberOfLogUnits,
            // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
            forOfflineModeComponents: nil
        )
    }
    
    // MARK: - Functions
    
    /// logStartDate takes precendence over logEndDate. Therefore, if the times overlap incorrectly, i.e. logStartDate is after logEndDate, then logStartDate is set its value, then logEndDate is adjusted so that it is later than logStartDate.
    func changeLogDate(forLogStartDate: Date, forLogEndDate: Date?) {
        logStartDate = forLogStartDate
        
        if let forLogEndDate = forLogEndDate {
            // If forLogStartDate is after forLogEndDate, that is incorrect. Therefore, disregard it
            logEndDate = forLogStartDate >= forLogEndDate ? nil : forLogEndDate
        }
        else {
            logEndDate = nil
        }
    }
    
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

    /// Returns an array literal of the logs's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody(forDogUUID: UUID) -> [String: CompatibleDataTypeForJSON?] {
        var body: [String: CompatibleDataTypeForJSON?] = [:]
        body[KeyConstant.dogUUID.rawValue] = forDogUUID.uuidString
        body[KeyConstant.logId.rawValue] = logId
        body[KeyConstant.logUUID.rawValue] = logUUID.uuidString
        body[KeyConstant.logAction.rawValue] = logAction.internalValue
        body[KeyConstant.logCustomActionName.rawValue] = logCustomActionName
        body[KeyConstant.logStartDate.rawValue] = logStartDate.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.logEndDate.rawValue] = logEndDate?.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.logNote.rawValue] = logNote
        body[KeyConstant.logUnit.rawValue] = logUnit?.rawValue
        body[KeyConstant.logNumberOfLogUnits.rawValue] = logNumberOfLogUnits
        return body

    }
}
