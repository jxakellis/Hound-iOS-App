//
//  ReminderTests.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/26/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import XCTest
@testable import Hound

final class ReminderTests: XCTestCase {
    
    func testOneTimeReminderExecution() {
        let execDate = TestHelper.date("2024-10-05T12:30:00Z")
        let rem = Reminder(
            reminderType: .oneTime,
            reminderExecutionBasis: execDate,
            reminderTimeZone: TestHelper.utc,
            oneTimeComponents: TestHelper.oneTime(date: execDate)
        )
        XCTAssertEqual(rem.reminderExecutionDate, execDate)
    }
    
    func testCountdownReminderExecution() {
        let rem = Reminder(
            reminderType: .countdown,
            reminderExecutionBasis: TestHelper.date("2024-01-01T00:00:00Z"),
            reminderTimeZone: TestHelper.utc,
            countdownComponents: TestHelper.countdown(60)
        )
        XCTAssertEqual(rem.reminderExecutionDate, TestHelper.date("2024-01-01T00:01:00Z"))
    }
    
    func testWeeklyReminderExecutionInDifferentTZ() {
        let rem = Reminder(
            reminderType: .weekly,
            reminderExecutionBasis: TestHelper.date("2024-05-10T12:00:00Z"),
            reminderTimeZone: TimeZone(identifier: "America/New_York"),
            weeklyComponents: TestHelper.weekly(days: [.monday], hour: 9, minute: 0, skipped: nil)
        )
        let next = rem.reminderExecutionDate
        // basis 2024-05-10T12:00:00Z is Friday 08:00 in New York
        // next Monday at 09:00 EDT is 2024-05-13T13:00:00Z in UTC
        XCTAssertEqual(next, TestHelper.date("2024-05-13T13:00:00Z"))
    }
    
    func testMonthlyReminderExecutionSkipsAndDisables() {
        let rem = Reminder(
            reminderType: .monthly,
            reminderExecutionBasis: TestHelper.date("2024-05-01T00:00:00Z"),
            reminderTimeZone: TestHelper.utc,
            monthlyComponents: TestHelper.monthly(day: 20, hour: 7, minute: 0, skipped: TestHelper.date("2024-05-20T07:00:00Z"))
        )
        // should skip the first occurrence on 2024-05-20 and move to 2024-06-20
        let next = rem.reminderExecutionDate
        XCTAssertEqual(next, TestHelper.date("2024-06-20T07:00:00Z"))
        // disable skipping
        rem.disableIsSkipping()
        XCTAssertFalse(rem.monthlyComponents.isSkipping)
    }
    
    func testSnoozeOverridesReminder() {
        let rem = Reminder(
            reminderType: .weekly,
            reminderExecutionBasis: TestHelper.date("2024-06-01T00:00:00Z"),
            reminderTimeZone: TestHelper.utc,
            weeklyComponents: TestHelper.weekly(days: [.sunday], hour: 8, minute: 0, skipped: nil),
            snoozeComponents: TestHelper.snooze(3600)
        )
        // 1 hour snooze from 2024-06-01T00:00:00Z results in 2024-06-01T01:00:00Z
        XCTAssertEqual(rem.reminderExecutionDate, TestHelper.date("2024-06-01T01:00:00Z"))
    }
    
    func testWeeklyReminderDSTSpringForward() {
        let rem = Reminder(
            reminderType: .weekly,
            reminderExecutionBasis: TestHelper.date("2024-03-01T00:00:00Z"),
            reminderTimeZone: TimeZone(identifier: "America/New_York"),
            weeklyComponents: TestHelper.weekly(days: [.sunday], hour: 2, minute: 30, skipped: nil)
        )
        let next = rem.reminderExecutionDate
        // next Sunday 2:30 AM occurs on 2024-03-03 which is 07:30 UTC
        XCTAssertEqual(next, TestHelper.date("2024-03-03T07:30:00Z"))
    }
    
    func testWeeklyReminderDSTFallBack() {
        let rem = Reminder(
            reminderType: .weekly,
            reminderExecutionBasis: TestHelper.date("2024-10-20T00:00:00Z"),
            reminderTimeZone: TimeZone(identifier: "America/New_York"),
            weeklyComponents: TestHelper.weekly(days: [.sunday], hour: 1, minute: 30, skipped: nil)
        )
        let next = rem.reminderExecutionDate
        // next Sunday 1:30 AM before fall back is 2024-10-20 at 05:30 UTC
        XCTAssertEqual(next, TestHelper.date("2024-10-20T05:30:00Z"))
    }
    
    func testWeeklyMultipleDaysPreviousNext() {
        let rem = Reminder(
            reminderType: .weekly,
            reminderExecutionBasis: TestHelper.date("2024-05-15T12:00:00Z"),
            reminderTimeZone: TestHelper.utc,
            weeklyComponents: TestHelper.weekly(days: [.monday, .wednesday], hour: 9, minute: 0, skipped: nil)
        )
        let next = rem.reminderExecutionDate
        // next occurrence should be Monday 2024-05-20 at 09:00 UTC
        XCTAssertEqual(next, TestHelper.date("2024-05-20T09:00:00Z"))
        let prev = rem.weeklyComponents.previousExecutionDate(reminderExecutionBasis: rem.reminderExecutionBasis,
                                                              sourceTimeZone: rem.reminderTimeZone)
        // previous occurrence is Wednesday 2024-05-15 at 09:00 UTC
        XCTAssertEqual(prev, TestHelper.date("2024-05-15T09:00:00Z"))
    }
    
    func testMonthlyDayOverflowNextAndPrevious() {
        let rem = Reminder(
            reminderType: .monthly,
            reminderExecutionBasis: TestHelper.date("2024-04-01T00:00:00Z"),
            reminderTimeZone: TestHelper.utc,
            monthlyComponents: TestHelper.monthly(day: 31, hour: 8, minute: 0, skipped: nil)
        )
        let next = rem.reminderExecutionDate
        // April has only 30 days so next execution occurs on 2024-04-30 at 08:00 UTC
        XCTAssertEqual(next, TestHelper.date("2024-04-30T08:00:00Z"))
        let prev = rem.monthlyComponents.previousExecutionDate(reminderExecutionBasis: rem.reminderExecutionBasis,
                                                               sourceTimeZone: rem.reminderTimeZone)
        // previous execution was 2024-03-31 at 08:00 UTC
        XCTAssertEqual(prev, TestHelper.date("2024-03-31T08:00:00Z"))
    }
    
    func testDisableIsSkippingDateWeekly() {
        let rem = Reminder(
            reminderType: .weekly,
            reminderExecutionBasis: TestHelper.date("2024-07-01T00:00:00Z"),
            reminderTimeZone: TestHelper.utc,
            weeklyComponents: TestHelper.weekly(days: [.sunday], hour: 6, minute: 0, skipped: TestHelper.date("2024-07-07T06:00:00Z"))
        )
        // disabling skipping should return the first scheduled date 2024-07-07 at 06:00 UTC
        XCTAssertEqual(rem.disableIsSkippingDate, TestHelper.date("2024-07-07T06:00:00Z"))
    }
    
    func testDisableIsSkippingDateSnoozedReturnsNil() {
        let rem = Reminder(
            reminderType: .weekly,
            reminderExecutionBasis: TestHelper.date("2024-07-01T00:00:00Z"),
            reminderTimeZone: TestHelper.utc,
            weeklyComponents: TestHelper.weekly(days: [.sunday], hour: 6, minute: 0, skipped: TestHelper.date("2024-07-07T06:00:00Z")),
            snoozeComponents: TestHelper.snooze(600)
        )
        XCTAssertNil(rem.disableIsSkippingDate)
    }
    
    func makeFullReminder(type: ReminderType) -> Reminder {
        let basis = TestHelper.date("2024-01-01T00:00:00Z")
        let tz = TimeZone(identifier: "America/Los_Angeles")!
        let recipients = ["a", "b"]
        let countdown = TestHelper.countdown(120)
        let weekly = TestHelper.weekly(days: [.sunday], hour: 8, minute: 0, skipped: nil)
        let monthly = TestHelper.monthly(day: 15, hour: 9, minute: 0, skipped: nil)
        let oneTime = TestHelper.oneTime(date: TestHelper.date("2024-05-05T12:00:00Z"))
        let snooze = TestHelper.snooze(nil)
        let offline = OfflineModeComponents(forInitialAttemptedSyncDate: basis,
                                            forInitialCreationDate: basis)
        return Reminder(
            reminderId: 5,
            reminderUUID: UUID(uuidString: "00000000-0000-0000-0000-000000000555"),
            reminderActionTypeId: 2,
            reminderCustomActionName: "Walk",
            reminderType: type,
            reminderExecutionBasis: basis,
            reminderIsTriggerResult: false,
            reminderIsEnabled: true,
            reminderRecipientUserIds: recipients,
            reminderTimeZone: tz,
            countdownComponents: countdown,
            weeklyComponents: weekly,
            monthlyComponents: monthly,
            oneTimeComponents: oneTime,
            snoozeComponents: snooze,
            offlineModeComponents: offline
        )
    }
    
    func testCustomActionNameSanitization() {
        let rem = makeFullReminder(type: .countdown)
        rem.reminderCustomActionName = "   extremely long custom name that should be truncated to thirty two characters  "
        XCTAssertLessThanOrEqual(rem.reminderCustomActionName.count, Constant.Class.Reminder.reminderCustomActionNameCharacterLimit)
        XCTAssertFalse(rem.reminderCustomActionName.hasPrefix(" "))
    }
    
    func testChangeTypeResetsExecutionBasis() {
        let rem = makeFullReminder(type: .countdown)
        let before = rem.reminderExecutionBasis
        rem.changeReminderType(forReminderType: .weekly)
        XCTAssertEqual(rem.reminderType, .weekly)
        XCTAssertGreaterThan(rem.reminderExecutionBasis, before)
    }
    
    func testEnableDisableAndReset() {
        let rem = makeFullReminder(type: .weekly)
        rem.reminderIsEnabled = false
        XCTAssertNil(rem.reminderExecutionDate)
        rem.reminderIsEnabled = true
        XCTAssertNotNil(rem.reminderExecutionDate)
    }
    
    func testSkippingAndDisableIsSkippingDate() {
        let rem = makeFullReminder(type: .weekly)
        let skipDate = TestHelper.date("2024-05-05T15:00:00Z")
        rem.enableIsSkipping(skippedDate: skipDate)
        XCTAssertTrue(rem.weeklyComponents.isSkipping)
        XCTAssertEqual(rem.disableIsSkippingDate, rem.weeklyComponents.notSkippingExecutionDate(reminderExecutionBasis: rem.reminderExecutionBasis, sourceTimeZone: rem.reminderTimeZone))
        rem.disableIsSkipping()
        XCTAssertFalse(rem.weeklyComponents.isSkipping)
    }
    
    func testSnoozeOverridesExecution() {
        let rem = makeFullReminder(type: .countdown)
        rem.snoozeComponents.changeExecutionInterval(300)
        // 5 minute snooze from 2024-01-01T00:00:00Z results in 2024-01-01T00:05:00Z
        XCTAssertEqual(rem.reminderExecutionDate, TestHelper.date("2024-01-01T00:05:00Z"))
    }
}
