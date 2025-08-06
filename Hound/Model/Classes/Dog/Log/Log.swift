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
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        copy.logId = self.logId
        copy.logUUID = self.logUUID
        copy.logCreated = self.logCreated
        copy.logCreatedBy = self.logCreatedBy
        copy.logLastModified = self.logLastModified
        copy.logLastModifiedBy = self.logLastModifiedBy
        copy.logActionTypeId = self.logActionTypeId
        copy.storedLogCustomActionName = self.logCustomActionName
        copy.logStartDate = self.logStartDate
        copy.logEndDate = self.logEndDate
        copy.storedLogNote = self.logNote
        copy.logUnitTypeId = self.logUnitTypeId
        copy.logNumberOfLogUnits = self.logNumberOfLogUnits
        copy.logCreatedByReminderUUID = self.logCreatedByReminderUUID
        copy.offlineModeComponents = self.offlineModeComponents.copy() as? OfflineModeComponents ?? OfflineModeComponents()
        copy.likedByUserIds = self.likedByUserIds
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedLogId: Int? = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logId.rawValue)
        let decodedLogUUID: UUID? = UUID.fromString(UUIDString: aDecoder.decodeOptionalString(forKey: Constant.Key.logUUID.rawValue))
        let decodedLogCreated: Date? = (aDecoder.decodeOptionalString(forKey: Constant.Key.logCreated.rawValue)?.formatISO8601IntoDate())
        let decodedLogCreatedBy: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.logCreatedBy.rawValue)
        let decodedLogLastModified: Date? = (aDecoder.decodeOptionalString(forKey: Constant.Key.logLastModified.rawValue)?.formatISO8601IntoDate())
        let decodedLogLastModifiedBy: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.logLastModifiedBy.rawValue)
        let decodedLogActionTypeId: Int = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logActionTypeId.rawValue) ?? Constant.Class.Log.defaultLogActionTypeId
        let decodedLogCustomActionName: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.logCustomActionName.rawValue)
        let decodedLogStartDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.logStartDate.rawValue)
        let decodedLogEndDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.logEndDate.rawValue)
        let decodedLogNote: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.logNote.rawValue)
        let decodedLogUnitTypeId: Int? = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logUnitTypeId.rawValue)
        let decodedLogNumberOfLogUnits: Double? = aDecoder.decodeOptionalDouble(forKey: Constant.Key.logNumberOfLogUnits.rawValue)
        let decodedLogCreatedByReminderUUID: UUID? = UUID.fromString(UUIDString: aDecoder.decodeOptionalObject(forKey: Constant.Key.logCreatedByReminderUUID.rawValue))
        let decodedLikedByUserIds: [String]? = aDecoder.decodeOptionalObject(forKey: Constant.Key.logLikedByUserIds.rawValue)
        let decodedOfflineModeComponents: OfflineModeComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.offlineModeComponents.rawValue)
        
        self.init(
            logId: decodedLogId,
            logUUID: decodedLogUUID,
            logCreated: decodedLogCreated,
            logCreatedBy: decodedLogCreatedBy,
            logLastModified: decodedLogLastModified,
            logLastModifiedBy: decodedLogLastModifiedBy,
            logActionTypeId: decodedLogActionTypeId,
            logCustomActionName: decodedLogCustomActionName,
            logStartDate: decodedLogStartDate,
            logEndDate: decodedLogEndDate,
            logNote: decodedLogNote,
            logUnitTypeId: decodedLogUnitTypeId,
            logNumberOfUnits: decodedLogNumberOfLogUnits,
            logCreatedByReminderUUID: decodedLogCreatedByReminderUUID,
            likedByUserIds: Set(decodedLikedByUserIds ?? []),
            offlineModeComponents: decodedOfflineModeComponents
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        if let logId = logId {
            aCoder.encode(logId, forKey: Constant.Key.logId.rawValue)
        }
        aCoder.encode(logUUID.uuidString, forKey: Constant.Key.logUUID.rawValue)
        aCoder.encode(logCreated.ISO8601FormatWithFractionalSeconds(), forKey: Constant.Key.logCreated.rawValue)
        aCoder.encode(logCreatedBy, forKey: Constant.Key.logCreatedBy.rawValue)
        if let logLastModified = logLastModified {
            aCoder.encode(logLastModified.ISO8601FormatWithFractionalSeconds(), forKey: Constant.Key.logLastModified.rawValue)
        }
        if let logLastModifiedBy = logLastModifiedBy {
            aCoder.encode(logLastModifiedBy, forKey: Constant.Key.logLastModifiedBy.rawValue)
        }
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
        aCoder.encode(Array(likedByUserIds), forKey: Constant.Key.logLikedByUserIds.rawValue)
        aCoder.encode(offlineModeComponents, forKey: Constant.Key.offlineModeComponents.rawValue)
    }
    
    // MARK: - Properties
    
    /// The logId given to this log from the Hound database
    var logId: Int?
    
    /// The UUID of this log that is generated locally upon creation. Useful in identifying the log before/in the process of creating it
    private(set) var logUUID: UUID = UUID()
    
    private(set) var logCreated: Date = Date()
    private(set) var logCreatedBy: String = Constant.Class.Log.defaultUserId
    private(set) var logLastModified: Date?
    private(set) var logLastModifiedBy: String?
    
    var logActionTypeId: Int = Constant.Class.Log.defaultLogActionTypeId {
        didSet {
            // Check to see if logUnitTypeId are compatible with the new logActionTypeId
            let logUnitTypeIds = LogActionType.find(logActionTypeId: logActionTypeId).associatedLogUnitTypes.map { $0.logUnitTypeId }
            
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
        return LogActionType.find(logActionTypeId: logActionTypeId)
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
    /// logStartDate takes precendence over logEndDate. Therefore, if the times overlap incorrectly, i.e. logStartDate is after logEndDate, then logStartDate is set its value, then logEndDate is adjusted so that it is later than logStartDate.
    func setLogDate(logStartDate: Date, logEndDate: Date?) {
        self.logStartDate = logStartDate
        
        if let logEndDate = logEndDate {
            // If logStartDate is after logEndDate, that is incorrect. Therefore, disregard it
            self.logEndDate = logStartDate >= logEndDate ? nil : logEndDate
        }
        else {
            self.logEndDate = nil
        }
    }
    
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
        return LogUnitType.find(logUnitTypeId: logUnitTypeId)
    }
    private(set) var logNumberOfLogUnits: Double?
    /// If numberOfUnits or logUnitTypeId is nil, both are set to nil. The logUnitTypeId provided must be in the array of LogUnitTypes that are valid for this log's logActionTypeId.
    func setLogUnit(logUnitTypeId: Int?, logNumberOfLogUnits: Double?) {
        guard let logUnitTypeId = logUnitTypeId, let logNumberOfLogUnits = logNumberOfLogUnits else {
            self.logNumberOfLogUnits = nil
            self.logUnitTypeId = nil
            return
        }
        
        let logUnitTypeIds = logActionType.associatedLogUnitTypes.map { $0.logUnitTypeId }
        
        guard logUnitTypeIds.contains(logUnitTypeId) else {
            self.logNumberOfLogUnits = nil
            self.logUnitTypeId = nil
            return
        }
        
        self.logNumberOfLogUnits = round(logNumberOfLogUnits * 100.0) / 100.0
        self.logUnitTypeId = logUnitTypeId
    }
    
    private(set) var logCreatedByReminderUUID: UUID?

    private(set) var likedByUserIds: Set<String> = []
    func setLogLike(_ liked: Bool) {
        if liked {
            likedByUserIds.insert(Constant.Class.Log.defaultUserId)
        }
        else {
            likedByUserIds.remove(Constant.Class.Log.defaultUserId)
        }
    }
    func setLogLikes(_ userIds: Set<String>) {
        likedByUserIds = userIds
    }


    /// Components that are used to track an object to determine whether it was synced with the Hound server and whether it needs to be when the device comes back online
    private(set) var offlineModeComponents: OfflineModeComponents = OfflineModeComponents()
    
    // MARK: - Main
    
    init(
        logId: Int? = nil,
        logUUID: UUID? = nil,
        logCreated: Date? = nil,
        logCreatedBy: String? = nil,
        logLastModified: Date? = nil,
        logLastModifiedBy: String? = nil,
        logActionTypeId: Int? = nil,
        logCustomActionName: String? = nil,
        logStartDate: Date? = nil,
        logEndDate: Date? = nil,
        logNote: String? = nil,
        logUnitTypeId: Int? = nil,
        logNumberOfUnits: Double? = nil,
        logCreatedByReminderUUID: UUID? = nil,
        likedByUserIds: Set<String>? = nil,
        offlineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        self.logId = logId ?? self.logId
        self.logUUID = logUUID ?? self.logUUID
        self.logCreated = logCreated ?? self.logCreated
        self.logCreatedBy = logCreatedBy ?? self.logCreatedBy
        self.logLastModified = logLastModified ?? self.logLastModified
        self.logLastModifiedBy = logLastModifiedBy ?? self.logLastModifiedBy
        self.logActionTypeId = logActionTypeId ?? self.logActionTypeId
        self.logCustomActionName = logCustomActionName ?? self.logCustomActionName
        self.logStartDate = logStartDate ?? self.logStartDate
        self.logEndDate = logEndDate ?? self.logEndDate
        self.logNote = logNote ?? self.logNote
        self.setLogUnit(logUnitTypeId: logUnitTypeId, logNumberOfLogUnits: logNumberOfUnits)
        self.logCreatedByReminderUUID = logCreatedByReminderUUID ?? logCreatedByReminderUUID
        self.likedByUserIds = likedByUserIds ?? self.likedByUserIds
        self.offlineModeComponents = offlineModeComponents ?? self.offlineModeComponents
    }
    
    /// Provide a dictionary literal of log properties to instantiate log. Optionally, provide a log to override with new properties from fromBody.
    convenience init?(fromBody: JSONResponseBody, logToOverride: Log?) {
        // Don't pull logId or logIsDeleted from logToOverride. A valid fromBody needs to provide this itself
        let logId: Int? = fromBody[Constant.Key.logId.rawValue] as? Int
        let logUUID: UUID? = UUID.fromString(UUIDString: fromBody[Constant.Key.logUUID.rawValue] as? String)
        let logCreated: Date? = (fromBody[Constant.Key.logCreated.rawValue] as? String)?.formatISO8601IntoDate()
        let logIsDeleted: Bool? = fromBody[Constant.Key.logIsDeleted.rawValue] as? Bool
        
        guard let logId = logId, let logUUID = logUUID, let logCreated = logCreated, let logIsDeleted = logIsDeleted else {
            return nil
        }
        
        guard logIsDeleted == false else {
            return nil
        }
        
        let logLastModified: Date? = (fromBody[Constant.Key.logLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        
        // If we have pulled an update from the server which is more outdated than our local change, then ignore the data from the server. Otherwise, the newer server update takes precedence over our offline update
        if let logToOverride = logToOverride, let initialAttemptedSyncDate = logToOverride.offlineModeComponents.initialAttemptedSyncDate, initialAttemptedSyncDate >= logLastModified ?? logCreated {
            self.init(
                    logId: logToOverride.logId,
                    logUUID: logToOverride.logUUID,
                    logCreated: logToOverride.logCreated,
                    logCreatedBy: logToOverride.logCreatedBy,
                    logLastModified: logToOverride.logLastModified,
                    logLastModifiedBy: logToOverride.logLastModifiedBy,
                    logActionTypeId: logToOverride.logActionTypeId,
                    logCustomActionName: logToOverride.logCustomActionName,
                    logStartDate: logToOverride.logStartDate,
                    logEndDate: logToOverride.logEndDate,
                    logNote: logToOverride.logNote,
                    logUnitTypeId: logToOverride.logUnitTypeId,
                    logNumberOfUnits: logToOverride.logNumberOfLogUnits,
                    logCreatedByReminderUUID: logToOverride.logCreatedByReminderUUID,
                    likedByUserIds: logToOverride.likedByUserIds,
                    offlineModeComponents: logToOverride.offlineModeComponents
                )
            return
        }
        
        // if the log is the same, then we pull values from logToOverride
        // if the log is updated, then we pull values from fromBody
        let logCreatedBy = fromBody[Constant.Key.logCreatedBy.rawValue] as? String ?? logToOverride?.logCreatedBy
        let logLastModifiedBy: String? = fromBody[Constant.Key.logLastModifiedBy.rawValue] as? String ?? logToOverride?.logLastModifiedBy
        
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
        let logCreatedByReminderUUID: UUID? = UUID.fromString(UUIDString: fromBody[Constant.Key.logCreatedByReminderUUID.rawValue] as? String) ?? logToOverride?.logCreatedByReminderUUID

        let likedByUserIds: Set<String>? = {
            if let arr = fromBody[Constant.Key.logLikedByUserIds.rawValue] as? [String] {
                return Set(arr)
            }
            return logToOverride?.likedByUserIds
        }()
        
        self.init(
            logId: logId,
            logUUID: logUUID,
            logCreated: logCreated,
            logCreatedBy: logCreatedBy,
            logLastModified: logLastModified,
            logLastModifiedBy: logLastModifiedBy,
            logActionTypeId: logActionTypeId,
            logCustomActionName: logCustomActionName,
            logStartDate: logStartDate,
            logEndDate: logEndDate,
            logNote: logNote,
            logUnitTypeId: logUnitTypeId,
            logNumberOfUnits: logNumberOfLogUnits,
            logCreatedByReminderUUID: logCreatedByReminderUUID,
            likedByUserIds: likedByUserIds,
            // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
            offlineModeComponents: nil
        )
    }
    
    // MARK: - Functions
    
    /// Returns true if any major property of the log matches the provided search text
    func matchesSearchText(_ searchText: String) -> Bool {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmed.isEmpty == false else { return true }
        
        if logActionType.readableValue.lowercased().contains(trimmed) { return true }
        if logCustomActionName.lowercased().contains(trimmed) { return true }
        if logActionType.convertToReadableName(customActionName: logCustomActionName, includeMatchingEmoji: true).lowercased().contains(trimmed) { return true }
        
        if logNote.lowercased().contains(trimmed) { return true }
        
        if let logUnitType = logUnitType, let num = logNumberOfLogUnits {
            if logUnitType.pluralReadableValueWithNumUnits(logNumberOfLogUnits: num)?.lowercased().contains(trimmed) ?? false { return true }
        }
        
        return false
    }
    
    /// Returns an array literal of the logs's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody(dogUUID: UUID) -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.dogUUID.rawValue] = .string(dogUUID.uuidString)
        body[Constant.Key.logId.rawValue] = .int(logId)
        body[Constant.Key.logUUID.rawValue] = .string(logUUID.uuidString)
        body[Constant.Key.logCreated.rawValue] = .string(logCreated.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.logCreatedBy.rawValue] = .string(logCreatedBy)
        body[Constant.Key.logLastModified.rawValue] = .string(logLastModified?.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.logLastModifiedBy.rawValue] = .string(logLastModifiedBy)
        body[Constant.Key.logActionTypeId.rawValue] = .int(logActionTypeId)
        body[Constant.Key.logCustomActionName.rawValue] = .string(logCustomActionName)
        body[Constant.Key.logStartDate.rawValue] = .string(logStartDate.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.logEndDate.rawValue] = .string(logEndDate?.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.logNote.rawValue] = .string(logNote)
        body[Constant.Key.logUnitTypeId.rawValue] = .int(logUnitTypeId)
        body[Constant.Key.logNumberOfLogUnits.rawValue] = .double(logNumberOfLogUnits)
        body[Constant.Key.logCreatedByReminderUUID.rawValue] = .string(logCreatedByReminderUUID?.uuidString)
        // don't send logLikedByUserIds because that is handled w/ a separate api call
        // body[Constant.Key.logLikedByUserIds.rawValue] = .array(likedByUserIds.map { .string($0) })
        return body
    }
}
