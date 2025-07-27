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
    
    // MARK: - Next Execution Tests
    
    func testNextExecutionNormalMonth() {
        let tz = TestHelper.utc
        
        let comp = TestHelper.monthly(day: 15, hour: 10, minute: 15, skipped: nil)
        let basis = TestHelper.date("2024-01-10T00:00:00Z")
        
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let expected = TestHelper.date("2024-01-15T10:15:00Z")
        
        XCTAssertEqual(next, expected)
    }
    
    func testNextExecutionFirstDay() {
        let tz = TestHelper.utc
        
        let comp = TestHelper.monthly(day: 1, hour: 10, minute: 15, skipped: nil)
        let basis = TestHelper.date("2024-01-10T00:00:00Z")
        
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let expected = TestHelper.date("2024-02-01T10:15:00Z")
        
        XCTAssertEqual(next, expected)
    }
    
    func testNextExecutionDayUnderflowTo30() {
        let tz = TestHelper.utc
        
        let comp = TestHelper.monthly(day: 31, hour: 8, minute: 0, skipped: nil)
        let basis = TestHelper.date("2024-04-01T00:00:00Z")
        
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let expected = TestHelper.date("2024-04-30T08:00:00Z")
        
        XCTAssertEqual(next, expected)
    }
    
    func testNextExecutionDayNoUnderflow() {
        let tz = TestHelper.utc
        
        let comp = TestHelper.monthly(day: 31, hour: 8, minute: 0, skipped: nil)
        let basis = TestHelper.date("2024-05-01T00:00:00Z")
        
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let expected = TestHelper.date("2024-05-31T08:00:00Z")
        
        XCTAssertEqual(next, expected)
    }
    
    func testNextExecutionDSTSpringForward() {
        let comp = TestHelper.monthly(day: 10, hour: 2, minute: 30, skipped: nil)
        let noDSTBasis = TestHelper.date("2024-02-01T00:00:00Z")
        let basis = TestHelper.date("2024-03-01T00:00:00Z")
        let tz = TimeZone(identifier: "America/New_York")!
        
        // For February, 2:30 AM EST (UTC-5) = 07:30 UTC
        let noDSTNext = comp.nextExecutionDate(reminderExecutionBasis: noDSTBasis, sourceTimeZone: tz)
        let noDSTExpected = TestHelper.date("2024-02-10T07:30:00Z")
        XCTAssertEqual(noDSTNext, noDSTExpected)

        // For March 10, 2024, 2:30 AM does NOT exist, so it should jump to 3:30 AM EDT (UTC-4) = 07:30 UTC
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let expected = TestHelper.date("2024-03-10T07:30:00Z") // 3:30 AM EDT
        XCTAssertEqual(next, expected)
    }
    
    // MARK: - Previous Execution Tests
    
    func testPreviousExecutionDST() {
        let comp = TestHelper.monthly(day: 14, hour: 2, minute: 30, skipped: nil)
        let basis = TestHelper.date("2024-03-15T12:00:00Z")
        let tz = TimeZone(identifier: "America/New_York")!
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let expected = "2024-03-14T06:30:00Z" // DST consideration
        XCTAssertEqual(prev, TestHelper.date(expected))
    }
    
    func testPreviousExecutionDayOverflow() {
        let comp = TestHelper.monthly(day: 31, hour: 9, minute: 0, skipped: nil)
        let basis = TestHelper.date("2024-04-15T00:00:00Z")
        let tz = TimeZone(identifier: "America/New_York")!
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let expected = TestHelper.date("2024-03-31T13:00:00Z") // previous month (March)
        XCTAssertEqual(prev, expected)
    }
    
    func testPreviousExecutionLeapYear() {
            let comp = TestHelper.monthly(day: 31, hour: 9, minute: 0, skipped: nil)
            let basis = TestHelper.date("2024-03-15T00:00:00Z")
            let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: TestHelper.utc)
            let expected = "2024-02-29T09:00:00Z"
            XCTAssertEqual(prev, TestHelper.date(expected))
        }

    
    // MARK: - Skipping Behavior Tests
    
    func testSkippingBehavior() {
        let skipped = TestHelper.date("2024-06-05T12:00:00Z")
        let comp = TestHelper.monthly(day: 5, hour: 12, minute: 0, skipped: skipped)
        let basis = TestHelper.date("2024-06-01T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: TestHelper.utc)
        let expected = TestHelper.date("2024-07-05T12:00:00Z")
        XCTAssertEqual(next, expected)
    }
    
    // MARK: - Readable Recurrence Tests
    
    func testLocalConversion() {
        // Helper to replace all kinds of non-breaking/narrow spaces with regular spaces
        func normalized(_ s: String) -> String {
            s.replacingOccurrences(of: "\u{202F}", with: " ")
             .replacingOccurrences(of: "\u{00A0}", with: " ")
        }
        
        let est = TimeZone(identifier: "America/New_York")!
        let gmt = TimeZone(identifier: "GMT")!
        // 2024-01-10 is always standard time (EST, UTC-5)
        let comp = TestHelper.monthly(day: 10, hour: 22, minute: 15, skipped: nil)
        let basis = TestHelper.date("2024-01-10T00:00:00-05:00")

        let estReadable = comp.readableRecurrence(from: est, to: est, reminderExecutionBasis: basis)
        XCTAssertEqual(normalized(estReadable), "Every 10th at 10:15 PM")
        
        let local = comp.readableRecurrence(from: est, to: gmt, reminderExecutionBasis: basis)
        // 10:15 PM EST converts to 3:15 AM GMT on the 11th
        XCTAssertEqual(normalized(local), "Every 11th at 3:15 AM")
    }
    
    func testNotSkippingExecutionAcrossTimeZones() {
        let expectations: [String: String] = [
            "UTC": "2024-01-15T10:00:00Z",
            "Pacific/Auckland": "2024-01-14T21:00:00Z",
            "Pacific/Honolulu": "2024-01-15T20:00:00Z",
            "Asia/Kolkata": "2024-01-15T04:30:00Z"
        ]
        let comp = TestHelper.monthly(day: 15, hour: 10, minute: 0, skipped: nil)
        let basis = TestHelper.date("2024-01-01T00:00:00Z")
        for (id, expected) in expectations {
            let tz = TimeZone(identifier: id)!
            let next = comp.notSkippingExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
            XCTAssertEqual(next, TestHelper.date(expected))
        }
    }
    
    func testNextExecutionWhileSkipping() {
        let date = TestHelper.date("2024-08-20T08:00:00Z")
        let comp = TestHelper.monthly(day: 20, hour: 8, minute: 0, skipped: date)
        let tz = TestHelper.utc
        let basis = TestHelper.date("2024-08-01T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        // first execution on 2024-08-20T08:00:00Z is skipped; next is 2024-09-20T08:00:00Z
        XCTAssertEqual(next, TestHelper.date("2024-09-20T08:00:00Z"))
    }
    
    func testPreviousExecutionLeapYearUTC() {
        let tz = TestHelper.utc
        let comp = TestHelper.monthly(day: 31, hour: 9, minute: 0, skipped: nil)
        let basis = TestHelper.date("2024-03-15T00:00:00Z") // leap year
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        // previous valid date is 2024-02-29 at 09:00 UTC
        XCTAssertEqual(prev, TestHelper.date("2024-02-29T09:00:00Z"))
    }
    
    func testDSTFallBackAmbiguousTime() {
        let tz = TimeZone(identifier: "America/New_York")!

        let comp = TestHelper.monthly(day: 3, hour: 1, minute: 30, skipped: nil)
        let basis = TestHelper.date("2024-10-20T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        // falls on DST change day: 2024-11-03 at 1:30 AM EDT -> 05:30 UTC
        XCTAssertEqual(next, TestHelper.date("2024-11-03T05:30:00Z"))
    }
    
    func testReadableRecurrenceDifferentTimeZone() {
        let comp = TestHelper.monthly(day: 15, hour: 22, minute: 45, skipped: nil)
        let est = TimeZone(identifier: "America/New_York")!
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let basis = TestHelper.date("2024-07-01T00:00:00Z")
        let next = comp.notSkippingExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: est)
        XCTAssertNotNil(next)
        guard let next = next else {
            return
        }
        let (d,h,m) = est.convert(day: 15, hour: 22, minute: 45, to: pst, referenceDate: next)
        let expected = "Every \(d)\(d.daySuffix()) at \(String.convert(hour: h, minute: m))"
        XCTAssertEqual(comp.readableRecurrence(from: est, to: pst, reminderExecutionBasis: basis), expected)
    }
    
    func testConfigureFromDate() {
        let date = TestHelper.date("2024-07-04T18:30:00Z")
        let tz = TestHelper.utc
        let comp = TestHelper.monthly(day: 1, hour: 1, minute: 1, skipped: nil)
        comp.configure(from: date, timeZone: tz)
        XCTAssertEqual(comp.zonedDay, 4)
        XCTAssertEqual(comp.zonedHour, 18)
        XCTAssertEqual(comp.zonedMinute, 30)
    }
    
    func testApplyFromOtherComponent() {
        let base = TestHelper.monthly(day: 5, hour: 7, minute: 0, skipped: nil)
        let other = TestHelper.monthly(day: 10, hour: 20, minute: 45, skipped: nil)
        base.apply(from: other)
        XCTAssertEqual(base.zonedDay, 10)
        XCTAssertEqual(base.zonedHour, 20)
        XCTAssertEqual(base.zonedMinute, 45)
    }
    
    func testReminderIntegrationNextDate() {
        let rem = Reminder(reminderType: .monthly,
                           reminderExecutionBasis: TestHelper.date("2024-05-01T00:00:00Z"),
                           reminderTimeZone: TestHelper.utc,
                           monthlyComponents: TestHelper.monthly(day: 20, hour: 7, minute: 0, skipped: nil))
        let next = rem.reminderExecutionDate
        // next occurrence is 2024-05-20 at 07:00 UTC
        XCTAssertEqual(next, TestHelper.date("2024-05-20T07:00:00Z"))
    }
    
    func testReminderIntegrationSkipping() {
        let rem = Reminder(reminderType: .monthly,
                           reminderExecutionBasis: TestHelper.date("2024-06-01T00:00:00Z"),
                           reminderTimeZone: TestHelper.utc,
                           monthlyComponents: TestHelper.monthly(day: 10, hour: 7, minute: 0, skipped: TestHelper.date("2024-06-10T07:00:00Z")))
        let first = rem.reminderExecutionDate
        rem.disableIsSkipping()
        let second = rem.reminderExecutionDate
        XCTAssertNotEqual(first, second)
    }
}
