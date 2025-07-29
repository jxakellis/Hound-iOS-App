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
        
        copy.timeDelayComponents = self.timeDelayComponents.copy() as? TriggerTimeDelayComponents ?? TriggerTimeDelayComponents()
        copy.fixedTimeComponents = self.fixedTimeComponents.copy() as? TriggerFixedTimeComponents ?? TriggerFixedTimeComponents()
        
        copy.triggerManualCondition = self.triggerManualCondition
        copy.triggerAlarmCreatedCondition = self.triggerAlarmCreatedCondition
        copy.offlineModeComponents = self.offlineModeComponents.copy() as? OfflineModeComponents ?? OfflineModeComponents()
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let triggerId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.triggerId.rawValue)
        let triggerUUID = UUID.fromString(forUUIDString: aDecoder.decodeOptionalString(forKey: Constant.Key.triggerUUID.rawValue))
        let triggerLogReactions: [TriggerLogReaction]? = aDecoder.decodeOptionalObject(forKey: Constant.Key.triggerLogReactions.rawValue)
        let triggerReminderResult: TriggerReminderResult? = aDecoder.decodeOptionalObject(forKey: Constant.Key.triggerReminderResult.rawValue)
        let triggerType = TriggerType(rawValue: aDecoder.decodeOptionalString(forKey: Constant.Key.triggerType.rawValue) ?? Constant.Class.Trigger.defaultTriggerType.rawValue)
        
        let triggerTimeDelayComponents: TriggerTimeDelayComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.triggerTimeDelayComponents.rawValue)
        let triggerFixedTimeComponents: TriggerFixedTimeComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.triggerFixedTimeComponents.rawValue)
        
        let triggerManualCondition = aDecoder.decodeOptionalBool(forKey: Constant.Key.triggerManualCondition.rawValue) ?? Constant.Class.Trigger.defaultTriggerManualCondition
        let triggerAlarmCreatedCondition = aDecoder.decodeOptionalBool(forKey: Constant.Key.triggerAlarmCreatedCondition.rawValue) ?? Constant.Class.Trigger.defaultTriggerAlarmCreatedCondition
        let offlineModeComponents: OfflineModeComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.offlineModeComponents.rawValue)
        
        self.init(
            triggerId: triggerId,
            triggerUUID: triggerUUID,
            triggerLogReactions: triggerLogReactions,
            triggerReminderResult: triggerReminderResult,
            triggerType: triggerType,
            triggerTimeDelayComponents: triggerTimeDelayComponents,
            triggerFixedTimeComponents: triggerFixedTimeComponents,
            triggerManualCondition: triggerManualCondition,
            triggerAlarmCreatedCondition: triggerAlarmCreatedCondition,
            offlineModeComponents: offlineModeComponents
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(triggerId, forKey: Constant.Key.triggerId.rawValue)
        aCoder.encode(triggerUUID.uuidString, forKey: Constant.Key.triggerUUID.rawValue)
        aCoder.encode(triggerLogReactions, forKey: Constant.Key.triggerLogReactions.rawValue)
        aCoder.encode(triggerReminderResult, forKey: Constant.Key.triggerReminderResult.rawValue)
        aCoder.encode(triggerType.rawValue, forKey: Constant.Key.triggerType.rawValue)
        
        aCoder.encode(timeDelayComponents, forKey: Constant.Key.triggerTimeDelayComponents.rawValue)
        
        aCoder.encode(fixedTimeComponents, forKey: Constant.Key.triggerFixedTimeComponents.rawValue)
        
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
            if lhs.timeDelayComponents.triggerTimeDelay < rhs.timeDelayComponents.triggerTimeDelay {
                return true
            }
            else if lhs.timeDelayComponents.triggerTimeDelay > rhs.timeDelayComponents.triggerTimeDelay {
                return false
            }
        case (.fixedTime, .fixedTime):
            // 2a. if both fixedTime, smaller fixed time comes first (if one is smaller)
            // If they are of the same fixed time type, ignore this check
            // If diff fixed time types, the smaller one comes first
            switch (lhs.fixedTimeComponents.triggerFixedTimeType, rhs.fixedTimeComponents.triggerFixedTimeType) {
            case let (lhsType, rhsType) where lhsType == rhsType: break
            case (.day, _): return true
            case (.week, .day): return false
            case (.week, .month): return true
            case (.month, _): return false
            default: break
            }
            
            // One with smaller fixed time type amount comes first
            // If equal, need a different tie breaker
            if lhs.fixedTimeComponents.triggerFixedTimeTypeAmount < rhs.fixedTimeComponents.triggerFixedTimeTypeAmount {
                return true
            }
            else if lhs.fixedTimeComponents.triggerFixedTimeTypeAmount > rhs.fixedTimeComponents.triggerFixedTimeTypeAmount {
                return false
            }
            
            // One with smaller fixed time hour comes first
            // If equal, need a different tie breaker
            if lhs.fixedTimeComponents.triggerFixedTimeHour < rhs.fixedTimeComponents.triggerFixedTimeHour {
                return true
            }
            else if lhs.fixedTimeComponents.triggerFixedTimeHour > rhs.fixedTimeComponents.triggerFixedTimeHour {
                return false
            }
            
            // One with smaller fixed time minute comes first
            // If equal, need a different tie breaker
            if lhs.fixedTimeComponents.triggerFixedTimeMinute < rhs.fixedTimeComponents.triggerFixedTimeMinute {
                return true
            }
            else if lhs.fixedTimeComponents.triggerFixedTimeMinute > rhs.fixedTimeComponents.triggerFixedTimeMinute {
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
    func setTriggerLogReactions(_ newLogReactions: [TriggerLogReaction]) -> Bool {
        if newLogReactions.isEmpty { return false }
        var seen = Set<String>()
        triggerLogReactions = newLogReactions.filter { reaction in
            let identifier = "\(reaction.logActionTypeId)-\(reaction.logCustomActionName)"
            return seen.insert(identifier).inserted
        }
        return true
    }
    
    var triggerReminderResult: TriggerReminderResult = TriggerReminderResult()
    
    var triggerType: TriggerType = Constant.Class.Trigger.defaultTriggerType
    
    private(set) var timeDelayComponents: TriggerTimeDelayComponents = TriggerTimeDelayComponents()
    private(set) var fixedTimeComponents: TriggerFixedTimeComponents = TriggerFixedTimeComponents()
    
    /// If true, the trigger will be activated by logs that were manually created by the user (no reminder/alarm)
    var triggerManualCondition: Bool = Constant.Class.Trigger.defaultTriggerManualCondition
    /// If true, the trigger will be activated by logs that were automatically created by an alarm
    var triggerAlarmCreatedCondition: Bool = Constant.Class.Trigger.defaultTriggerAlarmCreatedCondition
    
    /// Components that are used to track an object to determine whether it was synced with the Hound server and whether it needs to be when the device comes back online
    private(set) var offlineModeComponents: OfflineModeComponents = OfflineModeComponents()
    
    // MARK: - Main
    
    init(
        triggerId: Int? = nil,
        triggerUUID: UUID? = nil,
        triggerLogReactions: [TriggerLogReaction]? = nil,
        triggerReminderResult: TriggerReminderResult? = nil,
        triggerType: TriggerType? = nil,
        triggerTimeDelayComponents: TriggerTimeDelayComponents? = nil,
        triggerFixedTimeComponents: TriggerFixedTimeComponents? = nil,
        triggerManualCondition: Bool? = nil,
        triggerAlarmCreatedCondition: Bool? = nil,
        offlineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        self.triggerId = triggerId ?? self.triggerId
        self.triggerUUID = triggerUUID ?? self.triggerUUID
        self.triggerLogReactions = triggerLogReactions ?? self.triggerLogReactions
        self.triggerReminderResult = triggerReminderResult ?? self.triggerReminderResult
        self.triggerType = triggerType ?? self.triggerType
        self.timeDelayComponents = triggerTimeDelayComponents ?? self.timeDelayComponents
        self.fixedTimeComponents = triggerFixedTimeComponents ?? self.fixedTimeComponents
        self.triggerManualCondition = triggerManualCondition ?? self.triggerManualCondition
        self.triggerAlarmCreatedCondition = triggerAlarmCreatedCondition ?? self.triggerAlarmCreatedCondition
        self.offlineModeComponents = offlineModeComponents ?? self.offlineModeComponents
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
                triggerId: triggerToOverride.triggerId,
                triggerUUID: triggerToOverride.triggerUUID,
                triggerLogReactions: triggerToOverride.triggerLogReactions,
                triggerReminderResult: triggerToOverride.triggerReminderResult,
                triggerType: triggerToOverride.triggerType,
                triggerTimeDelayComponents: triggerToOverride.timeDelayComponents,
                triggerFixedTimeComponents: triggerToOverride.fixedTimeComponents,
                triggerManualCondition: triggerToOverride.triggerManualCondition,
                triggerAlarmCreatedCondition: triggerToOverride.triggerAlarmCreatedCondition,
                offlineModeComponents: triggerToOverride.offlineModeComponents
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
        
        let triggerTimeDelayComponents = TriggerTimeDelayComponents(fromBody: fromBody, componentToOverride: triggerToOverride?.timeDelayComponents)
        let triggerFixedTimeComponents = TriggerFixedTimeComponents(fromBody: fromBody, componentToOverride: triggerToOverride?.fixedTimeComponents)
        
        let triggerManualCondition = fromBody[Constant.Key.triggerManualCondition.rawValue] as? Bool ?? triggerToOverride?.triggerManualCondition
        let triggerAlarmCreatedCondition = fromBody[Constant.Key.triggerAlarmCreatedCondition.rawValue] as? Bool ?? triggerToOverride?.triggerAlarmCreatedCondition
        
        self.init(
            triggerId: triggerId,
            triggerUUID: triggerUUID,
            triggerLogReactions: triggerLogReactions,
            triggerReminderResult: triggerReminderResult,
            triggerType: triggerType,
            triggerTimeDelayComponents: triggerTimeDelayComponents,
            triggerFixedTimeComponents: triggerFixedTimeComponents,
            triggerManualCondition: triggerManualCondition,
            triggerAlarmCreatedCondition: triggerAlarmCreatedCondition,
            offlineModeComponents: nil
        )
    }
    
    // MARK: - Functions
    
    func readableTime() -> String {
        switch triggerType {
        case .timeDelay:
            return timeDelayComponents.readableTime()
        case .fixedTime:
            return fixedTimeComponents.readableTime()
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
    
    private func nextReminderDate(afterDate date: Date, in inTimeZone: TimeZone = UserConfiguration.timeZone) -> Date? {
        switch triggerType {
        case .timeDelay:
            return timeDelayComponents.nextReminderDate(afterDate: date)
        case .fixedTime:
            return fixedTimeComponents.nextReminderDate(afterDate: date, in: inTimeZone)
        }
    }
    
    private func nextReminderDate(afterLog log: Log, in inTimeZone: TimeZone = UserConfiguration.timeZone) -> Date? {
        let date = log.logEndDate ?? log.logStartDate
        
        return nextReminderDate(afterDate: date, in: inTimeZone)
    }
    
    /// Attempts to construct a reminder for the trigger result of this trigger, after the given log's end date (or start date). However, if this reminder is in the past, return nil as we don't want to create a reminder that is already overdue.
    func createTriggerResultReminder(afterLog log: Log, in inTimeZone: TimeZone = UserConfiguration.timeZone) -> Reminder? {
        guard let executionDate = nextReminderDate(afterLog: log, in: inTimeZone) else {
            return nil
        }
        
        // Allow for proper construction of the reminder result and if it already happened, then we don't need it
        guard executionDate > Date() else {
            return nil
        }
        
        return Reminder(
            reminderActionTypeId: triggerReminderResult.reminderActionTypeId,
            reminderCustomActionName: triggerReminderResult.reminderCustomActionName,
            reminderType: .oneTime,
            reminderExecutionBasis: Date(),
            reminderIsTriggerResult: true,
            reminderRecipientUserIds: Constant.Class.Reminder.defaultReminderRecipientUserIds,
            oneTimeComponents: OneTimeComponents(oneTimeDate: executionDate)
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
        body.merge(timeDelayComponents.createBody()) { _, new in
            return new
        }
        body.merge(fixedTimeComponents.createBody()) { _, new in
            return new
        }
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
        if !timeDelayComponents.isSame(as: other.timeDelayComponents) { return false }
        if !fixedTimeComponents.isSame(as: other.fixedTimeComponents) { return false }
        if triggerManualCondition != other.triggerManualCondition { return false }
        if triggerAlarmCreatedCondition != other.triggerAlarmCreatedCondition { return false }
        return true
    }
}
