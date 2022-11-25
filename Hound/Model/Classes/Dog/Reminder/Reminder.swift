//
//  Remindert.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
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
}

final class Reminder: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Reminder()
        
        copy.reminderId = self.reminderId
        copy.reminderAction = self.reminderAction
        copy.reminderCustomActionName = self.reminderCustomActionName
        
        copy.countdownComponents = self.countdownComponents.copy() as? CountdownComponents ?? CountdownComponents()
        copy.weeklyComponents = self.weeklyComponents.copy() as? WeeklyComponents ?? WeeklyComponents()
        copy.monthlyComponents = self.monthlyComponents.copy() as? MonthlyComponents ?? MonthlyComponents()
        copy.oneTimeComponents = self.oneTimeComponents.copy() as? OneTimeComponents ?? OneTimeComponents()
        copy.snoozeComponents = self.snoozeComponents.copy() as? SnoozeComponents ?? SnoozeComponents()
        copy.storedReminderType = self.storedReminderType
        
        copy.reminderExecutionBasis = self.reminderExecutionBasis
        copy.storedReminderAlarmTimer = self.storedReminderAlarmTimer
        copy.storedReminderDisableIsSkippingTimer = self.storedReminderDisableIsSkippingTimer
        
        copy.storedReminderIsEnabled = self.storedReminderIsEnabled
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        reminderId = aDecoder.decodeInteger(forKey: KeyConstant.reminderId.rawValue)
        // shift reminderId of 0 to proper placeholder of -1
        reminderId = reminderId >= 1 ? reminderId : -1
        
        reminderAction = ReminderAction(rawValue: aDecoder.decodeObject(forKey: KeyConstant.reminderAction.rawValue) as? String ?? ClassConstant.ReminderConstant.defaultReminderAction.rawValue) ?? reminderAction
        reminderCustomActionName = aDecoder.decodeObject(forKey: KeyConstant.reminderCustomActionName.rawValue) as? String ?? reminderCustomActionName
        
        countdownComponents = aDecoder.decodeObject(forKey: KeyConstant.countdownComponents.rawValue) as? CountdownComponents ?? countdownComponents
        weeklyComponents = aDecoder.decodeObject(forKey: KeyConstant.weeklyComponents.rawValue) as?  WeeklyComponents ?? weeklyComponents
        monthlyComponents = aDecoder.decodeObject(forKey: KeyConstant.monthlyComponents.rawValue) as?  MonthlyComponents ?? monthlyComponents
        oneTimeComponents = aDecoder.decodeObject(forKey: KeyConstant.oneTimeComponents.rawValue) as? OneTimeComponents ?? oneTimeComponents
        snoozeComponents = aDecoder.decodeObject(forKey: KeyConstant.snoozeComponents.rawValue) as? SnoozeComponents ?? snoozeComponents
        
        storedReminderType = ReminderType(rawValue: aDecoder.decodeObject(forKey: KeyConstant.reminderType.rawValue) as? String ?? ClassConstant.ReminderConstant.defaultReminderType.rawValue) ?? storedReminderType
        reminderExecutionBasis = aDecoder.decodeObject(forKey: KeyConstant.reminderExecutionBasis.rawValue) as? Date ?? reminderExecutionBasis
        reminderIsEnabled = aDecoder.decodeBool(forKey: KeyConstant.reminderIsEnabled.rawValue)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(reminderId, forKey: KeyConstant.reminderId.rawValue)
        aCoder.encode(reminderAction.rawValue, forKey: KeyConstant.reminderAction.rawValue)
        aCoder.encode(reminderCustomActionName, forKey: KeyConstant.reminderCustomActionName.rawValue)
        
        aCoder.encode(countdownComponents, forKey: KeyConstant.countdownComponents.rawValue)
        aCoder.encode(weeklyComponents, forKey: KeyConstant.weeklyComponents.rawValue)
        aCoder.encode(monthlyComponents, forKey: KeyConstant.monthlyComponents.rawValue)
        aCoder.encode(oneTimeComponents, forKey: KeyConstant.oneTimeComponents.rawValue)
        aCoder.encode(snoozeComponents, forKey: KeyConstant.snoozeComponents.rawValue)
        aCoder.encode(storedReminderType.rawValue, forKey: KeyConstant.reminderType.rawValue)
        
        aCoder.encode(reminderExecutionBasis, forKey: KeyConstant.reminderExecutionBasis.rawValue)
        
        aCoder.encode(reminderIsEnabled, forKey: KeyConstant.reminderIsEnabled.rawValue)
    }
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    /// Provide a dictionary literal of reminder properties to instantiate reminder. Optionally, provide a reminder to override with new properties from reminderBody.
    convenience init?(forReminderBody reminderBody: [String: Any], overrideReminder: Reminder?) {
        // Don't pull reminderId or reminderIsDeleted from overrideReminder. A valid reminderBody needs to provide this itself
        let reminderId: Int? = reminderBody[KeyConstant.reminderId.rawValue] as? Int
        let reminderIsDeleted: Bool? = reminderBody[KeyConstant.reminderIsDeleted.rawValue] as? Bool
        
        // a reminder body needs a reminder and logIsDeleted to be intrepeted as same, updated, or deleted
        guard let reminderId = reminderId, let reminderIsDeleted = reminderIsDeleted else {
            // couldn't construct essential components to intrepret reminder
            return nil
        }
        
        guard reminderIsDeleted == false else {
            // the reminder has been deleted
            return nil
        }
        
        // if the reminder is the same, then we pull values from overrideReminder
        // if the reminder is updated, then we pull values from reminderBody
        // reminder
        let reminderAction: ReminderAction? = {
            guard let reminderActionString = reminderBody[KeyConstant.reminderAction.rawValue] as? String else {
                return nil
            }
            return ReminderAction(rawValue: reminderActionString)
        }() ?? overrideReminder?.reminderAction
        let reminderCustomActionName: String? = reminderBody[KeyConstant.reminderCustomActionName.rawValue] as? String
        let reminderType: ReminderType? = {
            guard let reminderTypeString = reminderBody[KeyConstant.reminderType.rawValue] as? String else {
                return nil
            }
            return ReminderType(rawValue: reminderTypeString)
        }() ?? overrideReminder?.reminderType
        let reminderExecutionBasis: Date? = {
            guard let reminderExecutionBasisString = reminderBody[KeyConstant.reminderExecutionBasis.rawValue] as? String else {
                return nil
            }
            return RequestUtils.dateFormatter(fromISO8601String: reminderExecutionBasisString)
        }() ?? overrideReminder?.reminderExecutionBasis
        let reminderIsEnabled: Bool? = reminderBody[KeyConstant.reminderIsEnabled.rawValue] as? Bool ?? overrideReminder?.reminderIsEnabled
        
        // no properties should be nil. Either a complete reminderBody should be provided (i.e. no previousDogManagerSynchronization was used in query) or a potentially partial reminderBody (i.e. previousDogManagerSynchronization used in query) should be passed with an overrideReminderManager
        // reminderCustomActionName can be nil
        guard let reminderAction = reminderAction, let reminderCustomActionName = reminderCustomActionName, let reminderType = reminderType, let reminderExecutionBasis = reminderExecutionBasis, let reminderIsEnabled = reminderIsEnabled else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        // countdown
        let countdownExecutionInterval: TimeInterval? = reminderBody[KeyConstant.countdownExecutionInterval.rawValue] as? TimeInterval ?? overrideReminder?.countdownComponents.executionInterval
        
        guard let countdownExecutionInterval = countdownExecutionInterval else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        // weekly
        let weeklyUTCHour: Int? = reminderBody[KeyConstant.weeklyUTCHour.rawValue] as? Int ?? overrideReminder?.weeklyComponents.UTCHour
        let weeklyUTCMinute: Int? = reminderBody[KeyConstant.weeklyUTCMinute.rawValue] as? Int ?? overrideReminder?.weeklyComponents.UTCMinute
        let weeklySkippedDate: Date? = {
            guard let weeklySkippedDateString = reminderBody[KeyConstant.weeklySkippedDate.rawValue] as? String else {
                return nil
            }
            return RequestUtils.dateFormatter(fromISO8601String: weeklySkippedDateString)
        }() ?? overrideReminder?.weeklyComponents.skippedDate
        let weeklySunday: Bool? = reminderBody[KeyConstant.weeklySunday.rawValue] as? Bool ?? overrideReminder?.weeklyComponents.weekdays.contains(1)
        let weeklyMonday: Bool? = reminderBody[KeyConstant.weeklyMonday.rawValue] as? Bool ?? overrideReminder?.weeklyComponents.weekdays.contains(2)
        let weeklyTuesday: Bool? = reminderBody[KeyConstant.weeklyTuesday.rawValue] as? Bool ?? overrideReminder?.weeklyComponents.weekdays.contains(3)
        let weeklyWednesday: Bool? = reminderBody[KeyConstant.weeklyWednesday.rawValue] as? Bool ?? overrideReminder?.weeklyComponents.weekdays.contains(4)
        let weeklyThursday: Bool? = reminderBody[KeyConstant.weeklyThursday.rawValue] as? Bool ?? overrideReminder?.weeklyComponents.weekdays.contains(5)
        let weeklyFriday: Bool? = reminderBody[KeyConstant.weeklyFriday.rawValue] as? Bool ?? overrideReminder?.weeklyComponents.weekdays.contains(6)
        let weeklySaturday: Bool? = reminderBody[KeyConstant.weeklySaturday.rawValue] as? Bool ?? overrideReminder?.weeklyComponents.weekdays.contains(7)
        
        // weeklySkippedDate can be nil
        guard let weeklyUTCHour = weeklyUTCHour, let weeklyUTCMinute = weeklyUTCMinute, let weeklySunday = weeklySunday, let weeklyMonday = weeklyMonday, let weeklyTuesday = weeklyTuesday, let weeklyWednesday = weeklyWednesday, let weeklyThursday = weeklyThursday, let weeklyFriday = weeklyFriday, let weeklySaturday = weeklySaturday else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        // monthly
        let monthlyUTCDay: Int? = reminderBody[KeyConstant.monthlyUTCDay.rawValue] as? Int ?? overrideReminder?.monthlyComponents.UTCDay
        let monthlyUTCHour: Int? = reminderBody[KeyConstant.monthlyUTCHour.rawValue] as? Int ?? overrideReminder?.monthlyComponents.UTCHour
        let monthlyUTCMinute: Int? = reminderBody[KeyConstant.monthlyUTCMinute.rawValue] as? Int ?? overrideReminder?.monthlyComponents.UTCMinute
        let monthlySkippedDate: Date? = {
            guard let monthlySkippedDateString = reminderBody[KeyConstant.monthlySkippedDate.rawValue] as? String else {
                return nil
            }
            return RequestUtils.dateFormatter(fromISO8601String: monthlySkippedDateString)
        }() ?? overrideReminder?.monthlyComponents.skippedDate
        
        // monthlySkippedDate can be nil
        guard let monthlyUTCDay = monthlyUTCDay, let monthlyUTCHour = monthlyUTCHour, let monthlyUTCMinute = monthlyUTCMinute else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        // one time
        let oneTimeDate: Date? = {
            guard let oneTimeDateString = reminderBody[KeyConstant.oneTimeDate.rawValue] as? String else {
                return nil
            }
            return RequestUtils.dateFormatter(fromISO8601String: oneTimeDateString)
        }() ?? overrideReminder?.oneTimeComponents.oneTimeDate
        
        guard let oneTimeDate = oneTimeDate else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        // snooze
        
        let snoozeExecutionInterval = reminderBody[KeyConstant.snoozeExecutionInterval.rawValue] as? TimeInterval ?? overrideReminder?.snoozeComponents.executionInterval
        
        // snoozeExecutionInterval can be nil
        guard true else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        self.init()
        self.reminderId = reminderId
        self.reminderAction = reminderAction
        self.reminderCustomActionName = reminderCustomActionName
        self.storedReminderType = reminderType
        self.reminderExecutionBasis = reminderExecutionBasis
        self.reminderIsEnabled = reminderIsEnabled
        self.reminderAlarmTimer = overrideReminder?.reminderAlarmTimer
        self.reminderDisableIsSkippingTimer = overrideReminder?.reminderDisableIsSkippingTimer
        
        self.countdownComponents = CountdownComponents(executionInterval: countdownExecutionInterval)

        self.weeklyComponents = WeeklyComponents(UTCHour: weeklyUTCHour, UTCMinute: weeklyUTCMinute, skippedDate: weeklySkippedDate, sunday: weeklySunday, monday: weeklyMonday, tuesday: weeklyTuesday, wednesday: weeklyWednesday, thursday: weeklyThursday, friday: weeklyFriday, saturday: weeklySaturday)
        
        self.monthlyComponents = MonthlyComponents(UTCDay: monthlyUTCDay, UTCHour: monthlyUTCHour, UTCMinute: monthlyUTCMinute, skippedDate: monthlySkippedDate)
        
        self.oneTimeComponents = OneTimeComponents(date: oneTimeDate)
        
        self.snoozeComponents = SnoozeComponents(executionInterval: snoozeExecutionInterval)
    }
    
    // MARK: - Properties
    
    // General
    
    var reminderId: Int = ClassConstant.ReminderConstant.defaultReminderId
    
    /// This is a user selected label for the reminder. It dictates the name that is displayed in the UI for this reminder.
    var reminderAction: ReminderAction = ClassConstant.ReminderConstant.defaultReminderAction
    
    /// If the reminder's type is custom, this is the name for it.
    private(set) var reminderCustomActionName: String = ClassConstant.ReminderConstant.defaultReminderCustomActionName
    func changeReminderCustomActionName(forReminderCustomActionName: String) throws {
        guard forReminderCustomActionName.count <= ClassConstant.ReminderConstant.reminderCustomActionNameCharacterLimit else {
            throw ErrorConstant.ReminderError.reminderCustomActionNameCharacterLimitExceeded
        }
        
        reminderCustomActionName = forReminderCustomActionName
    }
    
    // Timing
    
    var storedReminderType: ReminderType = ClassConstant.ReminderConstant.defaultReminderType
    /// Tells the reminder what components to use to make sure its in the correct timing style. Changing this changes between countdown, weekly, monthly, and oneTime mode.
    var reminderType: ReminderType {
        get {
            return storedReminderType
        }
        set (newReminderType) {
            guard newReminderType != storedReminderType else {
                return
            }
            resetForNextAlarm()
        
            storedReminderType = newReminderType
        }
    }
    
    /// This is what the reminder should base its timing off it. This is either the last time a user responded to a reminder alarm or the last time a user changed a timing related property of the reminder. For example, 5 minutes into the timer you change the countdown from 30 minutes to 15. To start the timer fresh, having it count down from the moment it was changed, reset reminderExecutionBasis to Date()
    var reminderExecutionBasis: Date = ClassConstant.ReminderConstant.defaultReminderExecutionBasis
    
    // Enable
    
    private var storedReminderIsEnabled: Bool = ClassConstant.ReminderConstant.defaultReminderIsEnabled
    /// Whether or not the reminder  is enabled, if disabled all reminders will not fire.
    var reminderIsEnabled: Bool {
        get {
            return storedReminderIsEnabled
        }
        set (newReminderIsEnabled) {
            // going from disable to enabled
            if reminderIsEnabled == false && newReminderIsEnabled == true {
                resetForNextAlarm()
            }
            
            storedReminderIsEnabled = newReminderIsEnabled
        }
    }
    
    // MARK: - Reminder Components
    
    var countdownComponents: CountdownComponents = CountdownComponents()
    
    var weeklyComponents: WeeklyComponents = WeeklyComponents()
    
    var monthlyComponents: MonthlyComponents = MonthlyComponents()
    
    var oneTimeComponents: OneTimeComponents = OneTimeComponents()
    
    var snoozeComponents: SnoozeComponents = SnoozeComponents()
    
    // MARK: - Timing
    
    var intervalRemaining: TimeInterval? {
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
    
    private var storedReminderAlarmTimer: Timer?
    /// Timer that executes a reminder's alarm. It triggers at reminderExecutionDate and invokes didExecuteReminderAlarmTimer. If assigning new timer, invalidates the current timer then assigns reminderAlarmTimer to new timer.
    var reminderAlarmTimer: Timer? {
        get {
            return storedReminderAlarmTimer
        }
        set (newReminderAlarmTimer) {
            // if the newReminderAlarmTimer references a different timer than storedReminderAlarmTimer, invalidate storedReminderAlarmTimer and assign it to newReminderAlarmTimer
            if newReminderAlarmTimer !== storedReminderAlarmTimer {
                storedReminderAlarmTimer?.invalidate()
                storedReminderAlarmTimer = newReminderAlarmTimer
            }
        }
    }
    
    private var storedReminderDisableIsSkippingTimer: Timer?
    /// Timer that executes to change a reminder from isSkipping true to false. It triggers when the current date passes the original reminderExecutionDate that was skipped, indicating the reminder should go back into regular, non-skipping mode. If assigning new timer, invalidates the current timer then assigns reminderDisableIsSkippingTimer to new timer.
    var reminderDisableIsSkippingTimer: Timer? {
        get {
            return storedReminderDisableIsSkippingTimer
        }
        set (newReminderDisableIsSkippingTimer) {
            // if the newReminderDisableIsSkippingTimer references a different timer than storedReminderDisableIsSkippingTimer, invalidate storedReminderDisableIsSkippingTimer and assign it to newReminderDisableIsSkippingTimer
            if newReminderDisableIsSkippingTimer !== storedReminderDisableIsSkippingTimer {
                storedReminderDisableIsSkippingTimer?.invalidate()
                storedReminderDisableIsSkippingTimer = newReminderDisableIsSkippingTimer
            }
        }
    }
    
    /// Restores the reminder to a state where it is ready for its next alarm. This resets reminderExecutionBasis, clears skippedDates, and clears snooze. Typically use if reminder's alarm executed and user responded to it or if reminder's timing has updated and needs a complete reset.
    func resetForNextAlarm() {
        reminderExecutionBasis = Date()
        
        snoozeComponents.executionInterval = nil
        
        weeklyComponents.skippedDate = nil
        monthlyComponents.skippedDate = nil
    }
    
    /// Only invoke this functions if the reminder's timers have taken an action to indicate they are past their fireDate or the timer is invalid and should be replaced. Timers will be overriden by TimingManager if they haven't passed their fireDate. Otherwise, if the timers have passed their fireDate, the reminder's references to the timers are important as they prevent TimingManager from producing duplicate timers (which would create duplicate alerts) with initalizeReminderTimers.
    func clearTimers() {
        reminderAlarmTimer = nil
        reminderDisableIsSkippingTimer = nil
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
    
    /// Call this function when a user driven action directly intends to change the skip status of the weekly or monthy components. This function only timing related data, no logs are added or removed. Additioanlly, if oneTime is getting skipped, it must be deleted externally.
    func changeIsSkipping(forIsSkipping isSkipping: Bool) {
        // can't change is skipping on a disabled reminder. nothing to skip.
        guard reminderIsEnabled == true else {
            return
        }
        
        switch reminderType {
        case .oneTime: break
            // can't skip and can't unskip
            // do nothing inside the reminder, this is handled externally
        case .countdown:
            // can skip and can't unskip
            if isSkipping == true {
                // only way to skip a countdown reminder is to reset it to restart its countdown
                resetForNextAlarm()
            }
        case .weekly:
            // can skip and can unskip
            guard isSkipping != weeklyComponents.isSkipping else {
                break
            }
            
            if let skippedDate = weeklyComponents.skippedDate {
                // since we are unskipping, we want to revert to the previous reminderExecutionBasis, which happens to be skippedDate
                reminderExecutionBasis = skippedDate
                weeklyComponents.skippedDate = nil
            }
            else {
                // skipping
                weeklyComponents.skippedDate = Date()
            }
        case .monthly:
            // can skip and can unskip
            guard isSkipping != monthlyComponents.isSkipping else {
                return
            }
            
            if let skippedDate = monthlyComponents.skippedDate {
                // since we are unskipping, we want to revert to the previous reminderExecutionBasis, which happens to be skippedDate
                reminderExecutionBasis = skippedDate
                monthlyComponents.skippedDate = nil
            }
            else {
                // skipping
                monthlyComponents.skippedDate = Date()
            }
        }
    }
    
}

extension Reminder {
    
    // MARK: - Compare
    
    /// Returns true if all the server synced properties for the reminder are the same. This includes all the base properties here (yes the reminderId too) and the reminder components for the corresponding reminderAction
    func isSame(asReminder reminder: Reminder) -> Bool {
        if reminderId != reminder.reminderId {
            return false
        }
        else if reminderAction != reminder.reminderAction {
            return false
        }
        else if reminderCustomActionName != reminder.reminderCustomActionName {
            return false
        }
        else if reminderExecutionBasis != reminder.reminderExecutionBasis {
            return false
        }
        else if reminderIsEnabled != reminder.reminderIsEnabled {
            return false
        }
        // snooze
        else if snoozeComponents.executionInterval != reminder.snoozeComponents.executionInterval {
            return false
        }
        // reminder types (countdown, weekly, monthly, one time)
        else if reminderType != reminder.reminderType {
            return false
        }
        
        // known at this point that the reminderTypes are the same
        switch reminderType {
        case .countdown:
            if countdownComponents.executionInterval != reminder.countdownComponents.executionInterval {
                return false
            }
            else {
                // everything the same!
                return true
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
            else {
                // all the same!
                return true
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
            else {
                // all the same!
                return true
            }
        case .oneTime:
            if oneTimeComponents.oneTimeDate != reminder.oneTimeComponents.oneTimeDate {
                return false
            }
            else {
                // all the same!
                return true
            }
        }
    }
    
    // MARK: - Request
    
    /// Returns an array literal of the reminders's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[KeyConstant.reminderId.rawValue] = reminderId
        body[KeyConstant.reminderType.rawValue] = reminderType.rawValue
        body[KeyConstant.reminderAction.rawValue] = reminderAction.rawValue
        body[KeyConstant.reminderCustomActionName.rawValue] = reminderCustomActionName
        body[KeyConstant.reminderExecutionBasis.rawValue] = reminderExecutionBasis.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.reminderExecutionDate.rawValue] = reminderExecutionDate?.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.reminderIsEnabled.rawValue] = reminderIsEnabled
        body[KeyConstant.reminderIsDeleted.rawValue] = false
        
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
    
    /// Returns an array literal of the reminders's reminderId and no other properties. This is suitable to be used as the JSON body for a HTTP request
    func createIdBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[KeyConstant.reminderId.rawValue] = reminderId
        return body
    }
}
