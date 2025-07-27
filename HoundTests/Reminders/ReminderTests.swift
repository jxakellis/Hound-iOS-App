//
//  ReminderTests.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/26/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import XCTest
@testable import Hound

final class ReminderIntegrationTests: XCTestCase {
    func date(_ str: String) -> Date { ISO8601DateFormatter().date(from: str)! }

    func testOneTimeReminderExecution() {
        let execDate = date("2024-10-05T12:30:00Z")
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .oneTime)
        rem.oneTimeComponents = OneTimeComponents(oneTimeDate: execDate)
        rem.reminderTimeZone = TimeZone(identifier: "UTC")!
        XCTAssertEqual(rem.reminderExecutionDate, execDate)
    }

    func testCountdownReminderExecution() {
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .countdown)
        rem.countdownComponents = CountdownComponents(executionInterval: 60)
        rem.reminderExecutionBasis = date("2024-01-01T00:00:00Z")
        rem.reminderTimeZone = TimeZone(identifier: "UTC")!
        XCTAssertEqual(rem.reminderExecutionDate, date("2024-01-01T00:01:00Z"))
    }

    func testWeeklyReminderExecutionInDifferentTZ() {
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .weekly)
        rem.reminderTimeZone = TimeZone(identifier: "America/New_York")!
        rem.weeklyComponents = WeeklyComponents(zonedSunday: false, zonedMonday: true, zonedTuesday: false,
                                                zonedWednesday: false, zonedThursday: false, zonedFriday: false,
                                                zonedSaturday: false, zonedHour: 9, zonedMinute: 0)
        rem.reminderExecutionBasis = date("2024-05-10T12:00:00Z")
        let next = rem.reminderExecutionDate!
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        var comps = cal.dateComponents(in: rem.reminderTimeZone, from: rem.reminderExecutionBasis)
        comps.weekday = Weekday.monday.rawValue
        comps.hour = 9
        comps.minute = 0
        comps.second = 0
        let expected = cal.nextDate(after: rem.reminderExecutionBasis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, expected)
    }

    func testMonthlyReminderExecutionSkipsAndDisables() {
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .monthly)
        rem.reminderTimeZone = TimeZone(identifier: "UTC")!
        rem.monthlyComponents = MonthlyComponents(zonedDay: 20, zonedHour: 7, zonedMinute: 0, skippedDate: date("2024-05-20T07:00:00Z"))
        rem.reminderExecutionBasis = date("2024-05-01T00:00:00Z")
        // should skip to next occurrence
        let next = rem.reminderExecutionDate!
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: rem.reminderTimeZone, from: rem.reminderExecutionBasis)
        comps.day = 20; comps.hour = 7; comps.minute = 0; comps.second = 0
        let first = cal.nextDate(after: rem.reminderExecutionBasis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        let second = cal.nextDate(after: first.addingTimeInterval(1), matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, second)
        // disable skipping
        rem.disableIsSkipping()
        XCTAssertFalse(rem.monthlyComponents.isSkipping)
    }

    func testSnoozeOverridesReminder() {
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .weekly)
        rem.weeklyComponents = WeeklyComponents(zonedSunday: true, zonedMonday: false, zonedTuesday: false,
                                                zonedWednesday: false, zonedThursday: false, zonedFriday: false,
                                                zonedSaturday: false, zonedHour: 8, zonedMinute: 0)
        rem.reminderTimeZone = TimeZone(identifier: "UTC")!
        rem.reminderExecutionBasis = date("2024-06-01T00:00:00Z")
        rem.snoozeComponents.executionInterval = 3600
        let expected = rem.reminderExecutionBasis.addingTimeInterval(3600)
        XCTAssertEqual(rem.reminderExecutionDate, expected)
    }

    func testInitializerAndSetters() {
        let tz = TimeZone(identifier: "UTC")!
        var rem = Reminder(reminderType: .weekly, reminderTimeZone: tz,
                           weeklyComponents: WeeklyComponents(zonedSunday: true,
                                                             zonedMonday: false,
                                                             zonedTuesday: false,
                                                             zonedWednesday: false,
                                                             zonedThursday: false,
                                                             zonedFriday: false,
                                                             zonedSaturday: false,
                                                             zonedHour: 5,
                                                             zonedMinute: 15))
        XCTAssertEqual(rem.reminderType, .weekly)
        rem.changeReminderType(forReminderType: .monthly)
        rem.monthlyComponents = MonthlyComponents(zonedDay: 3, zonedHour: 6, zonedMinute: 0)
        XCTAssertEqual(rem.reminderType, .monthly)
        XCTAssertEqual(rem.monthlyComponents.zonedDay, 3)
    }

    func testDuplicateProducesIndependentCopy() {
        var rem = Reminder()
        rem.reminderId = 42
        rem.reminderUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000111")!
        rem.reminderExecutionBasis = date("2024-01-01T00:00:00Z")
        rem.reminderTimeZone = TimeZone(identifier: "UTC")!
        guard let copy = rem.duplicate() else { return XCTFail("nil duplicate") }
        XCTAssertNil(copy.reminderId)
        XCTAssertNotEqual(copy.reminderUUID, rem.reminderUUID)
        XCTAssertNotEqual(copy.reminderExecutionBasis, rem.reminderExecutionBasis)
    }

    func testWeeklyReminderDSTSpringForward() {
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .weekly)
        rem.weeklyComponents = WeeklyComponents(zonedSunday: true, zonedMonday: false,
                                                zonedTuesday: false, zonedWednesday: false,
                                                zonedThursday: false, zonedFriday: false,
                                                zonedSaturday: false, zonedHour: 2, zonedMinute: 30)
        rem.reminderTimeZone = TimeZone(identifier: "America/New_York")!
        rem.reminderExecutionBasis = date("2024-03-01T00:00:00Z")
        let next = rem.reminderExecutionDate!
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: rem.reminderTimeZone, from: rem.reminderExecutionBasis)
        comps.weekday = Weekday.sunday.rawValue
        comps.hour = 2
        comps.minute = 30
        comps.second = 0
        let expected = cal.nextDate(after: rem.reminderExecutionBasis, matching: comps,
                                    matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, expected)
    }

    func testWeeklyReminderDSTFallBack() {
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .weekly)
        rem.weeklyComponents = WeeklyComponents(zonedSunday: true, zonedMonday: false,
                                                zonedTuesday: false, zonedWednesday: false,
                                                zonedThursday: false, zonedFriday: false,
                                                zonedSaturday: false, zonedHour: 1, zonedMinute: 30)
        rem.reminderTimeZone = TimeZone(identifier: "America/New_York")!
        rem.reminderExecutionBasis = date("2024-10-20T00:00:00Z")
        let next = rem.reminderExecutionDate!
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: rem.reminderTimeZone, from: rem.reminderExecutionBasis)
        comps.weekday = Weekday.sunday.rawValue
        comps.hour = 1
        comps.minute = 30
        comps.second = 0
        let expected = cal.nextDate(after: rem.reminderExecutionBasis, matching: comps,
                                    matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, expected)
    }

    func testWeeklyMultipleDaysPreviousNext() {
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .weekly)
        rem.weeklyComponents = WeeklyComponents(zonedSunday: false, zonedMonday: true,
                                                zonedTuesday: false, zonedWednesday: true,
                                                zonedThursday: false, zonedFriday: false,
                                                zonedSaturday: false, zonedHour: 9, zonedMinute: 0)
        rem.reminderTimeZone = TimeZone(identifier: "UTC")!
        rem.reminderExecutionBasis = date("2024-05-15T12:00:00Z")
        let next = rem.reminderExecutionDate!
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: rem.reminderTimeZone, from: rem.reminderExecutionBasis)
        comps.weekday = Weekday.wednesday.rawValue
        comps.hour = 9
        comps.minute = 0
        comps.second = 0
        let expected = cal.nextDate(after: rem.reminderExecutionBasis, matching: comps,
                                    matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, expected)
        let prev = rem.weeklyComponents.previousExecutionDate(reminderExecutionBasis: rem.reminderExecutionBasis,
                                                              sourceTimeZone: rem.reminderTimeZone)
        let prevExpected = cal.nextDate(after: rem.reminderExecutionBasis, matching: comps,
                                        matchingPolicy: .nextTimePreservingSmallerComponents,
                                        direction: .backward)!
        XCTAssertEqual(prev, prevExpected)
    }

    func testMonthlyDayOverflowNextAndPrevious() {
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .monthly)
        rem.reminderTimeZone = TimeZone(identifier: "UTC")!
        rem.monthlyComponents = MonthlyComponents(zonedDay: 31, zonedHour: 8, zonedMinute: 0)
        rem.reminderExecutionBasis = date("2024-04-01T00:00:00Z")
        let next = rem.reminderExecutionDate!
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: rem.reminderTimeZone, from: rem.reminderExecutionBasis)
        comps.day = 30
        comps.hour = 8
        comps.minute = 0
        comps.second = 0
        let expected = cal.nextDate(after: rem.reminderExecutionBasis, matching: comps,
                                    matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, expected)
        let prev = rem.monthlyComponents.previousExecutionDate(reminderExecutionBasis: rem.reminderExecutionBasis,
                                                               sourceTimeZone: rem.reminderTimeZone)
        let prevExpected = cal.nextDate(after: rem.reminderExecutionBasis, matching: comps,
                                        matchingPolicy: .nextTimePreservingSmallerComponents,
                                        direction: .backward)!
        XCTAssertEqual(prev, prevExpected)
    }

    func testDisableIsSkippingDateWeekly() {
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .weekly)
        rem.reminderTimeZone = TimeZone(identifier: "UTC")!
        rem.weeklyComponents = WeeklyComponents(zonedSunday: true, zonedMonday: false,
                                               zonedTuesday: false, zonedWednesday: false,
                                               zonedThursday: false, zonedFriday: false,
                                               zonedSaturday: false, zonedHour: 6, zonedMinute: 0,
                                               skippedDate: date("2024-07-07T06:00:00Z"))
        rem.reminderExecutionBasis = date("2024-07-01T00:00:00Z")
        let expected = rem.weeklyComponents.notSkippingExecutionDate(reminderExecutionBasis: rem.reminderExecutionBasis,
                                                                     sourceTimeZone: rem.reminderTimeZone)
        XCTAssertEqual(rem.disableIsSkippingDate, expected)
    }

    func testDisableIsSkippingDateSnoozedReturnsNil() {
        var rem = Reminder()
        rem.changeReminderType(forReminderType: .weekly)
        rem.reminderTimeZone = TimeZone(identifier: "UTC")!
        rem.weeklyComponents = WeeklyComponents(zonedSunday: true, zonedMonday: false,
                                               zonedTuesday: false, zonedWednesday: false,
                                               zonedThursday: false, zonedFriday: false,
                                               zonedSaturday: false, zonedHour: 6, zonedMinute: 0,
                                               skippedDate: date("2024-07-07T06:00:00Z"))
        rem.reminderExecutionBasis = date("2024-07-01T00:00:00Z")
        rem.snoozeComponents.executionInterval = 600
        XCTAssertNil(rem.disableIsSkippingDate)
    }
}
