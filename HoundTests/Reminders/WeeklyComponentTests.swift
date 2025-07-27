//
//  WeeklyComponentTests.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/26/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import XCTest
@testable import Hound

final class WeeklyComponentsTests: XCTestCase {
    
    func testNextExecutionBasic() {
        let comp = TestHelper.weekly(days: [.monday], hour: 9, minute: 30, skipped: nil)
        let tz = TimeZone(identifier: "America/Los_Angeles")!
        let basis = TestHelper.date("2024-06-01T12:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        // next Monday 9:30 PDT is 2024-06-03T16:30:00Z
        XCTAssertEqual(next, TestHelper.date("2024-06-03T16:30:00Z"))
    }
    
    func testNextExecutionSkipping() {
        let comp = TestHelper.weekly(days: [.sunday], hour: 6, minute: 0, skipped: TestHelper.date("2024-06-02T06:00:00Z"))
        let tz = TestHelper.utc
        let basis = TestHelper.date("2024-06-01T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        // first occurrence 2024-06-02T06:00:00Z is skipped so next is 2024-06-09T06:00:00Z
        XCTAssertEqual(next, TestHelper.date("2024-06-09T06:00:00Z"))
    }
    
    func testPreviousExecutionDST() {
        let comp = TestHelper.weekly(days: [.monday], hour: 2, minute: 30, skipped: nil)
        let tz = TimeZone(identifier: "America/New_York")!
        let basis = TestHelper.date("2024-03-12T12:00:00Z") // after spring forward
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        // previous Monday 2:30 AM EDT is 2024-03-11T06:30:00Z
        XCTAssertEqual(prev, TestHelper.date("2024-03-11T06:30:00Z"))
    }
    
    func testLocalConversions() {
        let comp = TestHelper.weekly(days: [.sunday], hour: 23, minute: 0, skipped: nil)
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let utc = TestHelper.utc
        let localTime = comp.localTimeOfDay(from: pst, to: utc)
        let expected = pst.convert(hour: 23, minute: 0, to: utc)
        XCTAssertEqual(localTime.hour, expected.hour)
        XCTAssertEqual(localTime.minute, expected.minute)
        let localWeekdays = comp.localWeekdays(from: pst, to: utc)
        XCTAssertEqual(Set(localWeekdays), Set(pst.convert(weekdays: [.sunday], hour: 23, minute: 0, to: utc)))
    }
    
    func testMultipleWeekdayNextAndPrevious() {
        let comp = TestHelper.weekly(days: [.monday, .wednesday], hour: 8, minute: 45, skipped: nil)
        let tz = TestHelper.utc
        let basis = TestHelper.date("2024-05-14T12:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        // next occurrence is Wednesday 2024-05-15 at 08:45 UTC
        XCTAssertEqual(next, TestHelper.date("2024-05-15T08:45:00Z"))
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        // previous occurrence is Monday 2024-05-13 at 08:45 UTC
        XCTAssertEqual(prev, TestHelper.date("2024-05-13T08:45:00Z"))
    }
    
    func testDSTFallBackNextExecution() {
        let comp = TestHelper.weekly(days: [.sunday], hour: 1, minute: 30, skipped: nil)
        let tz = TimeZone(identifier: "America/New_York")!
        let basis = TestHelper.date("2024-10-20T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        // next Sunday 1:30 AM occurs on 2024-10-20T05:30:00Z
        XCTAssertEqual(next, TestHelper.date("2024-10-20T05:30:00Z"))
    }
    
    func testSetZonedWeekdaysValidation() {
        let comp = TestHelper.weekly(days: Weekday.allCases, hour: 0, minute: 0, skipped: nil)
        let result = comp.setZonedWeekdays([])
        XCTAssertFalse(result)
        XCTAssertEqual(Set(comp.zonedWeekdays), Set(Weekday.allCases))
        XCTAssertTrue(comp.setZonedWeekdays([.tuesday, .thursday]))
        XCTAssertEqual(Set(comp.zonedWeekdays), Set([.tuesday, .thursday]))
    }
    
    func testConfigureUpdatesComponents() {
        let comp = TestHelper.weekly(days: Weekday.allCases, hour: 0, minute: 0, skipped: nil)
        let tz = TestHelper.utc
        let date = TestHelper.date("2024-06-01T12:34:00Z")
        let result = comp.configure(from: date, timeZone: tz, weekdays: [.monday])
        XCTAssertTrue(result)
        XCTAssertEqual(comp.zonedHour, 12)
        XCTAssertEqual(comp.zonedMinute, 34)
        XCTAssertEqual(Set(comp.zonedWeekdays), Set([.monday]))
    }
    
    func testConfigureWithInvalidWeekdaysStillUpdatesTime() {
        let comp = TestHelper.weekly(days: Weekday.allCases, hour: 0, minute: 0, skipped: nil)
        let tz = TestHelper.utc
        let date = TestHelper.date("2024-06-01T01:02:00Z")
        let result = comp.configure(from: date, timeZone: tz, weekdays: [])
        XCTAssertFalse(result)
        XCTAssertEqual(comp.zonedHour, 1)
        XCTAssertEqual(comp.zonedMinute, 2)
        XCTAssertEqual(Set(comp.zonedWeekdays), Set(Weekday.allCases))
    }
    
    func testNextExecutionHandlesDSTSpringForward() {
        let comp = TestHelper.weekly(days: [.sunday], hour: 2, minute: 30, skipped: nil)
        let tz = TestHelper.utc
        let basis = TestHelper.date("2024-03-01T00:00:00Z")
        let next = comp.notSkippingExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        // next Sunday 2:30 UTC is 2024-03-03T02:30:00Z
        XCTAssertEqual(next, TestHelper.date("2024-03-03T02:30:00Z"))
    }
    
    func testLocalWeekdaysCrossMidnight() {
        let comp = TestHelper.weekly(days: [.sunday], hour: 23, minute: 30, skipped: nil)
        let utc = TestHelper.utc
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let local = comp.localWeekdays(from: utc, to: tokyo)
        XCTAssertEqual(Set(local), Set(utc.convert(weekdays: [.sunday], hour: 23, minute: 30, to: tokyo)))
    }
    
    func testReadableRecurranceFormatting() {
        let comp = TestHelper.weekly(days: [.monday, .wednesday], hour: 9, minute: 0, skipped: nil)
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let utc = TestHelper.utc
        let rec = comp.readableRecurrance(from: pst, to: utc)
        let days = pst.convert(weekdays: [.monday, .wednesday], hour: 9, minute: 0, to: utc)
        let time = String.convert(hour: pst.convert(hour: 9, minute: 0, to: utc).hour,
                                  minute: pst.convert(hour: 9, minute: 0, to: utc).minute)
        let daysString = days.count > 1 ? days.sorted().map { $0.shortAbbreviation }.joined(separator: ", ") : days.first!.longName
        let expected = "\(daysString) at \(time)"
        XCTAssertEqual(rec, expected)
    }
    
    func testReminderIntegrationWithSkipping() {
        let tz = TimeZone(identifier: "UTC")!
        let basis = TestHelper.date("2024-06-01T00:00:00Z")
        let comp = TestHelper.weekly(days: [.sunday], hour: 8, minute: 0, skipped: nil)
        let rem = Reminder(reminderType: .weekly,
                           reminderExecutionBasis: basis,
                           reminderTimeZone: tz,
                           weeklyComponents: comp)
        let first = rem.reminderExecutionDate
        rem.enableIsSkipping(skippedDate: first)
        let next = rem.reminderExecutionDate
        // first execution 2024-06-02T08:00:00Z was skipped so new execution is 2024-06-09T08:00:00Z
        XCTAssertEqual(next, TestHelper.date("2024-06-09T08:00:00Z"))
    }

    func testNoWeekdaysProducesNil() {
        let comp = WeeklyComponents(zonedSunday: false, zonedMonday: false,
                                    zonedTuesday: false, zonedWednesday: false,
                                    zonedThursday: false, zonedFriday: false,
                                    zonedSaturday: false, zonedHour: 8, zonedMinute: 0)
        let tz = TestHelper.utc
        let basis = TestHelper.date("2024-06-01T00:00:00Z")
        XCTAssertNil(comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz))
        XCTAssertNil(comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz))
    }
}
