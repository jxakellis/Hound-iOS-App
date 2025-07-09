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
    
    var segmentedControlIndex: Int {
        switch self {
        case .oneTime:
            return 0
        case .countdown:
            return 1
        case .weekly:
            return 2
        case .monthly:
            return 3
        }
    }
    
    var readableName: String {
        switch self {
        case .oneTime:
            return "Once"
        case .countdown:
            return "Recurring"
        case .weekly:
            return "Days of Week"
        case .monthly:
            return "Monthly"
        }
    }
}

final class Reminder: NSObject, NSCoding, NSCopying, Comparable {
    
    // TODO TRIGGERS diable editting of reminder if its a isTriggerResult
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Reminder()
        
        copy.reminderId = self.reminderId
        copy.reminderUUID = self.reminderUUID
        copy.reminderActionTypeId = self.reminderActionTypeId
        copy.reminderCustomActionName = self.reminderCustomActionName
        copy.reminderType = self.reminderType
        copy.reminderExecutionBasis = self.reminderExecutionBasis
        copy.reminderIsTriggerResult = self.reminderIsTriggerResult
        copy.storedReminderIsEnabled = self.storedReminderIsEnabled
        
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
        let decodedReminderId: Int? = aDecoder.decodeOptionalInteger(forKey: KeyConstant.reminderId.rawValue)
        let decodedReminderUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeOptionalString(forKey: KeyConstant.reminderUUID.rawValue))
        let decodedReminderActionTypeId: Int? = aDecoder.decodeOptionalInteger(forKey: KeyConstant.reminderActionTypeId.rawValue)
        let decodedReminderCustomActionName: String? = aDecoder.decodeOptionalString(forKey: KeyConstant.reminderCustomActionName.rawValue)
        let decodedReminderType: ReminderType? = ReminderType(rawValue: aDecoder.decodeOptionalString(forKey: KeyConstant.reminderType.rawValue) ?? ClassConstant.ReminderConstant.defaultReminderType.rawValue)
        let decodedReminderExecutionBasis: Date? = aDecoder.decodeOptionalObject(forKey: KeyConstant.reminderExecutionBasis.rawValue)
        let decodedReminderIsTriggerResult: Bool? = aDecoder.decodeOptionalBool(forKey: KeyConstant.reminderIsTriggerResult.rawValue)
        let decodedReminderIsEnabled: Bool? = aDecoder.decodeOptionalBool(forKey: KeyConstant.reminderIsEnabled.rawValue)
        let decodedCountdownComponents: CountdownComponents? = aDecoder.decodeOptionalObject(forKey: KeyConstant.countdownComponents.rawValue)
        let decodedWeeklyComponents: WeeklyComponents? = aDecoder.decodeOptionalObject(forKey: KeyConstant.weeklyComponents.rawValue)
        let decodedMonthlyComponents: MonthlyComponents? = aDecoder.decodeOptionalObject(forKey: KeyConstant.monthlyComponents.rawValue)
        let decodedOneTimeComponents: OneTimeComponents? = aDecoder.decodeOptionalObject(forKey: KeyConstant.oneTimeComponents.rawValue)
        let decodedSnoozeComponents: SnoozeComponents? = aDecoder.decodeOptionalObject(forKey: KeyConstant.snoozeComponents.rawValue)
        let decodedOfflineModeComponents: OfflineModeComponents? = aDecoder.decodeOptionalObject(forKey: KeyConstant.offlineModeComponents.rawValue)

        self.init(
            forReminderId: decodedReminderId,
            forReminderUUID: decodedReminderUUID,
            forReminderActionTypeId: decodedReminderActionTypeId,
            forReminderCustomActionName: decodedReminderCustomActionName,
            forReminderType: decodedReminderType,
            forReminderExecutionBasis: decodedReminderExecutionBasis,
            forReminderIsTriggerResult: decodedReminderIsTriggerResult,
            forReminderIsEnabled: decodedReminderIsEnabled,
            forCountdownComponents: decodedCountdownComponents,
            forWeeklyComponents: decodedWeeklyComponents,
            forMonthlyComponents: decodedMonthlyComponents,
            forOneTimeComponents: decodedOneTimeComponents,
            forSnoozeComponents: decodedSnoozeComponents,
            forOfflineModeComponents: decodedOfflineModeComponents
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        if let reminderId = reminderId {
            aCoder.encode(reminderId, forKey: KeyConstant.reminderId.rawValue)
        }
        aCoder.encode(reminderUUID.uuidString, forKey: KeyConstant.reminderUUID.rawValue)
        aCoder.encode(reminderActionTypeId, forKey: KeyConstant.reminderActionTypeId.rawValue)
        aCoder.encode(reminderCustomActionName, forKey: KeyConstant.reminderCustomActionName.rawValue)
        aCoder.encode(reminderType.rawValue, forKey: KeyConstant.reminderType.rawValue)
        aCoder.encode(reminderExecutionBasis, forKey: KeyConstant.reminderExecutionBasis.rawValue)
        aCoder.encode(reminderIsTriggerResult, forKey: KeyConstant.reminderIsTriggerResult.rawValue)
        aCoder.encode(reminderIsEnabled, forKey: KeyConstant.reminderIsEnabled.rawValue)
        aCoder.encode(countdownComponents, forKey: KeyConstant.countdownComponents.rawValue)
        aCoder.encode(weeklyComponents, forKey: KeyConstant.weeklyComponents.rawValue)
        aCoder.encode(monthlyComponents, forKey: KeyConstant.monthlyComponents.rawValue)
        aCoder.encode(oneTimeComponents, forKey: KeyConstant.oneTimeComponents.rawValue)
        aCoder.encode(snoozeComponents, forKey: KeyConstant.snoozeComponents.rawValue)
        aCoder.encode(offlineModeComponents, forKey: KeyConstant.offlineModeComponents.rawValue)
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Reminder, rhs: Reminder) -> Bool {
        // if one reminder is a trigger result and the other isn't, trigger should come second
        switch (lhs.reminderIsTriggerResult, rhs.reminderIsTriggerResult) {
        case (true, false):
            return false
        case (false, true):
            return true
        default:
            break
        }
        
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
        func isLHSReminderBeforeRHSReminder(lhs: Reminder, rhs: Reminder) -> Bool {
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
        
        switch lhs.reminderType {
        case .countdown:
            // both countdown
            let lhsExecutionInterval = lhs.countdownComponents.executionInterval
            let rhsExecutionInterval = rhs.countdownComponents.executionInterval
            
            guard lhsExecutionInterval != rhsExecutionInterval else {
                // if equal, then smaller reminderId comes first
                return isLHSReminderBeforeRHSReminder(lhs: lhs, rhs: rhs)
            }
            // shorter executionInterval comes first
            return lhsExecutionInterval < rhsExecutionInterval
        case .weekly:
            // both weekly
            // earlier in the day is listed first
            let lhsHour = lhs.weeklyComponents.localHour
            let rhsHour = rhs.weeklyComponents.localHour
            
            guard lhsHour != rhsHour else {
                // hours are equal
                let lhsMinute = lhs.weeklyComponents.localMinute
                let rhsMinute = rhs.weeklyComponents.localMinute
                
                guard lhsMinute != rhsMinute else {
                    // if equal, then smaller reminderId comes first
                    return isLHSReminderBeforeRHSReminder(lhs: lhs, rhs: rhs)
                }
                
                // smaller minute comes first
                return lhsMinute < rhsMinute
            }
            
            // smaller hour comes first
            return lhsHour < rhsHour
        case .monthly:
            // both monthly
            let lhsDay = lhs.monthlyComponents.UTCDay
            let rhsDay = rhs.monthlyComponents.UTCDay
            
            guard lhsDay != rhsDay else {
                // earliest in day comes first if same days
                let lhsHour = lhs.monthlyComponents.localHour
                let rhsHour = rhs.monthlyComponents.localHour
                
                guard lhsHour != rhsHour else {
                    // earliest in hour comes first if same hour
                    let lhsMinute = lhs.monthlyComponents.localMinute
                    let rhsMinute = rhs.monthlyComponents.localMinute
                    
                    guard lhsMinute != rhsMinute else {
                        // smaller remidnerId comes first
                        return isLHSReminderBeforeRHSReminder(lhs: lhs, rhs: rhs)
                    }
                    // smaller minute comes first
                    return lhsMinute < rhsMinute
                }
                
                // smaller hour comes first
                return lhsHour < rhsHour
            }
            // smaller day comes first
            return lhsDay < rhsDay
        case .oneTime:
            // both oneTime
            let lhsDistanceToPast = Date().distance(to: lhs.oneTimeComponents.oneTimeDate)
            let rhsDistanceToPast = Date().distance(to: rhs.oneTimeComponents.oneTimeDate)
            
            guard lhsDistanceToPast != rhsDistanceToPast else {
                // if equal, then smaller reminderId comes first
                return isLHSReminderBeforeRHSReminder(lhs: lhs, rhs: rhs)
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
    
    /// This is a user selected label for the reminder. It dictates the name that is displayed in the UI for this reminder.
    var reminderActionTypeId: Int = ClassConstant.ReminderConstant.defaultReminderActionTypeId
    
    var reminderActionType: ReminderActionType {
        return ReminderActionType.find(forReminderActionTypeId: reminderActionTypeId)
    }
    
    private var storedReminderCustomActionName: String = ""
    var reminderCustomActionName: String {
        get {
            return storedReminderCustomActionName
        }
        set {
            storedReminderCustomActionName = String((newValue.trimmingCharacters(in: .whitespacesAndNewlines)).prefix(ClassConstant.ReminderConstant.reminderCustomActionNameCharacterLimit))
        }
    }
    
    /// Tells the reminder what components to use to make sure its in the correct timing style. Changing this changes between countdown, weekly, monthly, and oneTime mode.
    private(set) var reminderType: ReminderType = ClassConstant.ReminderConstant.defaultReminderType
    /// Changes reminderType invokes resetForNextAlarm if reminderType is different than the current one
    func changeReminderType(forReminderType: ReminderType) {
        reminderType = forReminderType
        
        if forReminderType != reminderType {
            // If switching to a different reminder type, reset all of thew components
            resetForNextAlarm()
        }
    }
    
    /// This is what the reminder should base its timing off it. This is either the last time a user responded to a reminder alarm or the last time a user changed a timing related property of the reminder. For example, 5 minutes into the timer you change the countdown from 30 minutes to 15. To start the timer fresh, having it count down from the moment it was changed, reset reminderExecutionBasis to Date()
    private(set) var reminderExecutionBasis: Date = ClassConstant.ReminderConstant.defaultReminderExecutionBasis
    
    private(set) var reminderIsTriggerResult: Bool = false
    
    private var storedReminderIsEnabled: Bool = ClassConstant.ReminderConstant.defaultReminderIsEnabled
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
        forReminderId: Int? = nil,
        forReminderUUID: UUID? = nil,
        forReminderActionTypeId: Int? = nil,
        forReminderCustomActionName: String? = nil,
        forReminderType: ReminderType? = nil,
        forReminderExecutionBasis: Date? = nil,
        forReminderIsTriggerResult: Bool? = nil,
        forReminderIsEnabled: Bool? = nil,
        forCountdownComponents: CountdownComponents? = nil,
        forWeeklyComponents: WeeklyComponents? = nil,
        forMonthlyComponents: MonthlyComponents? = nil,
        forOneTimeComponents: OneTimeComponents? = nil,
        forSnoozeComponents: SnoozeComponents? = nil,
        forOfflineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        
        self.reminderId = forReminderId ?? reminderId
        self.reminderUUID = forReminderUUID ?? reminderUUID
        self.reminderActionTypeId = forReminderActionTypeId ?? reminderActionTypeId
        self.reminderCustomActionName = forReminderCustomActionName ?? reminderCustomActionName
        self.reminderType = forReminderType ?? reminderType
        self.reminderExecutionBasis = forReminderExecutionBasis ?? reminderExecutionBasis
        self.reminderIsTriggerResult = forReminderIsTriggerResult ?? reminderIsTriggerResult
        self.reminderIsEnabled = forReminderIsEnabled ?? reminderIsEnabled
        
        self.countdownComponents = forCountdownComponents ?? countdownComponents
        self.weeklyComponents = forWeeklyComponents ?? weeklyComponents
        self.monthlyComponents = forMonthlyComponents ?? monthlyComponents
        self.oneTimeComponents = forOneTimeComponents ?? oneTimeComponents
        self.snoozeComponents = forSnoozeComponents ?? snoozeComponents
        self.offlineModeComponents = forOfflineModeComponents ?? offlineModeComponents
    }
    
    /// Provide a dictionary literal of reminder properties to instantiate reminder. Optionally, provide a reminder to override with new properties from fromBody.
    convenience init?(fromBody: [String: Any?], reminderToOverride: Reminder?) {
        // Don't pull reminderId or reminderIsDeleted from reminderToOverride. A valid fromBody needs to provide this itself
        let reminderId: Int? = fromBody[KeyConstant.reminderId.rawValue] as? Int
        let reminderUUID: UUID? = UUID.fromString(forUUIDString: fromBody[KeyConstant.reminderUUID.rawValue] as? String)
        let reminderLastModified: Date? = (fromBody[KeyConstant.reminderLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        let reminderIsDeleted: Bool? = fromBody[KeyConstant.reminderIsDeleted.rawValue] as? Bool
        
        // The body needs an id, uuid, and isDeleted to be intrepreted as same, updated, or deleted. Otherwise, it is invalid
        guard let reminderId = reminderId, let reminderUUID = reminderUUID, let reminderLastModified = reminderLastModified, let reminderIsDeleted = reminderIsDeleted else {
            return nil
        }
        
        guard reminderIsDeleted == false else {
            // The reminder has been deleted. Doesn't matter if our offline mode any changes
            return nil
        }
        
        // If we have pulled an update from the server which is more outdated than our local change, then ignore the data from the server. Otherwise, the newer update takes precedence over our update
        if let reminderToOverride = reminderToOverride, let initialAttemptedSyncDate = reminderToOverride.offlineModeComponents.initialAttemptedSyncDate, initialAttemptedSyncDate >= reminderLastModified {
            self.init(
                forReminderId: reminderToOverride.reminderId,
                forReminderUUID: reminderToOverride.reminderUUID,
                forReminderActionTypeId: reminderToOverride.reminderActionTypeId,
                forReminderCustomActionName: reminderToOverride.reminderCustomActionName,
                forReminderType: reminderToOverride.reminderType,
                forReminderExecutionBasis: reminderToOverride.reminderExecutionBasis,
                forReminderIsTriggerResult: reminderToOverride.reminderIsTriggerResult,
                forReminderIsEnabled: reminderToOverride.reminderIsEnabled,
                forCountdownComponents: reminderToOverride.countdownComponents,
                forWeeklyComponents: reminderToOverride.weeklyComponents,
                forMonthlyComponents: reminderToOverride.monthlyComponents,
                forOneTimeComponents: reminderToOverride.oneTimeComponents,
                forSnoozeComponents: reminderToOverride.snoozeComponents,
                forOfflineModeComponents: reminderToOverride.offlineModeComponents
            )
            return
        }
        
        // if the reminder is the same, then we pull values from reminderToOverride
        // if the reminder is updated, then we pull values from fromBody
        // reminder
        let reminderActionTypeId: Int? = fromBody[KeyConstant.reminderActionTypeId.rawValue] as? Int ?? reminderToOverride?.reminderActionTypeId
        let reminderCustomActionName: String? = fromBody[KeyConstant.reminderCustomActionName.rawValue] as? String
        let reminderType: ReminderType? = {
            guard let reminderTypeString = fromBody[KeyConstant.reminderType.rawValue] as? String else {
                return nil
            }
            return ReminderType(rawValue: reminderTypeString)
        }() ?? reminderToOverride?.reminderType
        let reminderExecutionBasis: Date? = {
            guard let reminderExecutionBasisString = fromBody[KeyConstant.reminderExecutionBasis.rawValue] as? String else {
                return nil
            }
            return reminderExecutionBasisString.formatISO8601IntoDate()
        }() ?? reminderToOverride?.reminderExecutionBasis
        let reminderIsTriggerResult: Bool? = fromBody[KeyConstant.reminderIsTriggerResult.rawValue] as? Bool ?? reminderToOverride?.reminderIsTriggerResult
        let reminderIsEnabled: Bool? = fromBody[KeyConstant.reminderIsEnabled.rawValue] as? Bool ?? reminderToOverride?.reminderIsEnabled
        
        // no properties should be nil. Either a complete fromBody should be provided (i.e. no previousDogManagerSynchronization was used in query) or a potentially partial fromBody (i.e. previousDogManagerSynchronization used in query) should be passed with an dogReminderManagerToOverride
        // reminderCustomActionName can be nil
        guard let reminderActionTypeId = reminderActionTypeId, let reminderCustomActionName = reminderCustomActionName, let reminderType = reminderType, let reminderExecutionBasis = reminderExecutionBasis, let reminderIsTriggerResult = reminderIsTriggerResult, let reminderIsEnabled = reminderIsEnabled else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        // countdown
        let countdownExecutionInterval: Double? = fromBody[KeyConstant.countdownExecutionInterval.rawValue] as? Double ?? reminderToOverride?.countdownComponents.executionInterval
        
        guard let countdownExecutionInterval = countdownExecutionInterval else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        // weekly
        let weeklyUTCHour: Int? = fromBody[KeyConstant.weeklyUTCHour.rawValue] as? Int ?? reminderToOverride?.weeklyComponents.UTCHour
        let weeklyUTCMinute: Int? = fromBody[KeyConstant.weeklyUTCMinute.rawValue] as? Int ?? reminderToOverride?.weeklyComponents.UTCMinute
        let weeklySkippedDate: Date? = {
            guard let weeklySkippedDateString = fromBody[KeyConstant.weeklySkippedDate.rawValue] as? String else {
                return nil
            }
            return weeklySkippedDateString.formatISO8601IntoDate()
        }() ?? reminderToOverride?.weeklyComponents.skippedDate
        let weeklySunday: Bool? = fromBody[KeyConstant.weeklySunday.rawValue] as? Bool ?? reminderToOverride?.weeklyComponents.weekdays.contains(1)
        let weeklyMonday: Bool? = fromBody[KeyConstant.weeklyMonday.rawValue] as? Bool ?? reminderToOverride?.weeklyComponents.weekdays.contains(2)
        let weeklyTuesday: Bool? = fromBody[KeyConstant.weeklyTuesday.rawValue] as? Bool ?? reminderToOverride?.weeklyComponents.weekdays.contains(3)
        let weeklyWednesday: Bool? = fromBody[KeyConstant.weeklyWednesday.rawValue] as? Bool ?? reminderToOverride?.weeklyComponents.weekdays.contains(4)
        let weeklyThursday: Bool? = fromBody[KeyConstant.weeklyThursday.rawValue] as? Bool ?? reminderToOverride?.weeklyComponents.weekdays.contains(5)
        let weeklyFriday: Bool? = fromBody[KeyConstant.weeklyFriday.rawValue] as? Bool ?? reminderToOverride?.weeklyComponents.weekdays.contains(6)
        let weeklySaturday: Bool? = fromBody[KeyConstant.weeklySaturday.rawValue] as? Bool ?? reminderToOverride?.weeklyComponents.weekdays.contains(7)
        
        // weeklySkippedDate can be nil
        guard let weeklyUTCHour = weeklyUTCHour, let weeklyUTCMinute = weeklyUTCMinute, let weeklySunday = weeklySunday, let weeklyMonday = weeklyMonday, let weeklyTuesday = weeklyTuesday, let weeklyWednesday = weeklyWednesday, let weeklyThursday = weeklyThursday, let weeklyFriday = weeklyFriday, let weeklySaturday = weeklySaturday else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        // monthly
        let monthlyUTCDay: Int? = fromBody[KeyConstant.monthlyUTCDay.rawValue] as? Int ?? reminderToOverride?.monthlyComponents.UTCDay
        let monthlyUTCHour: Int? = fromBody[KeyConstant.monthlyUTCHour.rawValue] as? Int ?? reminderToOverride?.monthlyComponents.UTCHour
        let monthlyUTCMinute: Int? = fromBody[KeyConstant.monthlyUTCMinute.rawValue] as? Int ?? reminderToOverride?.monthlyComponents.UTCMinute
        let monthlySkippedDate: Date? = {
            guard let monthlySkippedDateString = fromBody[KeyConstant.monthlySkippedDate.rawValue] as? String else {
                return nil
            }
            return monthlySkippedDateString.formatISO8601IntoDate()
        }() ?? reminderToOverride?.monthlyComponents.skippedDate
        
        // monthlySkippedDate can be nil
        guard let monthlyUTCDay = monthlyUTCDay, let monthlyUTCHour = monthlyUTCHour, let monthlyUTCMinute = monthlyUTCMinute else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        // one time
        let oneTimeDate: Date? = {
            guard let oneTimeDateString = fromBody[KeyConstant.oneTimeDate.rawValue] as? String else {
                return nil
            }
            return oneTimeDateString.formatISO8601IntoDate()
        }() ?? reminderToOverride?.oneTimeComponents.oneTimeDate
        
        guard let oneTimeDate = oneTimeDate else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        // snooze
        
        let snoozeExecutionInterval = fromBody[KeyConstant.snoozeExecutionInterval.rawValue] as? Double ?? reminderToOverride?.snoozeComponents.executionInterval
        
        // snoozeExecutionInterval can be nil
        
        self.init(
            forReminderId: reminderId,
            forReminderUUID: reminderUUID,
            forReminderActionTypeId: reminderActionTypeId,
            forReminderCustomActionName: reminderCustomActionName,
            forReminderType: reminderType,
            forReminderExecutionBasis: reminderExecutionBasis,
            forReminderIsTriggerResult: reminderIsTriggerResult,
            forReminderIsEnabled: reminderIsEnabled,
            forCountdownComponents: CountdownComponents(forExecutionInterval: countdownExecutionInterval),
            forWeeklyComponents: WeeklyComponents(
                UTCHour: weeklyUTCHour,
                UTCMinute: weeklyUTCMinute,
                skippedDate: weeklySkippedDate,
                sunday: weeklySunday,
                monday: weeklyMonday,
                tuesday: weeklyTuesday,
                wednesday: weeklyWednesday,
                thursday: weeklyThursday,
                friday: weeklyFriday,
                saturday: weeklySaturday
            ), forMonthlyComponents: MonthlyComponents(
                UTCDay: monthlyUTCDay,
                UTCHour: monthlyUTCHour,
                UTCMinute: monthlyUTCMinute,
                skippedDate: monthlySkippedDate
            ), forOneTimeComponents: OneTimeComponents(
                date: oneTimeDate
            ), forSnoozeComponents: SnoozeComponents(
                executionInterval: snoozeExecutionInterval
                // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
            ), forOfflineModeComponents: nil
        )
    }
    
    // MARK: - Timing
    
    var intervalRemaining: Double? {
        guard snoozeComponents.executionInterval == nil else {
            return snoozeComponents.executionInterval
        }
        
        switch reminderType {
        case .oneTime:
            return Date().distance(to: oneTimeComponents.oneTimeDate)
        case .countdown:
            // the time is supposed to countdown for minus the time it has countdown
            return countdownComponents.executionInterval
        case .weekly:
            if self.reminderExecutionBasis.distance(to: self.weeklyComponents.previousExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis)) > 0 {
                return nil
            }
            else {
                return Date().distance(to: self.weeklyComponents.nextExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis))
            }
        case .monthly:
            if self.reminderExecutionBasis.distance(to:
                                                        self.monthlyComponents.previousExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis)) > 0 {
                return nil
            }
            else {
                return Date().distance(to: self.monthlyComponents.nextExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis))
            }
        }
    }
    
    var reminderExecutionDate: Date? {
        // the reminder will not go off if disabled or the family is paused
        guard reminderIsEnabled == true else {
            return nil
        }
        
        guard let intervalRemaining = intervalRemaining else {
            // If the intervalRemaining is nil than means there is no time left
            return Date()
        }
        
        guard snoozeComponents.executionInterval == nil else {
            return Date(timeInterval: intervalRemaining, since: reminderExecutionBasis)
        }
        
        switch reminderType {
        case .oneTime:
            return oneTimeComponents.oneTimeDate
        case .countdown:
            return Date(timeInterval: intervalRemaining, since: reminderExecutionBasis)
        case .weekly:
            return weeklyComponents.nextExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis)
        case .monthly:
            return monthlyComponents.nextExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis)
        }
    }
    
    /// Restores the reminder to a state where it is ready for its next alarm. This resets reminderExecutionBasis, clears skippedDates, and clears snooze. Typically use if reminder's alarm executed and user responded to it or if reminder's timing has updated and needs a complete reset.
    func resetForNextAlarm() {
        reminderExecutionBasis = Date()
        
        snoozeComponents.executionInterval = nil
        weeklyComponents.skippedDate = nil
        monthlyComponents.skippedDate = nil
    }
    
    /// Finds the date which the reminder should be transformed from isSkipping to not isSkipping. This is the date at which the skipped reminder would have occured.
    var disableIsSkippingDate: Date? {
        guard reminderIsEnabled && snoozeComponents.executionInterval == nil else {
            return nil
        }
        
        if reminderType == .monthly && monthlyComponents.isSkipping == true {
            return monthlyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
        }
        else if reminderType == .weekly && weeklyComponents.isSkipping == true {
            return weeklyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
        }
        else {
            return nil
        }
    }
    
    /// Call this function when a user driven action directly intends to enable the skip status of the weekly or monthy components. This function only timing related data, no logs are added or removed. Additioanlly, if oneTime is getting skipped, it must be deleted externally.
    func enableIsSkipping(forSkippedDate: Date?) {
        // can't change is skipping on a disabled reminder. nothing to skip.
        guard reminderIsEnabled == true else { return }
        
        switch reminderType {
        case .oneTime: break
            // oneTime can't skip
        case .countdown:
            // countdown can skip
            resetForNextAlarm()
        case .weekly:
            // weekly can skip
            weeklyComponents.skippedDate = forSkippedDate
        case .monthly:
            // monthly can skip
            monthlyComponents.skippedDate = forSkippedDate
        }
    }
    
    /// Call this function when a user driven action directly intends to disable the skip status of the weekly or monthy components. This function only timing related data, no logs are added or removed.
    func disableIsSkipping() {
        // can't change is skipping on a disabled reminder. nothing to unskip.
        guard reminderIsEnabled == true else { return }
        
        switch reminderType {
        case .oneTime: break
            // oneTim can't unskip
        case .countdown: break
            // countdown can't unskip, only way to skip a countdown reminder is to reset it to restart its countdown
        case .weekly:
            // weekly can unskip
            weeklyComponents.skippedDate = nil
        case .monthly:
            // monthly can unskip
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
        duplicate.reminderExecutionBasis = ClassConstant.ReminderConstant.defaultReminderExecutionBasis
        
        duplicate.snoozeComponents = SnoozeComponents()
        duplicate.offlineModeComponents = OfflineModeComponents()
        
        duplicate.resetForNextAlarm()
        
        return duplicate
    }
    
    // MARK: - Compare
    
    /// Returns true if all the server synced properties for the reminder are the same. This includes all the base properties here (yes the reminderId too) and the reminder components for the corresponding reminderActionTypeId
    func isSame(asReminder reminder: Reminder) -> Bool {
        if reminderId != reminder.reminderId {
            return false
        }
        else if reminderUUID != reminder.reminderUUID {
            return false
        }
        else if reminderActionTypeId != reminder.reminderActionTypeId {
            return false
        }
        else if reminderCustomActionName != reminder.reminderCustomActionName {
            return false
        }
        // reminder types (countdown, weekly, monthly, one time)
        else if reminderType != reminder.reminderType {
            return false
        }
        else if reminderExecutionBasis != reminder.reminderExecutionBasis {
            return false
        }
        else if reminderIsEnabled != reminder.reminderIsEnabled {
            return false
        }
        else if reminderIsTriggerResult != reminder.reminderIsTriggerResult {
            return false
        }
        
        // known at this point that the reminderTypes are the same
        switch reminderType {
        case .countdown:
            if countdownComponents.executionInterval != reminder.countdownComponents.executionInterval {
                return false
            }
        case .weekly:
            if weeklyComponents.UTCHour != reminder.weeklyComponents.UTCHour {
                return false
            }
            else if weeklyComponents.UTCMinute != reminder.weeklyComponents.UTCMinute {
                return false
            }
            else if weeklyComponents.weekdays != reminder.weeklyComponents.weekdays {
                return false
            }
            else if weeklyComponents.isSkipping != reminder.weeklyComponents.isSkipping {
                return false
            }
            else if weeklyComponents.skippedDate != reminder.weeklyComponents.skippedDate {
                return false
            }
        case .monthly:
            if monthlyComponents.UTCHour != reminder.monthlyComponents.UTCHour {
                return false
            }
            else if monthlyComponents.UTCMinute != reminder.monthlyComponents.UTCMinute {
                return false
            }
            else if monthlyComponents.UTCDay != reminder.monthlyComponents.UTCDay {
                return false
            }
            else if monthlyComponents.isSkipping != reminder.monthlyComponents.isSkipping {
                return false
            }
            else if monthlyComponents.skippedDate != reminder.monthlyComponents.skippedDate {
                return false
            }
        case .oneTime:
            if oneTimeComponents.oneTimeDate != reminder.oneTimeComponents.oneTimeDate {
                return false
            }
        }
        
        if snoozeComponents.executionInterval != reminder.snoozeComponents.executionInterval {
            return false
        }
        
        return true
    }
    
    // MARK: - Request
    
    /// Returns an array literal of the reminders's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody(forDogUUID: UUID) -> [String: CompatibleDataTypeForJSON?] {
        var body: [String: CompatibleDataTypeForJSON?] = [:]
        body[KeyConstant.dogUUID.rawValue] = forDogUUID.uuidString
        body[KeyConstant.reminderId.rawValue] = reminderId
        body[KeyConstant.reminderUUID.rawValue] = reminderUUID.uuidString
        body[KeyConstant.reminderActionTypeId.rawValue] = reminderActionTypeId
        body[KeyConstant.reminderCustomActionName.rawValue] = reminderCustomActionName
        body[KeyConstant.reminderType.rawValue] = reminderType.rawValue
        body[KeyConstant.reminderExecutionBasis.rawValue] = reminderExecutionBasis.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.reminderExecutionDate.rawValue] = reminderExecutionDate?.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.reminderIsTriggerResult.rawValue] = reminderIsTriggerResult
        body[KeyConstant.reminderIsEnabled.rawValue] = reminderIsEnabled
        
        // snooze
        body[KeyConstant.snoozeExecutionInterval.rawValue] = snoozeComponents.executionInterval
        
        // countdown
        body[KeyConstant.countdownExecutionInterval.rawValue] = countdownComponents.executionInterval
        
        // weekly
        body[KeyConstant.weeklyUTCHour.rawValue] = weeklyComponents.UTCHour
        body[KeyConstant.weeklyUTCMinute.rawValue] = weeklyComponents.UTCMinute
        body[KeyConstant.weeklySkippedDate.rawValue] = weeklyComponents.skippedDate?.ISO8601FormatWithFractionalSeconds()
        
        body[KeyConstant.weeklySunday.rawValue] = false
        body[KeyConstant.weeklyMonday.rawValue] = false
        body[KeyConstant.weeklyTuesday.rawValue] = false
        body[KeyConstant.weeklyWednesday.rawValue] = false
        body[KeyConstant.weeklyThursday.rawValue] = false
        body[KeyConstant.weeklyFriday.rawValue] = false
        body[KeyConstant.weeklySaturday.rawValue] = false
        
        for weekday in weeklyComponents.weekdays {
            switch weekday {
            case 1:
                body[KeyConstant.weeklySunday.rawValue] = true
            case 2:
                body[KeyConstant.weeklyMonday.rawValue] = true
            case 3:
                body[KeyConstant.weeklyTuesday.rawValue] = true
            case 4:
                body[KeyConstant.weeklyWednesday.rawValue] = true
            case 5:
                body[KeyConstant.weeklyThursday.rawValue] = true
            case 6:
                body[KeyConstant.weeklyFriday.rawValue] = true
            case 7:
                body[KeyConstant.weeklySaturday.rawValue] = true
            default:
                continue
            }
        }
        
        // monthly
        body[KeyConstant.monthlyUTCDay.rawValue] = monthlyComponents.UTCDay
        body[KeyConstant.monthlyUTCHour.rawValue] = monthlyComponents.UTCHour
        body[KeyConstant.monthlyUTCMinute.rawValue] = monthlyComponents.UTCMinute
        body[KeyConstant.monthlySkippedDate.rawValue] = monthlyComponents.skippedDate?.ISO8601FormatWithFractionalSeconds()
        
        // one time
        body[KeyConstant.oneTimeDate.rawValue] = oneTimeComponents.oneTimeDate.ISO8601FormatWithFractionalSeconds()
        
        return body
    }
}
