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
        for logActionReaction in triggerLogReactions {
            if let logActionReactionCopy = logActionReaction.copy() as? TriggerLogReaction {
                copy.triggerLogReactions.append(logActionReactionCopy)
            }
        }
        copy.triggerReminderResult = self.triggerReminderResult.copy() as? TriggerReminderResult ?? TriggerReminderResult()
        copy.triggerType = self.triggerType
        copy.triggerTimeDelay = self.triggerTimeDelay
        copy.triggerFixedTimeType = self.triggerFixedTimeType
        copy.triggerFixedTimeTypeAmount = self.triggerFixedTimeTypeAmount
        copy.triggerFixedTimeUTCHour = self.triggerFixedTimeUTCHour
        copy.triggerFixedTimeUTCMinute = self.triggerFixedTimeUTCMinute
        copy.triggerManualCondition = self.triggerManualCondition
        copy.triggerAlarmCreatedCondition = self.triggerAlarmCreatedCondition
        copy.offlineModeComponents = self.offlineModeComponents.copy() as? OfflineModeComponents ?? OfflineModeComponents()
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedTriggerId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.triggerId.rawValue)
        let decodedTriggerUUID = UUID.fromString(forUUIDString: aDecoder.decodeOptionalString(forKey: Constant.Key.triggerUUID.rawValue))
        let decodedtriggerLogReactions: [TriggerLogReaction]? = aDecoder.decodeOptionalObject(forKey: Constant.Key.triggerLogReactions.rawValue)
        let decodedtriggerReminderResult: TriggerReminderResult? = aDecoder.decodeOptionalObject(forKey: Constant.Key.triggerReminderResult.rawValue)
        let decodedTriggerType = TriggerType(rawValue: aDecoder.decodeOptionalString(forKey: Constant.Key.triggerType.rawValue) ?? Constant.Class.Trigger.defaultTriggerType.rawValue)
        let decodedTriggerTimeDelay = aDecoder.decodeOptionalDouble(forKey: Constant.Key.triggerTimeDelay.rawValue)
        let decodedTriggerFixedTimeType = TriggerFixedTimeType(rawValue: aDecoder.decodeOptionalString(forKey: Constant.Key.triggerFixedTimeType.rawValue) ?? Constant.Class.Trigger.defaultTriggerFixedTimeType.rawValue)
        let decodedTriggerFixedTimeTypeAmount = aDecoder.decodeOptionalInteger(forKey: Constant.Key.triggerFixedTimeTypeAmount.rawValue)
        let decodedTriggerFixedTimeUTCHour = aDecoder.decodeOptionalInteger(forKey: Constant.Key.triggerFixedTimeUTCHour.rawValue)
        let decodedTriggerFixedTimeUTCMinute = aDecoder.decodeOptionalInteger(forKey: Constant.Key.triggerFixedTimeUTCMinute.rawValue)
        let decodedTriggerManualCondition = aDecoder.decodeOptionalBool(forKey: Constant.Key.triggerManualCondition.rawValue) ?? Constant.Class.Trigger.defaultTriggerManualCondition
        let decodedTriggerAlarmCreatedCondition = aDecoder.decodeOptionalBool(forKey: Constant.Key.triggerAlarmCreatedCondition.rawValue) ?? Constant.Class.Trigger.defaultTriggerAlarmCreatedCondition
        let decodedOfflineModeComponents: OfflineModeComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.offlineModeComponents.rawValue)
        
        self.init(
            forTriggerId: decodedTriggerId,
            forTriggerUUID: decodedTriggerUUID,
            forTriggerLogReactions: decodedtriggerLogReactions,
            forTriggerReminderResult: decodedtriggerReminderResult,
            forTriggerType: decodedTriggerType,
            forTriggerTimeDelay: decodedTriggerTimeDelay,
            forTriggerFixedTimeType: decodedTriggerFixedTimeType,
            forTriggerFixedTimeTypeAmount: decodedTriggerFixedTimeTypeAmount,
            forTriggerFixedTimeUTCHour: decodedTriggerFixedTimeUTCHour,
            forTriggerFixedTimeUTCMinute: decodedTriggerFixedTimeUTCMinute,
            forTriggerManualCondition: decodedTriggerManualCondition,
            forTriggerAlarmCreatedCondition: decodedTriggerAlarmCreatedCondition,
            forOfflineModeComponents: decodedOfflineModeComponents
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(triggerId, forKey: Constant.Key.triggerId.rawValue)
        aCoder.encode(triggerUUID.uuidString, forKey: Constant.Key.triggerUUID.rawValue)
        aCoder.encode(triggerLogReactions, forKey: Constant.Key.triggerLogReactions.rawValue)
        aCoder.encode(triggerReminderResult, forKey: Constant.Key.triggerReminderResult.rawValue)
        aCoder.encode(triggerType.rawValue, forKey: Constant.Key.triggerType.rawValue)
        aCoder.encode(triggerTimeDelay, forKey: Constant.Key.triggerTimeDelay.rawValue)
        aCoder.encode(triggerFixedTimeType.rawValue, forKey: Constant.Key.triggerFixedTimeType.rawValue)
        aCoder.encode(triggerFixedTimeTypeAmount, forKey: Constant.Key.triggerFixedTimeTypeAmount.rawValue)
        aCoder.encode(triggerFixedTimeUTCHour, forKey: Constant.Key.triggerFixedTimeUTCHour.rawValue)
        aCoder.encode(triggerFixedTimeUTCMinute, forKey: Constant.Key.triggerFixedTimeUTCMinute.rawValue)
        aCoder.encode(triggerManualCondition, forKey: Constant.Key.triggerManualCondition.rawValue)
        aCoder.encode(triggerAlarmCreatedCondition, forKey: Constant.Key.triggerAlarmCreatedCondition.rawValue)
        aCoder.encode(offlineModeComponents, forKey: Constant.Key.offlineModeComponents.rawValue)
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
    
    private(set) var triggerLogReactions: [TriggerLogReaction] = [] {
        didSet {
            triggerLogReactions.sort { lhs, rhs in
                let lhsType = LogActionType.find(forLogActionTypeId: lhs.logActionTypeId)
                let rhsType = LogActionType.find(forLogActionTypeId: rhs.logActionTypeId)
                let lhsOrder = lhsType.sortOrder
                let rhsOrder = rhsType.sortOrder
                
                if lhsOrder != rhsOrder { return lhsOrder < rhsOrder }
                if lhs.logActionTypeId != rhs.logActionTypeId { return lhs.logActionTypeId < rhs.logActionTypeId }
                
                return lhs.logCustomActionName.localizedCaseInsensitiveCompare(rhs.logCustomActionName) == .orderedAscending
            }
        }
    }
    func setTriggerLogReactions(forTriggerLogReactions: [TriggerLogReaction]) -> Bool {
        if forTriggerLogReactions.isEmpty { return false }
        var seen = Set<String>()
        triggerLogReactions = forTriggerLogReactions.filter { reaction in
            let identifier = "\(reaction.logActionTypeId)-\(reaction.logCustomActionName)"
            return seen.insert(identifier).inserted
        }
        return true
    }
    
    var triggerReminderResult: TriggerReminderResult = TriggerReminderResult()
    
    var triggerType: TriggerType = Constant.Class.Trigger.defaultTriggerType
    private(set) var triggerTimeDelay: Double = Constant.Class.Trigger.defaultTriggerTimeDelay
    func changeTriggerTimeDelay(forTimeDelay: Double) -> Bool {
        guard forTimeDelay > 0 else { return false }
        triggerTimeDelay = forTimeDelay
        return true
    }
    
    /// triggerFixedTimeType isn't used currently. leave as its default of .day
    private var triggerFixedTimeType: TriggerFixedTimeType = Constant.Class.Trigger.defaultTriggerFixedTimeType
    private(set) var triggerFixedTimeTypeAmount: Int = Constant.Class.Trigger.defaultTriggerFixedTimeTypeAmount
    func changeTriggerFixedTimeTypeAmount(forAmount: Int) -> Bool {
        guard forAmount >= 0 else { return false }
        triggerFixedTimeTypeAmount = forAmount
        return true
    }
    
    /// Hour of the day that that the trigger should fire in GMT+0000. [0, 23]
    private(set) var triggerFixedTimeUTCHour: Int = Constant.Class.ReminderComponent.defaultUTCHour
    /// UTCHour but converted to the hour in the user's timezone
    var triggerFixedTimeLocalHour: Int {
        let hoursFromUTC = TimeZone.current.secondsFromGMT() / 3600
        
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
    private(set) var triggerFixedTimeUTCMinute: Int = Constant.Class.ReminderComponent.defaultUTCMinute
    /// UTCMinute but converted to the minute in the user's timezone
    var triggerFixedTimeLocalMinute: Int {
        let minutesFromUTC = (TimeZone.current.secondsFromGMT() % 3600) / 60
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
    
    /// If true, the trigger will be activated by logs that were manually created by the user (no reminder/alarm)
    var triggerManualCondition: Bool = Constant.Class.Trigger.defaultTriggerManualCondition
    /// If true, the trigger will be activated by logs that were automatically created by an alarm
    var triggerAlarmCreatedCondition: Bool = Constant.Class.Trigger.defaultTriggerAlarmCreatedCondition
    
    /// Components that are used to track an object to determine whether it was synced with the Hound server and whether it needs to be when the device comes back online
    private(set) var offlineModeComponents: OfflineModeComponents = OfflineModeComponents()
    
    // MARK: - Main
    
    init(
        forTriggerId: Int? = nil,
        forTriggerUUID: UUID? = nil,
        forTriggerLogReactions: [TriggerLogReaction]? = nil,
        forTriggerReminderResult: TriggerReminderResult? = nil,
        forTriggerType: TriggerType? = nil,
        forTriggerTimeDelay: Double? = nil,
        forTriggerFixedTimeType: TriggerFixedTimeType? = nil,
        forTriggerFixedTimeTypeAmount: Int? = nil,
        forTriggerFixedTimeUTCHour: Int? = nil,
        forTriggerFixedTimeUTCMinute: Int? = nil,
        forTriggerManualCondition: Bool? = nil,
        forTriggerAlarmCreatedCondition: Bool? = nil,
        forOfflineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        self.triggerId = forTriggerId ?? triggerId
        self.triggerUUID = forTriggerUUID ?? triggerUUID
        self.triggerLogReactions = forTriggerLogReactions ?? self.triggerLogReactions
        self.triggerReminderResult = forTriggerReminderResult ?? self.triggerReminderResult
        self.triggerType = forTriggerType ?? self.triggerType
        self.triggerTimeDelay = forTriggerTimeDelay ?? self.triggerTimeDelay
        self.triggerFixedTimeType = forTriggerFixedTimeType ?? self.triggerFixedTimeType
        self.triggerFixedTimeTypeAmount = forTriggerFixedTimeTypeAmount ?? self.triggerFixedTimeTypeAmount
        self.triggerFixedTimeUTCHour = forTriggerFixedTimeUTCHour ?? self.triggerFixedTimeUTCHour
        self.triggerFixedTimeUTCMinute = forTriggerFixedTimeUTCMinute ?? self.triggerFixedTimeUTCMinute
        self.triggerManualCondition = forTriggerManualCondition ?? self.triggerManualCondition
        self.triggerAlarmCreatedCondition = forTriggerAlarmCreatedCondition ?? self.triggerAlarmCreatedCondition
        self.offlineModeComponents = forOfflineModeComponents ?? self.offlineModeComponents
    }
    
    /// Provide a dictionary literal of reminder trigger properties to instantiate reminder trigger. Optionally, provide a reminder trigger to override with new properties from fromBody.
    convenience init?(fromBody: JSONResponseBody, triggerToOverride: Trigger?) {
        // Don't pull triggerId or triggerIsDeleted from triggerToOverride. A valid fromBody needs to provide this itself
        let triggerId = fromBody[Constant.Key.triggerId.rawValue] as? Int
        let triggerUUID = UUID.fromString(forUUIDString: fromBody[Constant.Key.triggerUUID.rawValue] as? String)
        let triggerLastModified = (fromBody[Constant.Key.triggerLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        let reminderIsDeleted = fromBody[Constant.Key.triggerIsDeleted.rawValue] as? Bool
        
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
                forTriggerLogReactions: triggerToOverride.triggerLogReactions,
                forTriggerReminderResult: triggerToOverride.triggerReminderResult,
                forTriggerType: triggerToOverride.triggerType,
                forTriggerTimeDelay: triggerToOverride.triggerTimeDelay,
                forTriggerFixedTimeType: triggerToOverride.triggerFixedTimeType,
                forTriggerFixedTimeTypeAmount: triggerToOverride.triggerFixedTimeTypeAmount,
                forTriggerFixedTimeUTCHour: triggerToOverride.triggerFixedTimeUTCHour,
                forTriggerFixedTimeUTCMinute: triggerToOverride.triggerFixedTimeUTCMinute,
                forTriggerManualCondition: triggerToOverride.triggerManualCondition,
                forTriggerAlarmCreatedCondition: triggerToOverride.triggerAlarmCreatedCondition,
                forOfflineModeComponents: triggerToOverride.offlineModeComponents
            )
            return
        }
        
        // if the reminder trigger is the same, then we pull values from triggerToOverride
        // if the reminder trigger is updated, then we pull values from fromBody
        
        let reactionsBody = fromBody[Constant.Key.triggerLogReactions.rawValue] as? [JSONResponseBody]
        let triggerLogReactions = reactionsBody?.compactMap { body -> TriggerLogReaction? in
            guard let id = body[Constant.Key.logActionTypeId.rawValue] as? Int else { return nil }
            let name = body[Constant.Key.logCustomActionName.rawValue] as? String
            return TriggerLogReaction(forLogActionTypeId: id, forLogCustomActionName: name)
        } ?? triggerToOverride?.triggerLogReactions
        
        let triggerReminderResult: TriggerReminderResult? = {
            guard let body = fromBody[Constant.Key.triggerReminderResult.rawValue] as? JSONResponseBody else {
                return nil
            }
            
            return TriggerReminderResult(fromBody: body, toOverride: triggerToOverride?.triggerReminderResult)
        }() ?? triggerToOverride?.triggerReminderResult.copy() as? TriggerReminderResult
        
        let triggerType: TriggerType? = {
            guard let triggerTypeString = fromBody[Constant.Key.triggerType.rawValue] as? String else {
                return nil
            }
            return TriggerType(rawValue: triggerTypeString)
        }() ?? triggerToOverride?.triggerType
        let triggerTimeDelay = fromBody[Constant.Key.triggerTimeDelay.rawValue] as? Double ?? triggerToOverride?.triggerTimeDelay
        
        let triggerFixedTimeType: TriggerFixedTimeType? = {
            guard let triggerFixedTimeTypeString = fromBody[Constant.Key.triggerFixedTimeType.rawValue] as? String else {
                return nil
            }
            return TriggerFixedTimeType(rawValue: triggerFixedTimeTypeString)
        }() ?? triggerToOverride?.triggerFixedTimeType
        
        let triggerFixedTimeTypeAmount = fromBody[Constant.Key.triggerFixedTimeTypeAmount.rawValue] as? Int ?? triggerToOverride?.triggerFixedTimeTypeAmount
        let triggerFixedTimeUTCHour = fromBody[Constant.Key.triggerFixedTimeUTCHour.rawValue] as? Int ?? triggerToOverride?.triggerFixedTimeUTCHour
        let triggerFixedTimeUTCMinute = fromBody[Constant.Key.triggerFixedTimeUTCMinute.rawValue] as? Int ?? triggerToOverride?.triggerFixedTimeUTCMinute
        let triggerManualCondition = fromBody[Constant.Key.triggerManualCondition.rawValue] as? Bool ?? triggerToOverride?.triggerManualCondition
        let triggerAlarmCreatedCondition = fromBody[Constant.Key.triggerAlarmCreatedCondition.rawValue] as? Bool ?? triggerToOverride?.triggerAlarmCreatedCondition
        
        self.init(
            forTriggerId: triggerId,
            forTriggerUUID: triggerUUID,
            forTriggerLogReactions: triggerLogReactions,
            forTriggerReminderResult: triggerReminderResult,
            forTriggerType: triggerType,
            forTriggerTimeDelay: triggerTimeDelay,
            forTriggerFixedTimeType: triggerFixedTimeType,
            forTriggerFixedTimeTypeAmount: triggerFixedTimeTypeAmount,
            forTriggerFixedTimeUTCHour: triggerFixedTimeUTCHour,
            forTriggerFixedTimeUTCMinute: triggerFixedTimeUTCMinute,
            forTriggerManualCondition: triggerManualCondition,
            forTriggerAlarmCreatedCondition: triggerAlarmCreatedCondition,
            forOfflineModeComponents: nil
        )
    }
    
    // MARK: - Functions
    
    func readableTime() -> String {
        switch triggerType {
        case .timeDelay:
            return "\(triggerTimeDelay.readable(capitalizeWords: false, abreviateWords: true)) later"
        case .fixedTime:
            var text = ""
            switch triggerFixedTimeTypeAmount {
            case 0: text += "same day"
            case 1: text += "next day"
            default: text += "\(triggerFixedTimeTypeAmount) days later"
            }
            text += " @ \(nextReminderDate(afterDate: Date())?.houndFormatted(.formatStyle(date: .omitted, time: .shortened)) ?? Constant.Visual.Text.unknownText)"
            return text
        }
    }
    
    func shouldActivateTrigger(forLog log: Log) -> Bool {
        if triggerManualCondition == false && log.logCreatedByReminderUUID == nil {
            return false
        }
        if triggerAlarmCreatedCondition == false && log.logCreatedByReminderUUID != nil {
            return false
        }
        
        for reaction in triggerLogReactions where reaction.logActionTypeId == log.logActionTypeId {
            guard reaction.logCustomActionName.hasText() else {
                return true
            }
            if reaction.logCustomActionName == log.logCustomActionName { return true }
        }
        
        return false
    }
    
    func nextReminderDate(afterDate date: Date) -> Date? {
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
                                               to: startOfDay) ?? Constant.Class.Date.default1970Date
            
            let strictExecutionDate = Calendar.current.date(bySettingHour: triggerFixedTimeLocalHour, minute: triggerFixedTimeLocalMinute, second: 0, of: targetDay, matchingPolicy: .strict, repeatedTimePolicy: .first, direction: .forward)
            let laxExecutionDate = Calendar.current.date(bySettingHour: triggerFixedTimeLocalHour, minute: triggerFixedTimeLocalMinute, second: 0, of: targetDay, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
            let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: targetDay) ?? targetDay
            let nextDayDate = Calendar.current.date(bySettingHour: triggerFixedTimeLocalHour, minute: triggerFixedTimeLocalMinute, second: 0, of: nextDay, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
            
            let executionDate = strictExecutionDate ?? laxExecutionDate
            
            if let executionDate = executionDate, executionDate > date {
                return executionDate
            }
            
            // executionDate doesn't exist or is before logStart/endDate
            return nextDayDate
        }
    }
    
    func nextReminderDate(afterLog log: Log) -> Date? {
        let date = log.logEndDate ?? log.logStartDate
        
        return nextReminderDate(afterDate: date)
    }
    
    func createTriggerResultReminder(afterLog log: Log) -> Reminder? {
            guard let executionDate = nextReminderDate(afterLog: log) else {
                return nil
            }

            return Reminder(
                forReminderActionTypeId: triggerReminderResult.reminderActionTypeId,
                forReminderCustomActionName: triggerReminderResult.reminderCustomActionName,
                forReminderType: .oneTime,
                forReminderExecutionBasis: Date(),
                forReminderIsTriggerResult: true,
                // all users get this reminder
                forReminderRecipientUserIds: Constant.Class.Reminder.defaultReminderRecipientUserIds,
                forOneTimeComponents: OneTimeComponents(date: executionDate)
            )
        }
    
    func createBody(forDogUUID: UUID) -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.dogUUID.rawValue] = .string(forDogUUID.uuidString)
        body[Constant.Key.triggerId.rawValue] = .int(triggerId)
        body[Constant.Key.triggerUUID.rawValue] = .string(triggerUUID.uuidString)
        body[Constant.Key.triggerLogReactions.rawValue] = .array(triggerLogReactions.map { .object($0.createBody()) })
        body[Constant.Key.triggerReminderResult.rawValue] = .object(triggerReminderResult.createBody())
        body[Constant.Key.triggerType.rawValue] = .string(triggerType.rawValue)
        body[Constant.Key.triggerTimeDelay.rawValue] = .double(triggerTimeDelay)
        body[Constant.Key.triggerFixedTimeType.rawValue] = .string(triggerFixedTimeType.rawValue)
        body[Constant.Key.triggerFixedTimeTypeAmount.rawValue] = .int(triggerFixedTimeTypeAmount)
        body[Constant.Key.triggerFixedTimeUTCHour.rawValue] = .int(triggerFixedTimeUTCHour)
        body[Constant.Key.triggerFixedTimeUTCMinute.rawValue] = .int(triggerFixedTimeUTCMinute)
        body[Constant.Key.triggerManualCondition.rawValue] = .bool(triggerManualCondition)
        body[Constant.Key.triggerAlarmCreatedCondition.rawValue] = .bool(triggerAlarmCreatedCondition)
        return body
    }
    
    // MARK: - Compare
    
    /// Returns true if all server-synced properties are identical to another trigger
    func isSame(as other: Trigger) -> Bool {
        if triggerId != other.triggerId { return false }
        if triggerUUID != other.triggerUUID { return false }
        if triggerLogReactions.count != other.triggerLogReactions.count { return false }
        for (a, b) in zip(triggerLogReactions, other.triggerLogReactions) where !a.isSame(as: b) {
            return false
        }
        if !triggerReminderResult.isSame(as: other.triggerReminderResult) { return false }
        if triggerType != other.triggerType { return false }
        if triggerTimeDelay != other.triggerTimeDelay { return false }
        if triggerFixedTimeType != other.triggerFixedTimeType { return false }
        if triggerFixedTimeTypeAmount != other.triggerFixedTimeTypeAmount { return false }
        if triggerFixedTimeUTCHour != other.triggerFixedTimeUTCHour { return false }
        if triggerFixedTimeUTCMinute != other.triggerFixedTimeUTCMinute { return false }
        if triggerManualCondition != other.triggerManualCondition { return false }
        if triggerAlarmCreatedCondition != other.triggerAlarmCreatedCondition { return false }
        return true
    }
}
