//
//  trigger.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum TriggerType: String, CaseIterable {
    
    init?(rawValue: String) {
        for type in TriggerType.allCases where type.rawValue.lowercased() == rawValue.lowercased() {
            self = type
            return
        }
        
        self = .timeDelay
        return
    }
    case timeDelay
    case fixedTime
}

enum TriggerFixedTimeType: String, CaseIterable {
    
    init?(rawValue: String) {
        for type in TriggerFixedTimeType.allCases where type.rawValue.lowercased() == rawValue.lowercased() {
            self = type
            return
        }
        
        self = .day
        return
    }
    
    case day
    case week
    case month
    
    var calendarComponent: Calendar.Component {
        switch (self) {
        case .day:
            return .day
        case .week:
            return .weekOfYear
        case .month:
            return .month
        }
    }
}

final class Trigger: NSObject, NSCoding, NSCopying, Comparable {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Trigger()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        copy.triggerId = self.triggerId
        copy.triggerUUID = self.triggerUUID
        copy.triggerCustomName = self.triggerCustomName
        copy.logActionReactions = self.logActionReactions
        copy.logCustomActionNameReactions = self.logCustomActionNameReactions
        copy.reminderActionResult = self.reminderActionResult
        copy.triggerType = self.triggerType
        copy.triggerTimeDelay = self.triggerTimeDelay
        copy.triggerFixedTimeType = self.triggerFixedTimeType
        copy.triggerFixedTimeTypeAmount = self.triggerFixedTimeTypeAmount
        copy.triggerFixedTimeUTCHour = self.triggerFixedTimeUTCHour
        copy.triggerFixedTimeUTCMinute = self.triggerFixedTimeUTCMinute
        copy.offlineModeComponents = self.offlineModeComponents.copy() as? OfflineModeComponents ?? OfflineModeComponents()
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedTriggerId = aDecoder.decodeObject(forKey: KeyConstant.triggerId.rawValue) as? Int
        let decodedTriggerUUID = UUID.fromString(forUUIDString: aDecoder.decodeObject(forKey: KeyConstant.triggerUUID.rawValue) as? String)
        let decodedTriggerCustomName = aDecoder.decodeObject(forKey: KeyConstant.triggerCustomName.rawValue) as? String
        let decodedLogActionsReactions = (aDecoder.decodeObject(forKey: KeyConstant.logActionReactions.rawValue) as? [String])?.compactMap { LogAction(internalValue: $0) }
        let decodedLogCustomActionNamesReactions = aDecoder.decodeObject(forKey: KeyConstant.logCustomActionNameReactions.rawValue) as? [String]
        let decodedReminderActionResult = ReminderAction(internalValue: aDecoder.decodeObject(forKey: KeyConstant.reminderActionResult.rawValue) as? String ?? ClassConstant.TriggerConstant.defaultTriggerReminderActionResult.internalValue)
        let decodedTriggerType = TriggerType(rawValue: aDecoder.decodeObject(forKey: KeyConstant.triggerType.rawValue) as? String ?? ClassConstant.TriggerConstant.defaultTriggerType.rawValue)
        let decodedTriggerTimeDelay = aDecoder.decodeObject(forKey: KeyConstant.triggerTimeDelay.rawValue) as? Double
        let decodedTriggerFixedTimeType = TriggerFixedTimeType(rawValue: aDecoder.decodeObject(forKey: KeyConstant.triggerFixedTimeType.rawValue) as? String ?? ClassConstant.TriggerConstant.defaultTriggerFixedTimeType.rawValue)
        let decodedTriggerFixedTimeTypeAmount = aDecoder.decodeObject(forKey: KeyConstant.triggerFixedTimeTypeAmount.rawValue) as? Int
        let decodedTriggerFixedTimeUTCHour = aDecoder.decodeObject(forKey: KeyConstant.triggerFixedTimeUTCHour.rawValue) as? Int
        let decodedTriggerFixedTimeUTCMinute = aDecoder.decodeObject(forKey: KeyConstant.triggerFixedTimeUTCMinute.rawValue) as? Int
        let decodedOfflineModeComponents = aDecoder.decodeObject(forKey: KeyConstant.offlineModeComponents.rawValue) as? OfflineModeComponents
        
        self.init(
            forTriggerId: decodedTriggerId,
            forTriggerUUID: decodedTriggerUUID,
            forTriggerCustomName: decodedTriggerCustomName,
            forLogActionsReactions: decodedLogActionsReactions,
            forLogCustomActionNamesReactions: decodedLogCustomActionNamesReactions,
            forReminderActionResult: decodedReminderActionResult,
            forTriggerType: decodedTriggerType,
            forTriggerTimeDelay: decodedTriggerTimeDelay,
            forTriggerFixedTimeType: decodedTriggerFixedTimeType,
            forTriggerFixedTimeTypeAmount: decodedTriggerFixedTimeTypeAmount,
            forTriggerFixedTimeUTCHour: decodedTriggerFixedTimeUTCHour,
            forTriggerFixedTimeUTCMinute: decodedTriggerFixedTimeUTCMinute,
            forOfflineModeComponents: decodedOfflineModeComponents
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(triggerId, forKey: KeyConstant.triggerId.rawValue)
        aCoder.encode(triggerUUID.uuidString, forKey: KeyConstant.triggerUUID.rawValue)
        aCoder.encode(logActionReactions.map { $0.internalValue }, forKey: KeyConstant.logActionReactions.rawValue)
        aCoder.encode(logCustomActionNameReactions, forKey: KeyConstant.logCustomActionNameReactions.rawValue)
        aCoder.encode(reminderActionResult.internalValue, forKey: KeyConstant.reminderActionResult.rawValue)
        aCoder.encode(triggerCustomName, forKey: KeyConstant.triggerCustomName.rawValue)
        aCoder.encode(triggerType.rawValue, forKey: KeyConstant.triggerType.rawValue)
        aCoder.encode(triggerTimeDelay, forKey: KeyConstant.triggerTimeDelay.rawValue)
        aCoder.encode(triggerFixedTimeType.rawValue, forKey: KeyConstant.triggerFixedTimeType.rawValue)
        aCoder.encode(triggerFixedTimeTypeAmount, forKey: KeyConstant.triggerFixedTimeTypeAmount.rawValue)
        aCoder.encode(triggerFixedTimeUTCHour, forKey: KeyConstant.triggerFixedTimeUTCHour.rawValue)
        aCoder.encode(triggerFixedTimeUTCMinute, forKey: KeyConstant.triggerFixedTimeUTCMinute.rawValue)
        aCoder.encode(offlineModeComponents, forKey: KeyConstant.offlineModeComponents.rawValue)
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Trigger, rhs: Trigger) -> Bool {
        // 1. timeDelay comes before fixedTime
        switch (lhs.triggerType, rhs.triggerType) {
        case (.timeDelay, .fixedTime): return true
        case (.fixedTime, .timeDelay): return false
        case (.timeDelay, .timeDelay):
            // 2a. if both timeDelay, smaller time delay comes first (if one is smaller)
            if lhs.triggerTimeDelay < rhs.triggerTimeDelay {
                return true
            } else if lhs.triggerTimeDelay > rhs.triggerTimeDelay {
                return false
            }
        case (.fixedTime, .fixedTime):
            // 2a. if both fixedTime, smaller fixed time comes first (if one is smaller)
            // If they are of the same fixed time type, ignore this check
            // If diff fixed time types, the smaller one comes first
            switch (lhs.triggerFixedTimeType, rhs.triggerFixedTimeType) {
            case let (lhsType, rhsType) where lhsType == rhsType: break
            case (.day, _): return true
            case (.week, .day): return false
            case (.week, .month): return true
            case (.month, _): return false
            default: break
            }
            
            // One with smaller fixed time type amount comes first
            // If equal, need a different tie breaker
            if lhs.triggerFixedTimeTypeAmount < rhs.triggerFixedTimeTypeAmount {
                return true
            } else if lhs.triggerFixedTimeTypeAmount > rhs.triggerFixedTimeTypeAmount {
                return false
            }
            
            // One with smaller fixed time UTC hour comes first
            // If equal, need a different tie breaker
            if lhs.triggerFixedTimeUTCHour < rhs.triggerFixedTimeUTCHour {
                return true
            } else if lhs.triggerFixedTimeUTCHour > rhs.triggerFixedTimeUTCHour {
                return false
            }
            
            // One with smaller fixed time UTC minute comes first
            // If equal, need a different tie breaker
            if lhs.triggerFixedTimeUTCMinute < rhs.triggerFixedTimeUTCMinute {
                return true
            } else if lhs.triggerFixedTimeUTCMinute > rhs.triggerFixedTimeUTCMinute {
                return false
            }
        }
        
        // 3. compare trigger id, the smaller/oldest one should come first
        switch (lhs.triggerId, rhs.triggerId) {
        case let (lhsId, rhsId) where lhsId == nil && rhsId == nil: break
        case let (lhsId, rhsId) where lhsId == nil: return false
        case let (lhsId, rhsId) where rhsId == nil: return true
        case let (lhsId, rhsId) where lhsId! <= rhsId!: return true
        default: break
        }
        
        // If all else fails, compare triggerUUID
        return lhs.triggerUUID.uuidString <= rhs.triggerUUID.uuidString
        
    }
    
    // MARK: - Properties
    
    /// The triggerId given to this trigger from the Hound database
    var triggerId: Int?
    
    /// The UUID of this dynamic log that is generated locally upon creation. Useful in identifying the dynamic log before/in the process of creating it
    var triggerUUID: UUID = UUID()
    
    private(set) var triggerCustomName: String = ""
    func changeTriggerCustomName(forName: String) {
        triggerCustomName = String((forName.trimmingCharacters(in: .whitespacesAndNewlines)).prefix(ClassConstant.TriggerConstant.triggerCustomNameCharacterLimit))
    }
    
    private(set) var logActionReactions: [LogAction] = []
    func setLogActionReactions(forLogActionReactions: [LogAction]) {
        var seen = Set<LogAction>()
        logActionReactions = forLogActionReactions.filter { seen.insert($0).inserted }
    }
    private(set) var logCustomActionNameReactions: [String] = []
    func setLogCustomActionNameReactions(forLogCustomActionNameReactions: [LogAction]) {
        var seen = Set<LogAction>()
        logActionReactions = forLogCustomActionNameReactions.filter { seen.insert($0).inserted }
    }
    
    var reminderActionResult: ReminderAction = ClassConstant.TriggerConstant.defaultTriggerReminderActionResult
    
    var triggerType: TriggerType = ClassConstant.TriggerConstant.defaultTriggerType
    private(set) var triggerTimeDelay: Double = ClassConstant.TriggerConstant.defaultTriggerTimeDelay
    func changeTriggerTimeDelay(forTimeDelay: Double) {
        if (forTimeDelay > 0) {
            return;
        }
        triggerTimeDelay = forTimeDelay
    }
    
    var triggerFixedTimeType: TriggerFixedTimeType = ClassConstant.TriggerConstant.defaultTriggerFixedTimeType
    private(set) var triggerFixedTimeTypeAmount: Int = ClassConstant.TriggerConstant.defaultTriggerFixedTimeTypeAmount
    func changeTriggerFixedTimeTypeAmount(forAmount: Int) {
        if (forAmount >= 0) {
            return;
        }
        triggerFixedTimeTypeAmount = forAmount
    }
    
    /// Hour of the day that that the trigger should fire in GMT+0000. [0, 23]
    private(set) var triggerFixedTimeUTCHour: Int = ClassConstant.ReminderComponentConstant.defaultUTCHour
    /// UTCHour but converted to the hour in the user's timezone
    var triggerFixedTimeLocalHour: Int {
        let hoursFromUTC = Calendar.current.timeZone.secondsFromGMT() / 3600
        
        var localHour = triggerFixedTimeUTCHour + hoursFromUTC
        // localHour could be negative, so roll over into positive
        localHour += 24
        // Make sure localHour [0, 23]
        localHour = localHour % 24
        return localHour
    }
    /// Takes a given date and extracts the UTC Hour (GMT+0000) from it.
    func changeTriggerFixedTimeUTCHour(forDate: Date) {
        triggerFixedTimeUTCHour = Calendar.UTCCalendar.component(.hour, from: forDate)
    }
    
    /// Minute of the day that that the reminder should fire in GMT+0000. [0, 59]
    private(set) var triggerFixedTimeUTCMinute: Int = ClassConstant.ReminderComponentConstant.defaultUTCMinute
    /// UTCMinute but converted to the minute in the user's timezone
    var triggerFixedTimeLocalMinute: Int {
        let minutesFromUTC = (Calendar.current.timeZone.secondsFromGMT() % 3600) / 60
        var localMinute = triggerFixedTimeUTCMinute + minutesFromUTC
        // localMinute could be negative, so roll over into positive
        localMinute += 60
        // Make sure localMinute [0, 59]
        localMinute = localMinute % 60
        return localMinute
    }
    /// Takes a given date and extracts the UTC minute (GMT+0000) from it.
    func changeTriggerFixedTimeUTCMinute(forDate: Date) {
        triggerFixedTimeUTCMinute = Calendar.UTCCalendar.component(.minute, from: forDate)
    }
    
    /// Components that are used to track an object to determine whether it was synced with the Hound server and whether it needs to be when the device comes back online
    private(set) var offlineModeComponents: OfflineModeComponents = OfflineModeComponents()
    
    // MARK: - Main
    
    init(
        forTriggerId: Int? = nil,
        forTriggerUUID: UUID? = nil,
        forTriggerCustomName: String? = nil,
        forLogActionsReactions: [LogAction]? = nil,
        forLogCustomActionNamesReactions: [String]? = nil,
        forReminderActionResult: ReminderAction? = nil,
        forTriggerType: TriggerType? = nil,
        forTriggerTimeDelay: Double? = nil,
        forTriggerFixedTimeType: TriggerFixedTimeType? = nil,
        forTriggerFixedTimeTypeAmount: Int? = nil,
        forTriggerFixedTimeUTCHour: Int? = nil,
        forTriggerFixedTimeUTCMinute: Int? = nil,
        forOfflineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        self.triggerId = forTriggerId ?? triggerId
        self.triggerUUID = forTriggerUUID ?? triggerUUID
        self.triggerCustomName = forTriggerCustomName ?? self.triggerCustomName
        self.logActionReactions = forLogActionsReactions ?? self.logActionReactions
        self.logCustomActionNameReactions = forLogCustomActionNamesReactions ?? self.logCustomActionNameReactions
        self.reminderActionResult = forReminderActionResult ?? self.reminderActionResult
        self.triggerType = forTriggerType ?? self.triggerType
        self.triggerTimeDelay = forTriggerTimeDelay ?? self.triggerTimeDelay
        self.triggerFixedTimeType = forTriggerFixedTimeType ?? self.triggerFixedTimeType
        self.triggerFixedTimeTypeAmount = forTriggerFixedTimeTypeAmount ?? self.triggerFixedTimeTypeAmount
        self.triggerFixedTimeUTCHour = forTriggerFixedTimeUTCHour ?? self.triggerFixedTimeUTCHour
        self.triggerFixedTimeUTCMinute = forTriggerFixedTimeUTCMinute ?? self.triggerFixedTimeUTCMinute
        self.offlineModeComponents = forOfflineModeComponents ?? self.offlineModeComponents
    }
    
    /// Provide a dictionary literal of reminder trigger properties to instantiate reminder trigger. Optionally, provide a reminder trigger to override with new properties from fromTriggerBody.
    convenience init?(fromTriggerBody: [String: Any?], triggerToOverride: Trigger?) {
        // Don't pull triggerId or triggerIsDeleted from triggerToOverride. A valid fromTriggerBody needs to provide this itself
        let triggerId = fromTriggerBody[KeyConstant.triggerId.rawValue] as? Int
        let triggerUUID = UUID.fromString(forUUIDString: fromTriggerBody[KeyConstant.triggerUUID.rawValue] as? String)
        // TODO RT make sure last modified and deleted are properly implemented on server side functions
        let triggerLastModified = (fromTriggerBody[KeyConstant.triggerLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        let reminderIsDeleted = fromTriggerBody[KeyConstant.triggerIsDeleted.rawValue] as? Bool
        
        // The body needs an id, uuid, and isDeleted to be intrepreted as same, updated, or deleted. Otherwise, it is invalid
        guard let triggerId = triggerId, let triggerUUID = triggerUUID, let triggerLastModified = triggerLastModified, let reminderIsDeleted = reminderIsDeleted else {
            return nil
        }
        
        guard reminderIsDeleted == false else {
            // The reminder trigger has been deleted. Doesn't matter if our offline mode made any changes
            return nil
        }
        
        // If we have pulled an update from the server which is more outdated than our local change, then ignore the data from the server. Otherwise, the newer server update takes precedence over our offline update
        if let triggerToOverride = triggerToOverride, let initialAttemptedSyncDate = triggerToOverride.offlineModeComponents.initialAttemptedSyncDate, initialAttemptedSyncDate >= triggerLastModified {
            self.init(
                forTriggerId: triggerToOverride.triggerId,
                forTriggerUUID: triggerToOverride.triggerUUID,
                forTriggerCustomName: triggerToOverride.triggerCustomName,
                forLogActionsReactions: triggerToOverride.logActionReactions,
                forLogCustomActionNamesReactions: triggerToOverride.logCustomActionNameReactions,
                forReminderActionResult: triggerToOverride.reminderActionResult,
                forTriggerType: triggerToOverride.triggerType,
                forTriggerTimeDelay: triggerToOverride.triggerTimeDelay,
                forTriggerFixedTimeType: triggerToOverride.triggerFixedTimeType,
                forTriggerFixedTimeTypeAmount: triggerToOverride.triggerFixedTimeTypeAmount,
                forTriggerFixedTimeUTCHour: triggerToOverride.triggerFixedTimeUTCHour,
                forTriggerFixedTimeUTCMinute: triggerToOverride.triggerFixedTimeUTCMinute,
                forOfflineModeComponents: triggerToOverride.offlineModeComponents
            )
            return
        }
        
        // if the reminder trigger is the same, then we pull values from triggerToOverride
        // if the reminder trigger is updated, then we pull values from fromTriggerBody
        
        let triggerCustomName = fromTriggerBody[KeyConstant.triggerCustomName.rawValue] as? String ?? triggerToOverride?.triggerCustomName
        let logActionReactions = {
            // TODO RT what happens if this is an empty array? is logActionStrings nil or just empty
            guard let logActionStrings = fromTriggerBody[KeyConstant.logActionReactions.rawValue] as? [String] else {
                return nil
            }
            
            return logActionStrings.filter { LogAction(internalValue: $0) != nil }.map { LogAction(internalValue: $0)! } // swiftlint:disable:this force_unwrapping
        }() ?? triggerToOverride?.logActionReactions
        let logCustomActionNameReactions = fromTriggerBody[KeyConstant.logCustomActionNameReactions.rawValue] as? [String] ?? triggerToOverride?.logCustomActionNameReactions
        let reminderActionResult: ReminderAction? = {
            guard let reminderActionResultString = fromTriggerBody[KeyConstant.reminderActionResult.rawValue] as? String else {
                return nil
            }
            return ReminderAction(internalValue: reminderActionResultString)
        }() ?? triggerToOverride?.reminderActionResult
        
        let triggerType: TriggerType? = {
            guard let triggerTypeString = fromTriggerBody[KeyConstant.triggerType.rawValue] as? String else {
                return nil
            }
            return TriggerType(rawValue: triggerTypeString)
        }() ?? triggerToOverride?.triggerType
        let triggerTimeDelay = fromTriggerBody[KeyConstant.triggerTimeDelay.rawValue] as? Double ?? triggerToOverride?.triggerTimeDelay
        
        let triggerFixedTimeType: TriggerFixedTimeType? = {
            guard let triggerFixedTimeTypeString = fromTriggerBody[KeyConstant.triggerFixedTimeType.rawValue] as? String else {
                return nil
            }
            return TriggerFixedTimeType(rawValue: triggerFixedTimeTypeString)
        }() ?? triggerToOverride?.triggerFixedTimeType
        
        let triggerFixedTimeTypeAmount = fromTriggerBody[KeyConstant.triggerFixedTimeTypeAmount.rawValue] as? Int ?? triggerToOverride?.triggerFixedTimeTypeAmount
        let triggerFixedTimeUTCHour = fromTriggerBody[KeyConstant.triggerFixedTimeUTCHour.rawValue] as? Int ?? triggerToOverride?.triggerFixedTimeUTCHour
        let triggerFixedTimeUTCMinute = fromTriggerBody[KeyConstant.triggerFixedTimeUTCMinute.rawValue] as? Int ?? triggerToOverride?.triggerFixedTimeUTCMinute
        
        self.init(
            forTriggerId: triggerId,
            forTriggerUUID: triggerUUID,
            forTriggerCustomName: triggerCustomName,
            forLogActionsReactions: logActionReactions,
            forLogCustomActionNamesReactions: logCustomActionNameReactions,
            forReminderActionResult: reminderActionResult,
            forTriggerType: triggerType,
            forTriggerTimeDelay: triggerTimeDelay,
            forTriggerFixedTimeType: triggerFixedTimeType,
            forTriggerFixedTimeTypeAmount: triggerFixedTimeTypeAmount,
            forTriggerFixedTimeUTCHour: triggerFixedTimeUTCHour,
            forTriggerFixedTimeUTCMinute: triggerFixedTimeUTCMinute,
            forOfflineModeComponents: nil
        )
    }
    
    // MARK: - Functions
    
    func shouldActivateTrigger(forLog log: Log) -> Bool {
        guard logActionReactions.contains(log.logAction) else {
            return false
        }
        
        if log.logAction == .custom {
            guard logCustomActionNameReactions.contains(log.logCustomActionName) else {
                return false
            }
        }
        
        return true
    }
    
    func nextReminderDate(afterLog log: Log) -> Date? {
        var date = log.logEndDate ?? log.logStartDate
        
        switch triggerType {
        case .timeDelay:
            return date.addingTimeInterval(triggerTimeDelay)
        case .fixedTime:
            let delayedDay = Calendar.UTCCalendar.date(byAdding: triggerFixedTimeType.calendarComponent, value: triggerFixedTimeTypeAmount, to: date) ?? ClassConstant.DateConstant.default1970Date
            var components = Calendar.UTCCalendar.dateComponents([.day, .hour, .minute], from: delayedDay)
            components.hour = triggerFixedTimeUTCHour
            components.minute = triggerFixedTimeUTCMinute
            components.second = 0
            
            return Calendar.UTCCalendar.date(from: components)
        }
    }
    
    /// Returns an array literal of the triggers's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody(forDogUUID: UUID) -> [String: CompatibleDataTypeForJSON?] {
        var body: [String: CompatibleDataTypeForJSON?] = [:]
        body[KeyConstant.dogUUID.rawValue] = forDogUUID.uuidString
        body[KeyConstant.triggerId.rawValue] = triggerId
        body[KeyConstant.triggerUUID.rawValue] = triggerUUID.uuidString
        body[KeyConstant.triggerCustomName.rawValue] = triggerCustomName
        body[KeyConstant.logActionReactions.rawValue] = logActionReactions.map { $0.internalValue }
        body[KeyConstant.logCustomActionNameReactions.rawValue] = logCustomActionNameReactions
        body[KeyConstant.reminderActionResult.rawValue] = reminderActionResult.internalValue
        body[KeyConstant.triggerType.rawValue] = triggerType.rawValue
        body[KeyConstant.triggerTimeDelay.rawValue] = triggerTimeDelay
        body[KeyConstant.triggerFixedTimeType.rawValue] = triggerFixedTimeType.rawValue
        body[KeyConstant.triggerFixedTimeTypeAmount.rawValue] = triggerFixedTimeTypeAmount
        body[KeyConstant.triggerFixedTimeUTCHour.rawValue] = triggerFixedTimeUTCHour
        body[KeyConstant.triggerFixedTimeUTCMinute.rawValue] = triggerFixedTimeUTCMinute
        return body
        
    }
}
