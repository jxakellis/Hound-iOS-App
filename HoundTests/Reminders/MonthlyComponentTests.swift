//
//  Untitled.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/26/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import XCTest
@testable import Hound

final class MonthlyComponentsTests: XCTestCase {

    func testNextExecutionNormalMonth() {
        let tz = TestHelper.utc
        let cal = TestHelper.calendar(tz)
        
        let comp = MonthlyComponents(zonedDay: 15, zonedHour: 10, zonedMinute: 0)
        let basis = TestHelper.date("2024-01-10T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.day = 15; comps.hour = 10; comps.minute = 0; comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
        XCTAssertEqual(next, expected)
    }

    func testNextExecutionDayOverflow() {
        let tz = TestHelper.utc
        let cal = TestHelper.calendar(tz)
        
        let comp = MonthlyComponents(zonedDay: 31, zonedHour: 8, zonedMinute: 0)
        let basis = TestHelper.date("2024-04-01T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.day = 30; comps.hour = 8; comps.minute = 0; comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
        XCTAssertEqual(next, expected)
    }

    func testSkippingBehavior() {
        let tz = TestHelper.utc
        let cal = TestHelper.calendar(tz)
        
        let comp = MonthlyComponents(zonedDay: 5, zonedHour: 12, zonedMinute: 0, skippedDate: TestHelper.date("2024-06-05T12:00:00Z"))
        let basis = TestHelper.date("2024-06-01T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.day = 5; comps.hour = 12; comps.minute = 0; comps.second = 0
        let first = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
        XCTAssertNotNil(first)
        guard let first = first else {
            return
        }
        let second = cal.nextDate(after: first.addingTimeInterval(1), matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
        XCTAssertEqual(next, second)
    }

    func testPreviousExecutionDST() {
        let tz = TimeZone(identifier: "America/New_York")!
        let cal = TestHelper.calendar(tz)
        
        let comp = MonthlyComponents(zonedDay: 14, zonedHour: 2, zonedMinute: 30)
        let basis = TestHelper.date("2024-03-15T12:00:00Z")
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.day = 14; comps.hour = 2; comps.minute = 30; comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents, direction: .backward)
        XCTAssertEqual(prev, expected)
    }

    func testLocalConversion() {
        let est = TimeZone(identifier: "America/New_York")!
        let gmt = TimeZone(identifier: "GMT")!
        
        let comp = MonthlyComponents(zonedDay: 10, zonedHour: 22, zonedMinute: 15)
        let ref = TestHelper.date("2024-05-01T00:00:00Z")
        let (day, hour, minute) = est.convert(day: 10, hour: 22, minute: 15, to: gmt, referenceDate: ref)
        let local = comp.readableRecurrence(from: est, to: gmt)
        let str = "Every \(day)\(day.daySuffix()) at \(String.convert(hour: hour, minute: minute))"
        XCTAssertEqual(local, str)
    }

    func testPreviousExecutionDayOverflow() {
        let tz = TimeZone(identifier: "America/New_York")!
        let cal = TestHelper.calendar(tz)
        
        let comp = MonthlyComponents(zonedDay: 31, zonedHour: 9, zonedMinute: 0)
        let basis = TestHelper.date("2024-04-15T00:00:00Z")
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.day = 31
        comps.hour = 9
        comps.minute = 0
        comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps,
                                    matchingPolicy: .nextTimePreservingSmallerComponents,
                                    direction: .backward)
        XCTAssertEqual(prev, expected)
    }

    func testNextExecutionDSTSpringForward() {
        let tz = TimeZone(identifier: "America/New_York")!
        let cal = TestHelper.calendar(tz)
        
        let comp = MonthlyComponents(zonedDay: 10, zonedHour: 2, zonedMinute: 30)
        let basis = TestHelper.date("2024-03-01T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.day = 10
        comps.hour = 2
        comps.minute = 30
        comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
        XCTAssertEqual(next, expected)
    }
    
    func testDefaultInitializer() {
            let comp = MonthlyComponents()
            XCTAssertEqual(comp.zonedDay, Constant.Class.ReminderComponent.defaultZonedDay)
            XCTAssertEqual(comp.zonedHour, Constant.Class.ReminderComponent.defaultZonedHour)
            XCTAssertEqual(comp.zonedMinute, Constant.Class.ReminderComponent.defaultZonedMinute)
            XCTAssertNil(comp.skippedDate)
        }

        func testInitializerWithValues() {
            let date = TestHelper.date("2024-06-02T09:15:00Z")
            let comp = MonthlyComponents(zonedDay: 2, zonedHour: 9, zonedMinute: 15, skippedDate: date)
            XCTAssertEqual(comp.zonedDay, 2)
            XCTAssertEqual(comp.zonedHour, 9)
            XCTAssertEqual(comp.zonedMinute, 15)
            XCTAssertEqual(comp.skippedDate, date)
        }

        func testInitFromBody() {
            let body: JSONResponseBody = [
                Constant.Key.monthlyZonedDay.rawValue: 5,
                Constant.Key.monthlyZonedHour.rawValue: 14,
                Constant.Key.monthlyZonedMinute.rawValue: 45,
                Constant.Key.monthlySkippedDate.rawValue: "2024-05-05T14:45:00Z"
            ]
            let comp = MonthlyComponents(fromBody: body, componentToOverride: nil)
            XCTAssertEqual(comp.zonedDay, 5)
            XCTAssertEqual(comp.zonedHour, 14)
            XCTAssertEqual(comp.zonedMinute, 45)
            XCTAssertEqual(comp.skippedDate, TestHelper.date("2024-05-05T14:45:00Z"))
        }

        func testInitFromBodyWithOverride() {
            let override = MonthlyComponents(zonedDay: 1, zonedHour: 1, zonedMinute: 1)
            let body: JSONResponseBody = [Constant.Key.monthlyZonedHour.rawValue: 22]
            let comp = MonthlyComponents(fromBody: body, componentToOverride: override)
            XCTAssertEqual(comp.zonedDay, 1)
            XCTAssertEqual(comp.zonedHour, 22)
            XCTAssertEqual(comp.zonedMinute, 1)
        }

        func testIsSameDetectsDifferences() {
            let base = MonthlyComponents(zonedDay: 1, zonedHour: 1, zonedMinute: 1)
            var other = MonthlyComponents(zonedDay: 1, zonedHour: 1, zonedMinute: 1)
            XCTAssertTrue(base.isSame(as: other))
            other = MonthlyComponents(zonedDay: 2, zonedHour: 1, zonedMinute: 1)
            XCTAssertFalse(base.isSame(as: other))
            other = MonthlyComponents(zonedDay: 1, zonedHour: 2, zonedMinute: 1)
            XCTAssertFalse(base.isSame(as: other))
            other = MonthlyComponents(zonedDay: 1, zonedHour: 1, zonedMinute: 2)
            XCTAssertFalse(base.isSame(as: other))
            other = MonthlyComponents(zonedDay: 1, zonedHour: 1, zonedMinute: 1, skippedDate: TestHelper.date("2024-05-01T01:01:00Z"))
            XCTAssertFalse(base.isSame(as: other))
        }

        func testNotSkippingExecutionAcrossTimeZones() {
            let zones = ["UTC", "Pacific/Auckland", "Pacific/Honolulu", "Asia/Kolkata"]
            let comp = MonthlyComponents(zonedDay: 15, zonedHour: 10, zonedMinute: 0)
            let basis = TestHelper.date("2024-01-01T00:00:00Z")
            for id in zones {
                let tz = TimeZone(identifier: id)!
                let next = comp.notSkippingExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
                var cal = Calendar(identifier: .gregorian)
                cal.timeZone = tz
                var comps = cal.dateComponents(in: tz, from: basis)
                comps.day = 15; comps.hour = 10; comps.minute = 0; comps.second = 0
                let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
                XCTAssertEqual(next, expected)
            }
        }

        func testNextExecutionWhileSkipping() {
            let date = TestHelper.date("2024-08-20T08:00:00Z")
            let comp = MonthlyComponents(zonedDay: 20, zonedHour: 8, zonedMinute: 0, skippedDate: date)
            let tz = TimeZone(identifier: "UTC")!
            let basis = TestHelper.date("2024-08-01T00:00:00Z")
            let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
            let cal = Calendar(identifier: .gregorian)
            var comps = cal.dateComponents(in: tz, from: basis)
            comps.day = 20; comps.hour = 8; comps.minute = 0; comps.second = 0
            let first = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
            XCTAssertNotNil(first)
            guard let first = first else {
                return
            }
            let second = cal.nextDate(after: first.addingTimeInterval(1), matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
            XCTAssertEqual(next, second)
        }

        func testPreviousExecutionLeapYear() {
            let tz = TestHelper.utc
            let cal = TestHelper.calendar(tz)
            
            let comp = MonthlyComponents(zonedDay: 31, zonedHour: 9, zonedMinute: 0)
            let basis = TestHelper.date("2024-03-15T00:00:00Z") // leap year
            let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
            var comps = cal.dateComponents(in: tz, from: basis)
            comps.day = 31; comps.hour = 9; comps.minute = 0; comps.second = 0
            let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents, direction: .backward)
            XCTAssertEqual(prev, expected)
        }

        func testDSTFallBackAmbiguousTime() {
            let tz = TimeZone(identifier: "America/New_York")!
            let cal = TestHelper.calendar(tz)
            
            let comp = MonthlyComponents(zonedDay: 3, zonedHour: 1, zonedMinute: 30)
            let basis = TestHelper.date("2024-10-20T00:00:00Z")
            let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
            var comps = cal.dateComponents(in: tz, from: basis)
            comps.day = 3; comps.hour = 1; comps.minute = 30; comps.second = 0
            let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
            XCTAssertEqual(next, expected)
        }

        func testReadableRecurrenceDifferentTimeZone() {
            let comp = MonthlyComponents(zonedDay: 15, zonedHour: 22, zonedMinute: 45)
            let est = TimeZone(identifier: "America/New_York")!
            let pst = TimeZone(identifier: "America/Los_Angeles")!
            let basis = TestHelper.date("2024-07-01T00:00:00Z")
            let next = comp.notSkippingExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: est)
            let (d,h,m) = est.convert(day: 15, hour: 22, minute: 45, to: pst, referenceDate: next)
            let expected = "Every \(d)\(d.daySuffix()) at \(String.convert(hour: h, minute: m))"
            XCTAssertEqual(comp.readableRecurrence(from: est, to: pst), expected)
        }

        func testConfigureFromDate() {
            let date = TestHelper.date("2024-07-04T18:30:00Z")
            let tz = TimeZone(identifier: "UTC")!
            let comp = MonthlyComponents()
            comp.configure(from: date, timeZone: tz)
            XCTAssertEqual(comp.zonedDay, 4)
            XCTAssertEqual(comp.zonedHour, 18)
            XCTAssertEqual(comp.zonedMinute, 30)
        }

        func testApplyFromOtherComponent() {
            let base = MonthlyComponents(zonedDay: 5, zonedHour: 7, zonedMinute: 0)
            let other = MonthlyComponents(zonedDay: 10, zonedHour: 20, zonedMinute: 45)
            base.apply(from: other)
            XCTAssertEqual(base.zonedDay, 10)
            XCTAssertEqual(base.zonedHour, 20)
            XCTAssertEqual(base.zonedMinute, 45)
        }

        func testFromBodyWithInvalidValues() {
            let body: JSONResponseBody = [Constant.Key.monthlyZonedDay.rawValue: "foo"]
            XCTAssertNil(MonthlyComponents(fromBody: body, componentToOverride: nil))
        }

        func testReminderIntegrationNextDate() {
            let rem = Reminder(reminderType: .monthly,
                               reminderExecutionBasis: TestHelper.date("2024-05-01T00:00:00Z"),
                               reminderTimeZone: TimeZone(identifier: "UTC"),
                               monthlyComponents: MonthlyComponents(zonedDay: 20, zonedHour: 7, zonedMinute: 0))
            let next = rem.reminderExecutionDate!
            let cal = Calendar(identifier: .gregorian)
            var comps = cal.dateComponents(in: rem.reminderTimeZone, from: rem.reminderExecutionBasis)
            comps.day = 20; comps.hour = 7; comps.minute = 0; comps.second = 0
            let expected = cal.nextDate(after: rem.reminderExecutionBasis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
            XCTAssertEqual(next, expected)
        }

        func testReminderIntegrationSkipping() {
            let rem = Reminder(reminderType: .monthly,
                               reminderExecutionBasis: TestHelper.date("2024-06-01T00:00:00Z"),
                               reminderTimeZone: TimeZone(identifier: "UTC"),
                               monthlyComponents: MonthlyComponents(zonedDay: 10, zonedHour: 7, zonedMinute: 0, skippedDate: TestHelper.date("2024-06-10T07:00:00Z")))
            let first = rem.reminderExecutionDate!
            rem.disableIsSkipping()
            let second = rem.reminderExecutionDate!
            XCTAssertNotEqual(first, second)
        }
}
