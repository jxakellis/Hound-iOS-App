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
        switch self {
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
        for logActionReaction in logActionReactions {
            if let logActionReactionCopy = logActionReaction.copy() as? TriggerLogReaction {
                copy.logActionReactions.append(logActionReactionCopy)
            }
        }
        copy.reminderActionResult = self.reminderActionResult.copy() as? TriggerReminderResult ?? TriggerReminderResult()
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
        let decodedTriggerId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.triggerId.rawValue)
        let decodedTriggerUUID = UUID.fromString(forUUIDString: aDecoder.decodeOptionalString(forKey: KeyConstant.triggerUUID.rawValue))
        let decodedLogActionReactions: [TriggerLogReaction]? = aDecoder.decodeOptionalObject(forKey: KeyConstant.reactionLogActions.rawValue)
        let decodedReminderActionResult: TriggerReminderResult? = aDecoder.decodeOptionalObject(forKey: KeyConstant.reminderActionResult.rawValue)
        let decodedTriggerType = TriggerType(rawValue: aDecoder.decodeOptionalString(forKey: KeyConstant.triggerType.rawValue) ?? ClassConstant.TriggerConstant.defaultTriggerType.rawValue)
        let decodedTriggerTimeDelay = aDecoder.decodeOptionalDouble(forKey: KeyConstant.triggerTimeDelay.rawValue)
        let decodedTriggerFixedTimeType = TriggerFixedTimeType(rawValue: aDecoder.decodeOptionalString(forKey: KeyConstant.triggerFixedTimeType.rawValue) ?? ClassConstant.TriggerConstant.defaultTriggerFixedTimeType.rawValue)
        let decodedTriggerFixedTimeTypeAmount = aDecoder.decodeOptionalInteger(forKey: KeyConstant.triggerFixedTimeTypeAmount.rawValue)
        let decodedTriggerFixedTimeUTCHour = aDecoder.decodeOptionalInteger(forKey: KeyConstant.triggerFixedTimeUTCHour.rawValue)
        let decodedTriggerFixedTimeUTCMinute = aDecoder.decodeOptionalInteger(forKey: KeyConstant.triggerFixedTimeUTCMinute.rawValue)
        let decodedOfflineModeComponents: OfflineModeComponents? = aDecoder.decodeOptionalObject(forKey: KeyConstant.offlineModeComponents.rawValue)
        
        self.init(
            forTriggerId: decodedTriggerId,
            forTriggerUUID: decodedTriggerUUID,
            forLogActionReactions: decodedLogActionReactions,
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
        aCoder.encode(logActionReactions, forKey: KeyConstant.reactionLogActions.rawValue)
        aCoder.encode(reminderActionResult, forKey: KeyConstant.reminderActionResult.rawValue)
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
            }
            else if lhs.triggerTimeDelay > rhs.triggerTimeDelay {
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
            }
            else if lhs.triggerFixedTimeTypeAmount > rhs.triggerFixedTimeTypeAmount {
                return false
            }
            
            // One with smaller fixed time UTC hour comes first
            // If equal, need a different tie breaker
            if lhs.triggerFixedTimeUTCHour < rhs.triggerFixedTimeUTCHour {
                return true
            }
            else if lhs.triggerFixedTimeUTCHour > rhs.triggerFixedTimeUTCHour {
                return false
            }
            
            // One with smaller fixed time UTC minute comes first
            // If equal, need a different tie breaker
            if lhs.triggerFixedTimeUTCMinute < rhs.triggerFixedTimeUTCMinute {
                return true
            }
            else if lhs.triggerFixedTimeUTCMinute > rhs.triggerFixedTimeUTCMinute {
                return false
            }
        }
        
        // 3. compare trigger id, the smaller/oldest one should come first
        switch (lhs.triggerId, rhs.triggerId) {
        case let (lhsId, rhsId) where lhsId == nil && rhsId == nil: break
        case let (lhsId, _) where lhsId == nil: return false
        case let (_, rhsId) where rhsId == nil: return true
        case let (lhsId, rhsId) where lhsId! <= rhsId!: return true // swiftlint:disable:this force_unwrapping
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
    
    private(set) var logActionReactions: [TriggerLogReaction] = []
    func setLogActionReactions(forLogActionReactions: [TriggerLogReaction]) {
        var seen = Set<String>()
        logActionReactions = forLogActionReactions.filter { reaction in
            let identifier = "\(reaction.logActionTypeId)-\(reaction.logCustomActionName)"
            return seen.insert(identifier).inserted
        }
    }
    
    var reminderActionResult: TriggerReminderResult = TriggerReminderResult()
    
    var triggerType: TriggerType = ClassConstant.TriggerConstant.defaultTriggerType
    private(set) var triggerTimeDelay: Double = ClassConstant.TriggerConstant.defaultTriggerTimeDelay
    func changeTriggerTimeDelay(forTimeDelay: Double) {
        if forTimeDelay > 0 { return }
        triggerTimeDelay = forTimeDelay
    }
    
    /// triggerFixedTimeType isn't used currently. leave as its default of .day
    private var triggerFixedTimeType: TriggerFixedTimeType = ClassConstant.TriggerConstant.defaultTriggerFixedTimeType
    private(set) var triggerFixedTimeTypeAmount: Int = ClassConstant.TriggerConstant.defaultTriggerFixedTimeTypeAmount
    func changeTriggerFixedTimeTypeAmount(forAmount: Int) {
        if forAmount >= 0 { return }
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
        forLogActionReactions: [TriggerLogReaction]? = nil,
        forReminderActionResult: TriggerReminderResult? = nil,
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
        self.logActionReactions = forLogActionReactions ?? self.logActionReactions
        self.reminderActionResult = forReminderActionResult ?? self.reminderActionResult
        self.triggerType = forTriggerType ?? self.triggerType
        self.triggerTimeDelay = forTriggerTimeDelay ?? self.triggerTimeDelay
        self.triggerFixedTimeType = forTriggerFixedTimeType ?? self.triggerFixedTimeType
        self.triggerFixedTimeTypeAmount = forTriggerFixedTimeTypeAmount ?? self.triggerFixedTimeTypeAmount
        self.triggerFixedTimeUTCHour = forTriggerFixedTimeUTCHour ?? self.triggerFixedTimeUTCHour
        self.triggerFixedTimeUTCMinute = forTriggerFixedTimeUTCMinute ?? self.triggerFixedTimeUTCMinute
        self.offlineModeComponents = forOfflineModeComponents ?? self.offlineModeComponents
    }
    
    /// Provide a dictionary literal of reminder trigger properties to instantiate reminder trigger. Optionally, provide a reminder trigger to override with new properties from fromBody.
    convenience init?(fromBody: [String: Any?], triggerToOverride: Trigger?) {
        // Don't pull triggerId or triggerIsDeleted from triggerToOverride. A valid fromBody needs to provide this itself
        let triggerId = fromBody[KeyConstant.triggerId.rawValue] as? Int
        let triggerUUID = UUID.fromString(forUUIDString: fromBody[KeyConstant.triggerUUID.rawValue] as? String)
        // TODO TRIGGERS make sure last modified and deleted are properly implemented on server side functions
        let triggerLastModified = (fromBody[KeyConstant.triggerLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        let reminderIsDeleted = fromBody[KeyConstant.triggerIsDeleted.rawValue] as? Bool
        
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
                forLogActionReactions: triggerToOverride.logActionReactions,
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
        // if the reminder trigger is updated, then we pull values from fromBody
        
        let reactionsBody = fromBody[KeyConstant.reactionLogActions.rawValue] as? [[String: Any?]]
        let logActionReactions = reactionsBody?.compactMap { body -> TriggerLogReaction? in
            guard let id = body[KeyConstant.logActionTypeId.rawValue] as? Int else { return nil }
            let name = body[KeyConstant.logCustomActionName.rawValue] as? String
            return TriggerLogReaction(forLogActionTypeId: id, forLogCustomActionName: name)
        } ?? triggerToOverride?.logActionReactions
        
        var reminderActionResult: TriggerReminderResult? = {
            guard let body = fromBody[KeyConstant.reminderActionResult.rawValue] as? [String: Any?] else {
                return nil
            }
            
            return TriggerReminderResult(fromBody: body, toOverride: triggerToOverride?.reminderActionResult)
        }() ?? triggerToOverride?.reminderActionResult.copy() as? TriggerReminderResult
        
        let triggerType: TriggerType? = {
            guard let triggerTypeString = fromBody[KeyConstant.triggerType.rawValue] as? String else {
                return nil
            }
            return TriggerType(rawValue: triggerTypeString)
        }() ?? triggerToOverride?.triggerType
        let triggerTimeDelay = fromBody[KeyConstant.triggerTimeDelay.rawValue] as? Double ?? triggerToOverride?.triggerTimeDelay
        
        let triggerFixedTimeType: TriggerFixedTimeType? = {
            guard let triggerFixedTimeTypeString = fromBody[KeyConstant.triggerFixedTimeType.rawValue] as? String else {
                return nil
            }
            return TriggerFixedTimeType(rawValue: triggerFixedTimeTypeString)
        }() ?? triggerToOverride?.triggerFixedTimeType
        
        let triggerFixedTimeTypeAmount = fromBody[KeyConstant.triggerFixedTimeTypeAmount.rawValue] as? Int ?? triggerToOverride?.triggerFixedTimeTypeAmount
        let triggerFixedTimeUTCHour = fromBody[KeyConstant.triggerFixedTimeUTCHour.rawValue] as? Int ?? triggerToOverride?.triggerFixedTimeUTCHour
        let triggerFixedTimeUTCMinute = fromBody[KeyConstant.triggerFixedTimeUTCMinute.rawValue] as? Int ?? triggerToOverride?.triggerFixedTimeUTCMinute
        
        self.init(
            forTriggerId: triggerId,
            forTriggerUUID: triggerUUID,
            forLogActionReactions: logActionReactions,
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
        for reaction in logActionReactions where reaction.logActionTypeId == log.logActionTypeId {
            guard reaction.logCustomActionName.hasText() else {
                return true
            }
            if reaction.logCustomActionName == log.logCustomActionName { return true }
        }
        
        return false
    }
    
    func nextReminderDate(afterLog log: Log) -> Date? {
        let date = log.logEndDate ?? log.logStartDate
        
        switch triggerType {
        case .timeDelay:
            return date.addingTimeInterval(triggerTimeDelay)
        case .fixedTime:
            // Compute the start of day in the user's current time zone so the
            // "day" component aligns with local expectations.
            let startOfDay = Calendar.current.startOfDay(for: date)
            
            // Advance by the configured amount of days/weeks/months using the
            // same calendar to respect daylight saving changes.
            let targetDay = Calendar.current.date(byAdding: triggerFixedTimeType.calendarComponent,
                                               value: triggerFixedTimeTypeAmount,
                                               to: startOfDay) ?? ClassConstant.DateConstant.default1970Date
            
            var executionDate = Calendar.current.date(bySettingHour: triggerFixedTimeLocalHour, minute: triggerFixedTimeLocalMinute, second: 0, of: targetDay, matchingPolicy: .strict, repeatedTimePolicy: .first, direction: .forward)
            
            if let exec = executionDate, exec <= date {
                // If execution is in the past, move to the next period (by day)
                let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: targetDay) ?? targetDay
                executionDate = Calendar.current.date(bySettingHour: triggerFixedTimeLocalHour, minute: triggerFixedTimeLocalMinute, second: 0, of: nextDay, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
            }
            
            return executionDate
        }
    }
    
    func createBody(forDogUUID: UUID) -> [String: JSONValue] {
        var body: [String: JSONValue] = [:]
        body[KeyConstant.dogUUID.rawValue] = .string(forDogUUID.uuidString)
        body[KeyConstant.triggerId.rawValue] = .int(triggerId)
        body[KeyConstant.triggerUUID.rawValue] = .string(triggerUUID.uuidString)
        body[KeyConstant.reactionLogActions.rawValue] = .array(logActionReactions.map { .object($0.createBody()) })
        body[KeyConstant.reminderActionResult.rawValue] = .object(reminderActionResult.createBody())
        body[KeyConstant.triggerType.rawValue] = .string(triggerType.rawValue)
        body[KeyConstant.triggerTimeDelay.rawValue] = .double(triggerTimeDelay)
        body[KeyConstant.triggerFixedTimeType.rawValue] = .string(triggerFixedTimeType.rawValue)
        body[KeyConstant.triggerFixedTimeTypeAmount.rawValue] = .int(triggerFixedTimeTypeAmount)
        body[KeyConstant.triggerFixedTimeUTCHour.rawValue] = .int(triggerFixedTimeUTCHour)
        body[KeyConstant.triggerFixedTimeUTCMinute.rawValue] = .int(triggerFixedTimeUTCMinute)
        return body
    }
    
    // MARK: - Compare
    
    /// Returns true if all server-synced properties are identical to another trigger
    func isSame(as other: Trigger) -> Bool {
        if triggerId != other.triggerId { return false }
        if triggerUUID != other.triggerUUID { return false }
        if logActionReactions.count != other.logActionReactions.count { return false }
        for (a, b) in zip(logActionReactions, other.logActionReactions) {
            if !a.isSame(as: b) { return false }
        }
        if !reminderActionResult.isSame(as: other.reminderActionResult) { return false }
        if triggerType != other.triggerType { return false }
        if triggerTimeDelay != other.triggerTimeDelay { return false }
        if triggerFixedTimeType != other.triggerFixedTimeType { return false }
        if triggerFixedTimeTypeAmount != other.triggerFixedTimeTypeAmount { return false }
        if triggerFixedTimeUTCHour != other.triggerFixedTimeUTCHour { return false }
        if triggerFixedTimeUTCMinute != other.triggerFixedTimeUTCMinute { return false }
        return true
    }
}
