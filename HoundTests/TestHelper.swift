//
//  TestHelper.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation
@testable import Hound

final class TestHelper {
    static var utc: TimeZone {
        return TimeZone(identifier: "UTC")!
    }
    
    static var utcCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = utc
        return cal
    }
    
    static func calendar(_ timeZone: TimeZone) -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        return cal
    }
    
    static func date(_ string: String) -> Date {
        return string.formatISO8601IntoDate()!
    }
    
    static func countdown(_ interval: Double? = Constant.Class.ReminderComponent.defaultCountdownExecutionInterval) -> CountdownComponents {
        CountdownComponents(executionInterval: interval)
    }
    
    static func weekly(days: [Weekday] = Weekday.allCases, hour: Int = Constant.Class.ReminderComponent.defaultZonedHour, minute: Int = Constant.Class.ReminderComponent.defaultZonedMinute, skipped: Date? = nil) -> WeeklyComponents {
        let comp = WeeklyComponents()
        _ = comp.setZonedWeekdays(days)
        comp.zonedHour = hour
        comp.zonedMinute = minute
        comp.skippedDate = skipped
        return comp
    }
    
    static func monthly(day: Int = Constant.Class.ReminderComponent.defaultZonedDay, hour: Int = Constant.Class.ReminderComponent.defaultZonedHour, minute: Int = Constant.Class.ReminderComponent.defaultZonedMinute, skipped: Date? = nil) -> MonthlyComponents {
        MonthlyComponents(zonedDay: day, zonedHour: hour, zonedMinute: minute, skippedDate: skipped)
    }
    
    static func oneTime(date: Date) -> OneTimeComponents {
        OneTimeComponents(oneTimeDate: date)
    }
    
    static func snooze(_ interval: Double?) -> SnoozeComponents {
        SnoozeComponents(executionInterval: interval)
    }
}
