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
        copy.logActionTypeId = self.logActionTypeId
        copy.storedLogCustomActionName = self.logCustomActionName
        copy.logStartDate = self.logStartDate
        copy.logEndDate = self.logEndDate
        copy.storedLogNote = self.logNote
        copy.logUnitTypeId = self.logUnitTypeId
        copy.logNumberOfLogUnits = self.logNumberOfLogUnits
        copy.logCreatedByReminderUUID = self.logCreatedByReminderUUID
        copy.offlineModeComponents = self.offlineModeComponents.copy() as? OfflineModeComponents ?? OfflineModeComponents()
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedLogId: Int? = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logId.rawValue)
        let decodedLogUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeOptionalString(forKey: Constant.Key.logUUID.rawValue))
        let decodedUserId: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.userId.rawValue)
        let decodedLogActionTypeId: Int = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logActionTypeId.rawValue) ?? Constant.Class.Log.defaultLogActionTypeId
        let decodedLogCustomActionName: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.logCustomActionName.rawValue)
        let decodedLogStartDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.logStartDate.rawValue)
        let decodedLogEndDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.logEndDate.rawValue)
        let decodedLogNote: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.logNote.rawValue)
        let decodedLogUnitTypeId: Int? = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logUnitTypeId.rawValue)
        let decodedLogNumberOfLogUnits: Double? = aDecoder.decodeOptionalDouble(forKey: Constant.Key.logNumberOfLogUnits.rawValue)
        let decodedLogCreatedByReminderUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeOptionalObject(forKey: Constant.Key.logCreatedByReminderUUID.rawValue))
        let decodedOfflineModeComponents: OfflineModeComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.offlineModeComponents.rawValue)
        
        self.init(
            forLogId: decodedLogId,
            forLogUUID: decodedLogUUID,
            forUserId: decodedUserId,
            forLogActionTypeId: decodedLogActionTypeId,
            forLogCustomActionName: decodedLogCustomActionName,
            forLogStartDate: decodedLogStartDate,
            forLogEndDate: decodedLogEndDate,
            forLogNote: decodedLogNote,
            forLogUnitTypeId: decodedLogUnitTypeId,
            forLogNumberOfUnits: decodedLogNumberOfLogUnits,
            forCreatedByReminderUUID: decodedLogCreatedByReminderUUID,
            offlineModeComponents: decodedOfflineModeComponents
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        if let logId = logId {
            aCoder.encode(logId, forKey: Constant.Key.logId.rawValue)
        }
        aCoder.encode(logUUID.uuidString, forKey: Constant.Key.logUUID.rawValue)
        aCoder.encode(userId, forKey: Constant.Key.userId.rawValue)
        aCoder.encode(logActionTypeId, forKey: Constant.Key.logActionTypeId.rawValue)
        aCoder.encode(logCustomActionName, forKey: Constant.Key.logCustomActionName.rawValue)
        aCoder.encode(logStartDate, forKey: Constant.Key.logStartDate.rawValue)
        if let logEndDate = logEndDate {
            aCoder.encode(logEndDate, forKey: Constant.Key.logEndDate.rawValue)
        }
        aCoder.encode(logNote, forKey: Constant.Key.logNote.rawValue)
        if let logUnitTypeId = logUnitTypeId {
            aCoder.encode(logUnitTypeId, forKey: Constant.Key.logUnitTypeId.rawValue)
        }
        if let logNumberOfLogUnits = logNumberOfLogUnits {
            aCoder.encode(logNumberOfLogUnits, forKey: Constant.Key.logNumberOfLogUnits.rawValue)
        }
        if let logCreatedByReminderUUID = logCreatedByReminderUUID {
            aCoder.encode(logCreatedByReminderUUID.uuidString, forKey: Constant.Key.logCreatedByReminderUUID.rawValue)
        }
        aCoder.encode(offlineModeComponents, forKey: Constant.Key.offlineModeComponents.rawValue)
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
    var userId: String = Constant.Class.Log.defaultUserId
    
    var logActionTypeId: Int = Constant.Class.Log.defaultLogActionTypeId {
        didSet {
            // Check to see if logUnitTypeId are compatible with the new logActionTypeId
            let logUnitTypeIds = LogActionType.find(forLogActionTypeId: logActionTypeId).associatedLogUnitTypes.map { $0.logUnitTypeId }
            
            guard let logUnitTypeId = logUnitTypeId else {
                self.logNumberOfLogUnits = nil
                self.logUnitTypeId = nil
                return
            }
            
            if logUnitTypeIds.contains(logUnitTypeId) == false {
                self.logNumberOfLogUnits = nil
                self.logUnitTypeId = nil
            }
        }
    }
    
    var logActionType: LogActionType {
        return LogActionType.find(forLogActionTypeId: logActionTypeId)
    }
    
    private var storedLogCustomActionName: String = ""
    var logCustomActionName: String {
        get {
            return storedLogCustomActionName
        }
        set {
            storedLogCustomActionName = String((newValue.trimmingCharacters(in: .whitespacesAndNewlines)).prefix(Constant.Class.Log.logCustomActionNameCharacterLimit))
        }
    }
    
    private(set) var logStartDate: Date = Constant.Class.Log.defaultLogStartDate
    private(set) var logEndDate: Date?
    
    private var storedLogNote: String = ""
    var logNote: String {
        get {
            return storedLogNote
        }
        set {
            storedLogNote = String(newValue.prefix(Constant.Class.Log.logNoteCharacterLimit))
        }
    }
    
    private(set) var logUnitTypeId: Int?
    
    var logUnitType: LogUnitType? {
        guard let logUnitTypeId = logUnitTypeId else {
            return nil
        }
        return LogUnitType.find(forLogUnitTypeId: logUnitTypeId)
    }
    
    private(set) var logNumberOfLogUnits: Double?
    
    private(set) var logCreatedByReminderUUID: UUID?
    
    /// Components that are used to track an object to determine whether it was synced with the Hound server and whether it needs to be when the device comes back online
    private(set) var offlineModeComponents: OfflineModeComponents = OfflineModeComponents()
    
    // MARK: - Main
    
    init(
        forLogId: Int? = nil,
        forLogUUID: UUID? = nil,
        forUserId: String? = nil,
        forLogActionTypeId: Int? = nil,
        forLogCustomActionName: String? = nil,
        forLogStartDate: Date? = nil,
        forLogEndDate: Date? = nil,
        forLogNote: String? = nil,
        forLogUnitTypeId: Int? = nil,
        forLogNumberOfUnits: Double? = nil,
        forCreatedByReminderUUID: UUID? = nil,
        offlineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        self.logId = forLogId ?? logId
        self.logUUID = forLogUUID ?? logUUID
        self.userId = forUserId ?? userId
        self.logActionTypeId = forLogActionTypeId ?? logActionTypeId
        self.logCustomActionName = forLogCustomActionName ?? logCustomActionName
        self.logStartDate = forLogStartDate ?? logStartDate
        self.logEndDate = forLogEndDate ?? logEndDate
        self.logNote = forLogNote ?? logNote
        self.changeLogUnit(forLogUnitTypeId: forLogUnitTypeId, forLogNumberOfLogUnits: forLogNumberOfUnits)
        self.logCreatedByReminderUUID = forCreatedByReminderUUID ?? logCreatedByReminderUUID
        self.offlineModeComponents = offlineModeComponents ?? self.offlineModeComponents
    }
    
    /// Provide a dictionary literal of log properties to instantiate log. Optionally, provide a log to override with new properties from fromBody.
    convenience init?(fromBody: JSONResponseBody, logToOverride: Log?) {
        // Don't pull logId or logIsDeleted from logToOverride. A valid fromBody needs to provide this itself
        let logId: Int? = fromBody[Constant.Key.logId.rawValue] as? Int
        let logUUID: UUID? = UUID.fromString(forUUIDString: fromBody[Constant.Key.logUUID.rawValue] as? String)
        let logLastModified: Date? = (fromBody[Constant.Key.logLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        let logIsDeleted: Bool? = fromBody[Constant.Key.logIsDeleted.rawValue] as? Bool
        
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
                forLogActionTypeId: logToOverride.logActionTypeId,
                forLogCustomActionName: logToOverride.logCustomActionName,
                forLogStartDate: logToOverride.logStartDate,
                forLogEndDate: logToOverride.logEndDate,
                forLogNote: logToOverride.logNote,
                forLogUnitTypeId: logToOverride.logUnitTypeId,
                forLogNumberOfUnits: logToOverride.logNumberOfLogUnits,
                forCreatedByReminderUUID: logToOverride.logCreatedByReminderUUID,
                offlineModeComponents: logToOverride.offlineModeComponents
            )
            return
        }
        
        // if the log is the same, then we pull values from logToOverride
        // if the log is updated, then we pull values from fromBody
        let userId: String? = fromBody[Constant.Key.userId.rawValue] as? String ?? logToOverride?.userId
        
        let logActionTypeId: Int? = fromBody[Constant.Key.logActionTypeId.rawValue] as? Int ?? logToOverride?.logActionTypeId
        
        let logCustomActionName: String? = fromBody[Constant.Key.logCustomActionName.rawValue] as? String ?? logToOverride?.logCustomActionName
        
        let logStartDate: Date? = {
            if let logStartDateString = fromBody[Constant.Key.logStartDate.rawValue] as? String {
                return logStartDateString.formatISO8601IntoDate()
            }
            return nil
        }() ?? logToOverride?.logStartDate
        
        let logEndDate: Date? = {
            if let logEndDateString = fromBody[Constant.Key.logEndDate.rawValue] as? String {
                return logEndDateString.formatISO8601IntoDate()
            }
            return nil
        }() ?? logToOverride?.logEndDate
        
        let logNote: String? = fromBody[Constant.Key.logNote.rawValue] as? String ?? logToOverride?.logNote
        
        let logUnitTypeId: Int? = fromBody[Constant.Key.logUnitTypeId.rawValue] as? Int ?? logToOverride?.logUnitTypeId
        
        let logNumberOfLogUnits: Double? = fromBody[Constant.Key.logNumberOfLogUnits.rawValue] as? Double ?? logToOverride?.logNumberOfLogUnits
        let logCreatedByReminderUUID: UUID? = UUID.fromString(forUUIDString: fromBody[Constant.Key.logCreatedByReminderUUID.rawValue] as? String) ?? logToOverride?.logCreatedByReminderUUID
        
        self.init(
            forLogId: logId,
            forLogUUID: logUUID,
            forUserId: userId,
            forLogActionTypeId: logActionTypeId,
            forLogCustomActionName: logCustomActionName,
            forLogStartDate: logStartDate,
            forLogEndDate: logEndDate,
            forLogNote: logNote,
            forLogUnitTypeId: logUnitTypeId,
            forLogNumberOfUnits: logNumberOfLogUnits,
            forCreatedByReminderUUID: logCreatedByReminderUUID,
            // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
            offlineModeComponents: nil
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
    
    /// If forNumberOfUnits or forLogUnitTypeId is nil, both are set to nil. The forLogUnitTypeId provided must be in the array of LogUnitTypes that are valid for this log's logActionTypeId.
    func changeLogUnit(forLogUnitTypeId: Int?, forLogNumberOfLogUnits: Double?) {
        guard let forLogUnitTypeId = forLogUnitTypeId, let forLogNumberOfLogUnits = forLogNumberOfLogUnits else {
            logNumberOfLogUnits = nil
            logUnitTypeId = nil
            return
        }
        
        let logUnitTypeIds = logActionType.associatedLogUnitTypes.map { $0.logUnitTypeId }
        
        guard logUnitTypeIds.contains(forLogUnitTypeId) else {
            logNumberOfLogUnits = nil
            logUnitTypeId = nil
            return
        }
        
        logNumberOfLogUnits = round(forLogNumberOfLogUnits * 100.0) / 100.0
        logUnitTypeId = forLogUnitTypeId
    }
    
    /// Returns true if any major property of the log matches the provided search text
    func matchesSearchText(_ searchText: String) -> Bool {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmed.isEmpty == false else { return true }
        
        if logActionType.readableValue.lowercased().contains(trimmed) { return true }
        if logCustomActionName.lowercased().contains(trimmed) { return true }
        if logActionType.convertToReadableName(customActionName: logCustomActionName, includeMatchingEmoji: true).lowercased().contains(trimmed) { return true }
        
        if logNote.lowercased().contains(trimmed) { return true }
        
        if let logUnitType = logUnitType, let num = logNumberOfLogUnits {
            if logUnitType.pluralReadableValueWithNumUnits(forLogNumberOfLogUnits: num)?.lowercased().contains(trimmed) ?? false { return true }
        }
        
        return false
    }
    
    /// Returns an array literal of the logs's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody(forDogUUID: UUID) -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.dogUUID.rawValue] = .string(forDogUUID.uuidString)
        body[Constant.Key.logId.rawValue] = .int(logId)
        body[Constant.Key.logUUID.rawValue] = .string(logUUID.uuidString)
        body[Constant.Key.logActionTypeId.rawValue] = .int(logActionTypeId)
        body[Constant.Key.logCustomActionName.rawValue] = .string(logCustomActionName)
        body[Constant.Key.logStartDate.rawValue] = .string(logStartDate.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.logEndDate.rawValue] = .string(logEndDate?.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.logNote.rawValue] = .string(logNote)
        body[Constant.Key.logUnitTypeId.rawValue] = .int(logUnitTypeId)
        body[Constant.Key.logNumberOfLogUnits.rawValue] = .double(logNumberOfLogUnits)
        body[Constant.Key.logCreatedByReminderUUID.rawValue] = .string(logCreatedByReminderUUID?.uuidString)
        return body
    }
}
