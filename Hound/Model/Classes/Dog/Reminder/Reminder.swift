//
//  Remindert.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ReminderType: String, CaseIterable {
    
    init?(rawValue: String) {
        for type in ReminderType.allCases where type.rawValue.lowercased() == rawValue.lowercased() {
            self = type
            return
        }
        
        self = .countdown
        return
    }
    case oneTime
    case countdown
    case weekly
    case monthly
    
    var readable: String {
        switch self {
        case .oneTime:
            return "Just Once"
        case .countdown:
            return "After Set Time"
        case .weekly:
            return "On Days of Week"
        case .monthly:
            return "Every Month"
        }
    }
}

final class Reminder: NSObject, NSCoding, NSCopying, Comparable {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Reminder()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        copy.reminderId = self.reminderId
        copy.reminderUUID = self.reminderUUID
        copy.reminderCreated = self.reminderCreated
        copy.reminderCreatedBy = self.reminderCreatedBy
        copy.reminderLastModified = self.reminderLastModified
        copy.reminderLastModifiedBy = self.reminderLastModifiedBy
        copy.reminderActionTypeId = self.reminderActionTypeId
        copy.reminderCustomActionName = self.reminderCustomActionName
        copy.reminderType = self.reminderType
        copy.reminderExecutionBasis = self.reminderExecutionBasis
        copy.reminderIsTriggerResult = self.reminderIsTriggerResult
        copy.storedReminderIsEnabled = self.storedReminderIsEnabled
        copy.reminderRecipientUserIds = self.reminderRecipientUserIds
        copy.reminderTimeZone = self.reminderTimeZone
        
        copy.countdownComponents = self.countdownComponents.copy() as? CountdownComponents ?? CountdownComponents()
        copy.weeklyComponents = self.weeklyComponents.copy() as? WeeklyComponents ?? WeeklyComponents()
        copy.monthlyComponents = self.monthlyComponents.copy() as? MonthlyComponents ?? MonthlyComponents()
        copy.oneTimeComponents = self.oneTimeComponents.copy() as? OneTimeComponents ?? OneTimeComponents()
        copy.snoozeComponents = self.snoozeComponents.copy() as? SnoozeComponents ?? SnoozeComponents()
        copy.offlineModeComponents = self.offlineModeComponents.copy() as? OfflineModeComponents ?? OfflineModeComponents()
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedReminderId: Int? = aDecoder.decodeOptionalInteger(forKey: Constant.Key.reminderId.rawValue)
        let decodedReminderUUID: UUID? = UUID.fromString(UUIDString: aDecoder.decodeOptionalString(forKey: Constant.Key.reminderUUID.rawValue))
        let decodedReminderCreated: Date? = (aDecoder.decodeOptionalString(forKey: Constant.Key.reminderCreated.rawValue)?.formatISO8601IntoDate())
        let decodedReminderCreatedBy: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.reminderCreatedBy.rawValue)
        let decodedReminderLastModified: Date? = (aDecoder.decodeOptionalString(forKey: Constant.Key.reminderLastModified.rawValue)?.formatISO8601IntoDate())
        let decodedReminderLastModifiedBy: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.reminderLastModifiedBy.rawValue)
        let decodedReminderActionTypeId: Int? = aDecoder.decodeOptionalInteger(forKey: Constant.Key.reminderActionTypeId.rawValue)
        let decodedReminderCustomActionName: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.reminderCustomActionName.rawValue)
        let decodedReminderType: ReminderType? = ReminderType(rawValue: aDecoder.decodeOptionalString(forKey: Constant.Key.reminderType.rawValue) ?? Constant.Class.Reminder.defaultReminderType.rawValue)
        let decodedReminderExecutionBasis: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.reminderExecutionBasis.rawValue)
        let decodedReminderIsTriggerResult: Bool? = aDecoder.decodeOptionalBool(forKey: Constant.Key.reminderIsTriggerResult.rawValue)
        let decodedReminderIsEnabled: Bool? = aDecoder.decodeOptionalBool(forKey: Constant.Key.reminderIsEnabled.rawValue)
        let decodedReminderRecipientUserIds: [String]? = aDecoder.decodeOptionalObject(forKey: Constant.Key.reminderRecipientUserIds.rawValue)
        let decodedReminderTimeZone: TimeZone? = TimeZone.from(aDecoder.decodeOptionalString(forKey: Constant.Key.reminderTimeZone.rawValue))
        
        let decodedCountdownComponents: CountdownComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.countdownComponents.rawValue)
        let decodedWeeklyComponents: WeeklyComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.weeklyComponents.rawValue)
        let decodedMonthlyComponents: MonthlyComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.monthlyComponents.rawValue)
        let decodedOneTimeComponents: OneTimeComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.oneTimeComponents.rawValue)
        let decodedSnoozeComponents: SnoozeComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.snoozeComponents.rawValue)
        let decodedOfflineModeComponents: OfflineModeComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.offlineModeComponents.rawValue)
        
        self.init(
            reminderId: decodedReminderId,
            reminderUUID: decodedReminderUUID,
            reminderCreated: decodedReminderCreated,
            reminderCreatedBy: decodedReminderCreatedBy,
            reminderLastModified: decodedReminderLastModified,
            reminderLastModifiedBy: decodedReminderLastModifiedBy,
            reminderActionTypeId: decodedReminderActionTypeId,
            reminderCustomActionName: decodedReminderCustomActionName,
            reminderType: decodedReminderType,
            reminderExecutionBasis: decodedReminderExecutionBasis,
            reminderIsTriggerResult: decodedReminderIsTriggerResult,
            reminderIsEnabled: decodedReminderIsEnabled,
            reminderRecipientUserIds: decodedReminderRecipientUserIds,
            reminderTimeZone: decodedReminderTimeZone,
            countdownComponents: decodedCountdownComponents,
            weeklyComponents: decodedWeeklyComponents,
            monthlyComponents: decodedMonthlyComponents,
            oneTimeComponents: decodedOneTimeComponents,
            snoozeComponents: decodedSnoozeComponents,
            offlineModeComponents: decodedOfflineModeComponents
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeInt, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        if let reminderId = reminderId {
            aCoder.encode(reminderId, forKey: Constant.Key.reminderId.rawValue)
        }
        aCoder.encode(reminderUUID.uuidString, forKey: Constant.Key.reminderUUID.rawValue)
        aCoder.encode(reminderCreated.ISO8601FormatWithFractionalSeconds(), forKey: Constant.Key.reminderCreated.rawValue)
        aCoder.encode(reminderCreatedBy, forKey: Constant.Key.reminderCreatedBy.rawValue)
        if let reminderLastModified = reminderLastModified {
            aCoder.encode(reminderLastModified.ISO8601FormatWithFractionalSeconds(), forKey: Constant.Key.reminderLastModified.rawValue)
        }
        if let reminderLastModifiedBy = reminderLastModifiedBy {
            aCoder.encode(reminderLastModifiedBy, forKey: Constant.Key.reminderLastModifiedBy.rawValue)
        }
        aCoder.encode(reminderActionTypeId, forKey: Constant.Key.reminderActionTypeId.rawValue)
        aCoder.encode(reminderCustomActionName, forKey: Constant.Key.reminderCustomActionName.rawValue)
        aCoder.encode(reminderType.rawValue, forKey: Constant.Key.reminderType.rawValue)
        aCoder.encode(reminderExecutionBasis, forKey: Constant.Key.reminderExecutionBasis.rawValue)
        aCoder.encode(reminderIsTriggerResult, forKey: Constant.Key.reminderIsTriggerResult.rawValue)
        aCoder.encode(reminderIsEnabled, forKey: Constant.Key.reminderIsEnabled.rawValue)
        aCoder.encode(reminderRecipientUserIds, forKey: Constant.Key.reminderRecipientUserIds.rawValue)
        aCoder.encode(reminderTimeZone.identifier, forKey: Constant.Key.reminderTimeZone.rawValue)
        
        aCoder.encode(countdownComponents, forKey: Constant.Key.countdownComponents.rawValue)
        aCoder.encode(weeklyComponents, forKey: Constant.Key.weeklyComponents.rawValue)
        aCoder.encode(monthlyComponents, forKey: Constant.Key.monthlyComponents.rawValue)
        aCoder.encode(oneTimeComponents, forKey: Constant.Key.oneTimeComponents.rawValue)
        aCoder.encode(snoozeComponents, forKey: Constant.Key.snoozeComponents.rawValue)
        aCoder.encode(offlineModeComponents, forKey: Constant.Key.offlineModeComponents.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Reminder else { return false }
        if reminderId != other.reminderId { return false }
 else if reminderUUID != other.reminderUUID { return false }
 else if reminderCreated != other.reminderCreated { return false }
 else if reminderCreatedBy != other.reminderCreatedBy { return false }
 else if reminderLastModified != other.reminderLastModified { return false }
 else if reminderLastModifiedBy != other.reminderLastModifiedBy { return false }
 else if reminderActionTypeId != other.reminderActionTypeId { return false }
 else if reminderCustomActionName != other.reminderCustomActionName { return false }
 else if reminderType != other.reminderType { return false }
 else if reminderExecutionBasis != other.reminderExecutionBasis { return false }
 else if reminderIsEnabled != other.reminderIsEnabled { return false }
 else if Set(reminderRecipientUserIds) != Set(other.reminderRecipientUserIds) { return false }
 else if reminderIsTriggerResult != other.reminderIsTriggerResult { return false }
 else if reminderTimeZone != other.reminderTimeZone { return false }
        
        // known at this point that the reminderTypes are the same
        switch reminderType {
        case .countdown:
            if countdownComponents != other.countdownComponents { return false }
        case .weekly:
            if weeklyComponents != other.weeklyComponents { return false }
        case .monthly:
            if monthlyComponents != other.monthlyComponents { return false }
        case .oneTime:
            if oneTimeComponents != other.oneTimeComponents { return false }
        }
        
        if snoozeComponents != other.snoozeComponents { return false }
        
        return true
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Reminder, rhs: Reminder) -> Bool {
        guard lhs.reminderType == rhs.reminderType else {
            // lhs and rhs are known to be different styles
            switch lhs.reminderType {
            case .countdown:
                // rhs can't be .countdown and .countdown always comes first, so lhs comes first
                return true
            case .weekly:
                // rhs can't be weekly. Therefore, the only way it can come before is if its .countdown
                return (rhs.reminderType == .countdown) ? false : true
            case .monthly:
                // rhs can't be monthly. Therefore, the only way it can come before is if its .countdown or .weekly
                return (rhs.reminderType == .countdown || rhs.reminderType == .weekly) ? false : true
            case .oneTime:
                // rhs can't be oneTime. Therefore, it will come before as it has to be one of the other types
                return false
            }
        }
        
        /// Analyzes both the reminderId and reminderUUID, finding which reminder is lessor than the other reminder.
        func isLHSBeforeRHS(lhs: Reminder, rhs: Reminder) -> Bool {
            guard let lhsReminderId = lhs.reminderId else {
                guard rhs.reminderId != nil else {
                    // neither lhs nor rhs has a reminderId. The one that was created first should come first
                    return lhs.offlineModeComponents.initialCreationDate.distance(to: rhs.offlineModeComponents.initialCreationDate) >= 0
                }
                
                // lhs doesn't have a reminderId but rhs does. rhs should come first
                return false
            }
            
            guard let rhsReminderId = rhs.reminderId else {
                // lhs has a reminderId but rhs doesn't. lhs should come first
                return true
            }
            
            return lhsReminderId <= rhsReminderId
        }
        
        let displayTZ = UserConfiguration.timeZone
        
        switch lhs.reminderType {
        case .countdown:
            // both countdown
            let lhsExecutionInterval = lhs.countdownComponents.executionInterval
            let rhsExecutionInterval = rhs.countdownComponents.executionInterval
            
            guard lhsExecutionInterval != rhsExecutionInterval else {
                // if equal, then smaller reminderId comes first
                return isLHSBeforeRHS(lhs: lhs, rhs: rhs)
            }
            // shorter executionInterval comes first
            return lhsExecutionInterval < rhsExecutionInterval
        case .weekly:
            // both weekly
            // earlier in the day is listed first
            let lhsTime = lhs.weeklyComponents.localTimeOfDay(reminderExecutionBasis: lhs.reminderExecutionBasis, reminderTimeZone: lhs.reminderTimeZone, displayTimeZone: displayTZ)
            let rhsTime = rhs.weeklyComponents.localTimeOfDay(reminderExecutionBasis: rhs.reminderExecutionBasis, reminderTimeZone: rhs.reminderTimeZone, displayTimeZone: displayTZ)
            
            if lhsTime.hour != rhsTime.hour {
                return lhsTime.hour < rhsTime.hour
            }
            if lhsTime.minute != rhsTime.minute {
                return lhsTime.minute < rhsTime.minute
            }
            
            return isLHSBeforeRHS(lhs: lhs, rhs: rhs)
        case .monthly:
            // both monthly
            let lhsDay = lhs.monthlyComponents.localDayOfMonth(reminderExecutionBasis: lhs.reminderExecutionBasis, reminderTimeZone: lhs.reminderTimeZone, displayTimeZone: displayTZ)
            let rhsDay = rhs.monthlyComponents.localDayOfMonth(reminderExecutionBasis: rhs.reminderExecutionBasis, reminderTimeZone: rhs.reminderTimeZone, displayTimeZone: displayTZ)
            if lhsDay != rhsDay {
                return lhsDay < rhsDay
            }
            
            let lhsTime = lhs.monthlyComponents.localTimeOfDay(reminderExecutionBasis: lhs.reminderExecutionBasis, reminderTimeZone: lhs.reminderTimeZone, displayTimeZone: displayTZ)
            let rhsTime = rhs.monthlyComponents.localTimeOfDay(reminderExecutionBasis: rhs.reminderExecutionBasis, reminderTimeZone: rhs.reminderTimeZone, displayTimeZone: displayTZ)
            
            if lhsTime.hour != rhsTime.hour {
                return lhsTime.hour < rhsTime.hour
            }
            if lhsTime.minute != rhsTime.minute {
                return lhsTime.minute < rhsTime.minute
            }
            
            return isLHSBeforeRHS(lhs: lhs, rhs: rhs)
        case .oneTime:
            // both oneTime
            let lhsDistanceToPast = Date().distance(to: lhs.oneTimeComponents.oneTimeDate)
            let rhsDistanceToPast = Date().distance(to: rhs.oneTimeComponents.oneTimeDate)
            
            guard lhsDistanceToPast != rhsDistanceToPast else {
                // if equal, then smaller reminderId comes first
                return isLHSBeforeRHS(lhs: lhs, rhs: rhs)
            }
            // not equal, the oldest one comes first
            return lhsDistanceToPast < rhsDistanceToPast
        }
    }
    
    // MARK: - Properties
    
    /// The reminderId given to this log from the Hound database
    var reminderId: Int?
    
    /// The UUID of this reminder that is generated locally upon creation. Useful in identifying the reminder before/in the process of creating it
    var reminderUUID: UUID = UUID()
    
    private(set) var reminderCreated: Date = Date()
    private(set) var reminderCreatedBy: String = Constant.Class.Log.defaultUserId
    private(set) var reminderLastModified: Date?
    private(set) var reminderLastModifiedBy: String?
    
    /// This is a user selected label for the reminder. It dictates the name that is displayed in the UI for this reminder.
    var reminderActionTypeId: Int = Constant.Class.Reminder.defaultReminderActionTypeId
    
    var reminderActionType: ReminderActionType {
        return ReminderActionType.find(reminderActionTypeId: reminderActionTypeId)
    }
    
    private var storedReminderCustomActionName: String = ""
    var reminderCustomActionName: String {
        get {
            return storedReminderCustomActionName
        }
        set {
            storedReminderCustomActionName = String((newValue.trimmingCharacters(in: .whitespacesAndNewlines)).prefix(Constant.Class.Reminder.reminderCustomActionNameCharacterLimit))
        }
    }
    
    /// Tells the reminder what components to use to make sure its in the correct timing style. Changing this changes between countdown, weekly, monthly, and oneTime mode.
    private(set) var reminderType: ReminderType = Constant.Class.Reminder.defaultReminderType
    /// Changes reminderType invokes resetForNextAlarm if reminderType is different than the current one
    func changeReminderType(_ newReminderType: ReminderType) {
        if newReminderType != reminderType {
            // If switching to a different reminder type, reset all of thew components
            resetForNextAlarm()
        }
        
        reminderType = newReminderType
    }
    
    /// This is what the reminder should base its timing off it. This is either the last time a user responded to a reminder alarm or the last time a user changed a timing related property of the reminder. For example, 5 minutes into the timer you change the countdown from 30 minutes to 15. To start the timer fresh, having it count down from the moment it was changed, reset reminderExecutionBasis to Date()
    private(set) var reminderExecutionBasis: Date = Constant.Class.Reminder.defaultReminderExecutionBasis
    
    private(set) var reminderIsTriggerResult: Bool = false
    
    private var storedReminderIsEnabled: Bool = Constant.Class.Reminder.defaultReminderIsEnabled
    /// Whether or not the reminder  is enabled, if disabled all reminders will not fire.
    var reminderIsEnabled: Bool {
        get {
            storedReminderIsEnabled
        }
        set {
            // going from disable to enabled
            if reminderIsEnabled == false && newValue == true {
                resetForNextAlarm()
            }
            
            storedReminderIsEnabled = newValue
        }
    }
    
    var reminderRecipientUserIds: [String] = Constant.Class.Reminder.defaultReminderRecipientUserIds
    
    var reminderTimeZone: TimeZone = UserConfiguration.timeZone
    
    // Reminder Components
    
    private(set) var countdownComponents: CountdownComponents = CountdownComponents()
    private(set) var weeklyComponents: WeeklyComponents = WeeklyComponents()
    private(set) var monthlyComponents: MonthlyComponents = MonthlyComponents()
    private(set) var oneTimeComponents: OneTimeComponents = OneTimeComponents()
    private(set) var snoozeComponents: SnoozeComponents = SnoozeComponents()
    /// Components that are used to track an object to determine whether it was synced with the Hound server and whether it needs to be when the device comes back online
    private(set) var offlineModeComponents: OfflineModeComponents = OfflineModeComponents()
    
    // MARK: - Main
    
    init(
        reminderId: Int? = nil,
        reminderUUID: UUID? = nil,
        reminderCreated: Date? = nil,
        reminderCreatedBy: String? = nil,
        reminderLastModified: Date? = nil,
        reminderLastModifiedBy: String? = nil,
        reminderActionTypeId: Int? = nil,
        reminderCustomActionName: String? = nil,
        reminderType: ReminderType? = nil,
        reminderExecutionBasis: Date? = nil,
        reminderIsTriggerResult: Bool? = nil,
        reminderIsEnabled: Bool? = nil,
        reminderRecipientUserIds: [String]? = nil,
        reminderTimeZone: TimeZone? = nil,
        countdownComponents: CountdownComponents? = nil,
        weeklyComponents: WeeklyComponents? = nil,
        monthlyComponents: MonthlyComponents? = nil,
        oneTimeComponents: OneTimeComponents? = nil,
        snoozeComponents: SnoozeComponents? = nil,
        offlineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        
        self.reminderId = reminderId ?? self.reminderId
        self.reminderUUID = reminderUUID ?? self.reminderUUID
        self.reminderCreated = reminderCreated ?? self.reminderCreated
        self.reminderCreatedBy = reminderCreatedBy ?? self.reminderCreatedBy
        self.reminderLastModified = reminderLastModified ?? self.reminderLastModified
        self.reminderLastModifiedBy = reminderLastModifiedBy ?? self.reminderLastModifiedBy
        self.reminderActionTypeId = reminderActionTypeId ?? self.reminderActionTypeId
        self.reminderCustomActionName = reminderCustomActionName ?? self.reminderCustomActionName
        self.reminderType = reminderType ?? self.reminderType
        self.reminderExecutionBasis = reminderExecutionBasis ?? self.reminderExecutionBasis
        self.reminderIsTriggerResult = reminderIsTriggerResult ?? self.reminderIsTriggerResult
        self.reminderIsEnabled = reminderIsEnabled ?? self.reminderIsEnabled
        self.reminderRecipientUserIds = reminderRecipientUserIds ?? self.reminderRecipientUserIds
        self.reminderTimeZone = reminderTimeZone ?? self.reminderTimeZone
        
        self.countdownComponents = countdownComponents ?? self.countdownComponents
        self.weeklyComponents = weeklyComponents ?? self.weeklyComponents
        self.monthlyComponents = monthlyComponents ?? self.monthlyComponents
        self.oneTimeComponents = oneTimeComponents ?? self.oneTimeComponents
        self.snoozeComponents = snoozeComponents ?? self.snoozeComponents
        self.offlineModeComponents = offlineModeComponents ?? self.offlineModeComponents
    }
    
    /// Provide a dictionary literal of reminder properties to instantiate reminder. Optionally, provide a reminder to override with new properties from fromBody.
    convenience init?(fromBody: JSONResponseBody, reminderToOverride: Reminder?) {
        // Don't pull reminderId or reminderIsDeleted from reminderToOverride. A valid fromBody needs to provide this itself
        let reminderId: Int? = fromBody[Constant.Key.reminderId.rawValue] as? Int
        let reminderUUID: UUID? = UUID.fromString(UUIDString: fromBody[Constant.Key.reminderUUID.rawValue] as? String)
        let reminderCreated: Date? = (fromBody[Constant.Key.reminderCreated.rawValue] as? String)?.formatISO8601IntoDate()
        let reminderIsDeleted: Bool? = fromBody[Constant.Key.reminderIsDeleted.rawValue] as? Bool
        
        guard let reminderId = reminderId, let reminderUUID = reminderUUID, let reminderCreated = reminderCreated, let reminderIsDeleted = reminderIsDeleted else {
            return nil
        }
        
        guard reminderIsDeleted == false else {
            return nil
        }
        
        let reminderLastModified: Date? = (fromBody[Constant.Key.reminderLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        
        // If we have pulled an update from the server which is more outdated than our local change, then ignore the data from the server. Otherwise, the newer update takes precedence over our update
        if let reminderToOverride = reminderToOverride, let initialAttemptedSyncDate = reminderToOverride.offlineModeComponents.initialAttemptedSyncDate, initialAttemptedSyncDate >= reminderLastModified ?? reminderCreated {
            self.init(
                reminderId: reminderToOverride.reminderId,
                reminderUUID: reminderToOverride.reminderUUID,
                reminderCreated: reminderToOverride.reminderCreated,
                reminderCreatedBy: reminderToOverride.reminderCreatedBy,
                reminderLastModified: reminderToOverride.reminderLastModified,
                reminderLastModifiedBy: reminderToOverride.reminderLastModifiedBy,
                reminderActionTypeId: reminderToOverride.reminderActionTypeId,
                reminderCustomActionName: reminderToOverride.reminderCustomActionName,
                reminderType: reminderToOverride.reminderType,
                reminderExecutionBasis: reminderToOverride.reminderExecutionBasis,
                reminderIsTriggerResult: reminderToOverride.reminderIsTriggerResult,
                reminderIsEnabled: reminderToOverride.reminderIsEnabled,
                reminderRecipientUserIds: reminderToOverride.reminderRecipientUserIds,
                reminderTimeZone: reminderToOverride.reminderTimeZone,
                countdownComponents: reminderToOverride.countdownComponents,
                weeklyComponents: reminderToOverride.weeklyComponents,
                monthlyComponents: reminderToOverride.monthlyComponents,
                oneTimeComponents: reminderToOverride.oneTimeComponents,
                snoozeComponents: reminderToOverride.snoozeComponents,
                offlineModeComponents: reminderToOverride.offlineModeComponents
            )
            return
        }
        
        // if the reminder is the same, then we pull values from reminderToOverride
        // if the reminder is updated, then we pull values from fromBody
        // reminder
        let reminderCreatedBy: String? = fromBody[Constant.Key.reminderCreatedBy.rawValue] as? String ?? reminderToOverride?.reminderCreatedBy
        let reminderLastModifiedBy: String? = fromBody[Constant.Key.reminderLastModifiedBy.rawValue] as? String ?? reminderToOverride?.reminderLastModifiedBy
        
        let reminderActionTypeId: Int? = fromBody[Constant.Key.reminderActionTypeId.rawValue] as? Int ?? reminderToOverride?.reminderActionTypeId
        let reminderCustomActionName: String? = fromBody[Constant.Key.reminderCustomActionName.rawValue] as? String
        let reminderType: ReminderType? = {
            guard let reminderTypeString = fromBody[Constant.Key.reminderType.rawValue] as? String else {
                return nil
            }
            return ReminderType(rawValue: reminderTypeString)
        }() ?? reminderToOverride?.reminderType
        let reminderExecutionBasis: Date? = {
            guard let reminderExecutionBasisString = fromBody[Constant.Key.reminderExecutionBasis.rawValue] as? String else {
                return nil
            }
            return reminderExecutionBasisString.formatISO8601IntoDate()
        }() ?? reminderToOverride?.reminderExecutionBasis
        let reminderIsTriggerResult: Bool? = fromBody[Constant.Key.reminderIsTriggerResult.rawValue] as? Bool ?? reminderToOverride?.reminderIsTriggerResult
        let reminderIsEnabled: Bool? = fromBody[Constant.Key.reminderIsEnabled.rawValue] as? Bool ?? reminderToOverride?.reminderIsEnabled
        let reminderRecipientUserIds: [String]? = fromBody[Constant.Key.reminderRecipientUserIds.rawValue] as? [String] ?? reminderToOverride?.reminderRecipientUserIds
        let reminderTimeZone: TimeZone? = TimeZone.from(fromBody[Constant.Key.reminderTimeZone.rawValue] as? String) ?? reminderToOverride?.reminderTimeZone
        
        // reminderCustomActionName can be nil
        guard let reminderActionTypeId = reminderActionTypeId,
              let reminderCustomActionName = reminderCustomActionName,
              let reminderType = reminderType,
              let reminderExecutionBasis = reminderExecutionBasis,
              let reminderIsTriggerResult = reminderIsTriggerResult,
              let reminderIsEnabled = reminderIsEnabled,
              let reminderRecipientUserIds = reminderRecipientUserIds,
              let reminderTimeZone = reminderTimeZone else {
            return nil
        }
        
        let countdownComponents = CountdownComponents(fromBody: fromBody, componentToOverride: reminderToOverride?.countdownComponents)
        let weekdayComponents = WeeklyComponents(fromBody: fromBody, componentToOverride: reminderToOverride?.weeklyComponents)
        let monthlyComponents = MonthlyComponents(fromBody: fromBody, componentToOverride: reminderToOverride?.monthlyComponents)
        let oneTimeComponents = OneTimeComponents(fromBody: fromBody, componentToOverride: reminderToOverride?.oneTimeComponents)
        let snoozeComponents = SnoozeComponents(fromBody: fromBody, componentToOverride: reminderToOverride?.snoozeComponents)
        
        self.init(
            reminderId: reminderId,
            reminderUUID: reminderUUID,
            reminderCreated: reminderCreated,
            reminderCreatedBy: reminderCreatedBy,
            reminderLastModified: reminderLastModified,
            reminderLastModifiedBy: reminderLastModifiedBy,
            reminderActionTypeId: reminderActionTypeId,
            reminderCustomActionName: reminderCustomActionName,
            reminderType: reminderType,
            reminderExecutionBasis: reminderExecutionBasis,
            reminderIsTriggerResult: reminderIsTriggerResult,
            reminderIsEnabled: reminderIsEnabled,
            reminderRecipientUserIds: reminderRecipientUserIds,
            reminderTimeZone: reminderTimeZone,
            countdownComponents: countdownComponents,
            weeklyComponents: weekdayComponents,
            monthlyComponents: monthlyComponents,
            oneTimeComponents: oneTimeComponents,
            snoozeComponents: snoozeComponents,
            // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
            offlineModeComponents: nil
        )
    }
    
    // MARK: - Functions
    
    func readableRecurrance(displayTimeZone: TimeZone = UserConfiguration.timeZone) -> String {
        switch self.reminderType {
        case .countdown:
            return countdownComponents.readableRecurrance
        case .weekly:
            return weeklyComponents.readableRecurrance(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone, displayTimeZone: displayTimeZone)
        case .monthly:
            return monthlyComponents.readableRecurrence(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone, displayTimeZone: displayTimeZone)
        case .oneTime:
            return oneTimeComponents.readableRecurrance(displayTimeZone: displayTimeZone)
        }
    }
    // MARK: - Timing
    
    var reminderExecutionDate: Date? {
        guard reminderIsEnabled == true else {
            return nil
        }
        
        if snoozeComponents.isSnoozing, let snooze = snoozeComponents.executionInterval {
            return Date(timeInterval: snooze, since: reminderExecutionBasis)
        }
        
        switch reminderType {
        case .oneTime:
            return oneTimeComponents.oneTimeDate
        case .countdown:
            return Date(timeInterval: countdownComponents.executionInterval, since: reminderExecutionBasis)
        case .weekly:
            return weeklyComponents.nextExecutionDate(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone)
        case .monthly:
            return monthlyComponents.nextExecutionDate(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone)
        }
    }
    
    /// Restores the reminder to a state where it is ready for its next alarm. This resets reminderExecutionBasis, clears skippedDates, and clears snooze. Typically use if reminder's alarm executed and user responded to it or if reminder's timing has updated and needs a complete reset.
    func resetForNextAlarm() {
        reminderExecutionBasis = Date()
        
        snoozeComponents.changeExecutionInterval(nil)
        weeklyComponents.skippedDate = nil
        monthlyComponents.skippedDate = nil
    }
    
    /// Finds the date which the reminder should be transformed from isSkipping to not isSkipping. This is the date at which the skipped reminder would have occured.
    var disableIsSkippingDate: Date? {
        guard reminderIsEnabled && !snoozeComponents.isSnoozing else {
            return nil
        }
        
        if reminderType == .monthly && monthlyComponents.isSkipping == true {
            return monthlyComponents.notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone)
        }
        else if reminderType == .weekly && weeklyComponents.isSkipping == true {
            return weeklyComponents.notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone)
        }
        
        return nil
    }
    
    /// Call this function when a user driven action directly intends to enable the skip status of the weekly or monthy components. This function only timing related data, no logs are added or removed. Additioanlly, if oneTime is getting skipped, it must be deleted externally.
    func enableIsSkipping(skippedDate: Date?) {
        guard reminderIsEnabled else { return }
        
        switch reminderType {
        case .oneTime: break
            // oneTime can't skip
        case .countdown:
            resetForNextAlarm()
        case .weekly:
            weeklyComponents.skippedDate = skippedDate
        case .monthly:
            monthlyComponents.skippedDate = skippedDate
        }
    }
    
    /// Call this function when a user driven action directly intends to disable the skip status of the weekly or monthy components. This function only timing related data, no logs are added or removed.
    func disableIsSkipping() {
        guard reminderIsEnabled else { return }
        
        switch reminderType {
        case .oneTime: break
        case .countdown: break
        case .weekly:
            weeklyComponents.skippedDate = nil
        case .monthly:
            monthlyComponents.skippedDate = nil
        }
    }
    
}

extension Reminder {
    
    // MARK: - Duplicate
    
    /// Copys a reminder then removes/resets certain properties. This allows a reminder to be an independent copy of a reminder (aka a duplicate) instead of an exact 1:1 clone
    func duplicate() -> Reminder? {
        guard let duplicate = self.copy() as? Reminder else {
            return nil
        }
        
        duplicate.reminderId = nil
        duplicate.reminderUUID = UUID()
        duplicate.reminderExecutionBasis = Constant.Class.Reminder.defaultReminderExecutionBasis
        
        duplicate.resetForNextAlarm()
        
        return duplicate
    }
    
    // MARK: - Request
    
    /// Returns an array literal of the reminders's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody(dogUUID: UUID) -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.dogUUID.rawValue] = .string(dogUUID.uuidString)
        body[Constant.Key.reminderId.rawValue] = .int(reminderId)
        body[Constant.Key.reminderUUID.rawValue] = .string(reminderUUID.uuidString)
        body[Constant.Key.reminderCreated.rawValue] = .string(reminderCreated.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.reminderCreatedBy.rawValue] = .string(reminderCreatedBy)
        body[Constant.Key.reminderLastModified.rawValue] = .string(reminderLastModified?.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.reminderLastModifiedBy.rawValue] = .string(reminderLastModifiedBy)
        body[Constant.Key.reminderActionTypeId.rawValue] = .int(reminderActionTypeId)
        body[Constant.Key.reminderCustomActionName.rawValue] = .string(reminderCustomActionName)
        body[Constant.Key.reminderType.rawValue] = .string(reminderType.rawValue)
        body[Constant.Key.reminderExecutionBasis.rawValue] = .string(reminderExecutionBasis.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.reminderExecutionDate.rawValue] = .string(reminderExecutionDate?.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.reminderIsTriggerResult.rawValue] = .bool(reminderIsTriggerResult)
        body[Constant.Key.reminderIsEnabled.rawValue] = .bool(reminderIsEnabled)
        body[Constant.Key.reminderRecipientUserIds.rawValue] = .array(reminderRecipientUserIds.map { .string($0) })
        body[Constant.Key.reminderTimeZone.rawValue] = .string(reminderTimeZone.identifier)
        
        body.merge(countdownComponents.createBody()) { _, new in
            return new
        }
        body.merge(weeklyComponents.createBody()) { _, new in
            return new
        }
        body.merge(monthlyComponents.createBody()) { _, new in
            return new
        }
        body.merge(oneTimeComponents.createBody()) { _, new in
            return new
        }
        body.merge(snoozeComponents.createBody()) { _, new in
            return new
        }
        return body
    }
}
