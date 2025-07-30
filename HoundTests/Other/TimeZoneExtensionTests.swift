//
//  TimeZoneExtensionTests.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/26/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import XCTest
@testable import Hound

final class TimeZoneExtensionTests: XCTestCase {
    
    func testHourMinuteConversion() {
        let est = TimeZone(identifier: "America/New_York")!
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let ref = TestHelper.date("2024-06-15T00:00:00Z")
        let result = est.convert(hour: 23, minute: 30, to: pst, referenceDate: ref)
        let calendar = Calendar(identifier: .gregorian)
        var comps = calendar.dateComponents(in: est, from: ref)
        comps.day = comps.day ?? 1
        comps.hour = 23; comps.minute = 30; comps.second = 0
        comps.timeZone = est
        let date = calendar.date(from: comps)!
        let expected = calendar.dateComponents(in: pst, from: date)
        XCTAssertEqual(result.hour, expected.hour)
        XCTAssertEqual(result.minute, expected.minute)
    }
    
    func testWeekdayConversion() {
        let gmt = TimeZone(identifier: "GMT")!
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let weekdays: [Weekday] = [.sunday, .tuesday]
        let ref = TestHelper.date("2024-06-15T00:00:00Z")
        let result = gmt.convert(weekdays: weekdays, hour: 23, minute: 0, to: tokyo, referenceDate: ref)
        var expected = Set<Weekday>()
        let calendar = Calendar(identifier: .gregorian)
        for day in weekdays {
            var comps = calendar.dateComponents([.year, .month], from: ref)
            comps.day = 2 + (day.rawValue - 1)
            comps.hour = 23; comps.minute = 0; comps.second = 0
            comps.timeZone = gmt
            let date = calendar.date(from: comps)!
            let out = calendar.dateComponents(in: tokyo, from: date)
            expected.insert(Weekday(rawValue: out.weekday!)!)
        }
        XCTAssertEqual(Set(result), expected)
    }
    
    func testDayHourMinuteConversion() {
        let est = TimeZone(identifier: "America/New_York")!
        let berlin = TimeZone(identifier: "Europe/Berlin")!
        let reference = TestHelper.date("2024-03-30T00:00:00Z")
        let (d,h,m) = est.convert(day: 31, hour: 1, minute: 45, to: berlin, referenceDate: reference)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: est, from: reference)
        let daysInMonth = cal.range(of: .day, in: .month, for: reference, in: est)!.count
        comps.day = min(31, daysInMonth)
        comps.hour = 1; comps.minute = 45; comps.second = 0
        let date = cal.date(from: comps)!
        let expComp = cal.dateComponents(in: berlin, from: date)
        let daysMonthBerlin = cal.range(of: .day, in: .month, for: date, in: berlin)!.count
        let expectedDay = min(expComp.day!, daysMonthBerlin)
        XCTAssertEqual(d, expectedDay)
        XCTAssertEqual(h, expComp.hour)
        XCTAssertEqual(m, expComp.minute)
    }
    
    func testHalfHourOffsetConversion() {
        let ist = TimeZone(identifier: "Asia/Kolkata")! // GMT+5:30
        let gmt = TimeZone(identifier: "GMT")!
        let ref = TestHelper.date("2024-06-15T00:00:00Z")
        let result = ist.convert(hour: 9, minute: 0, to: gmt, referenceDate: ref)
        var comps = Calendar(identifier: .gregorian).dateComponents(in: ist, from: ref)
        comps.day = comps.day ?? 1
        comps.hour = 9; comps.minute = 0; comps.second = 0
        comps.timeZone = ist
        let cal = Calendar(identifier: .gregorian)
        let date = cal.date(from: comps)!
        let expected = cal.dateComponents(in: gmt, from: date)
        XCTAssertEqual(result.hour, expected.hour)
        XCTAssertEqual(result.minute, expected.minute)
    }
    
    func testHourMinuteCrossMidnight() {
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let ref = TestHelper.date("2024-06-15T00:00:00Z")
        let result = tokyo.convert(hour: 0, minute: 30, to: pst, referenceDate: ref)
        XCTAssertEqual(result.hour, 8)
        XCTAssertEqual(result.minute, 30)
    }
    
    func testWeekdayNextDayConversion() {
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let utc = TestHelper.utc
        let ref = TestHelper.date("2024-06-15T00:00:00Z")
        let out = pst.convert(weekdays: [.saturday], hour: 23, minute: 0, to: utc, referenceDate: ref)
        XCTAssertEqual(out, [.sunday])
    }
    
    func testWeekdayPreviousDayConversion() {
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let ref = TestHelper.date("2024-06-15T00:00:00Z")
        let out = tokyo.convert(weekdays: [.monday], hour: 0, minute: 30, to: pst, referenceDate: ref)
        XCTAssertEqual(out, [.sunday])
    }
    
    func testDayHourMinuteDSTSpringForward() {
        let est = TimeZone(identifier: "America/New_York")!
        let utc = TestHelper.utc
        let ref = TestHelper.date("2024-03-01T00:00:00Z")
        let result = est.convert(day: 10, hour: 2, minute: 30, to: utc, referenceDate: ref)
        XCTAssertEqual(result.day, 10)
        XCTAssertEqual(result.hour, 7)
        XCTAssertEqual(result.minute, 30)
    }
    
    func testDayHourMinuteDSTFallBack() {
        let est = TimeZone(identifier: "America/New_York")!
        let utc = TestHelper.utc
        let ref = TestHelper.date("2024-11-01T00:00:00Z")
        let result = est.convert(day: 3, hour: 1, minute: 30, to: utc, referenceDate: ref)
        XCTAssertEqual(result.day, 3)
        XCTAssertEqual(result.hour, 5)
        XCTAssertEqual(result.minute, 30)
    }
    
    func testDayOverflowConversion() {
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let utc = TestHelper.utc
        let ref = TestHelper.date("2024-04-15T00:00:00Z")
        let result = pst.convert(day: 31, hour: 0, minute: 0, to: utc, referenceDate: ref)
        // april 31st doesnt exist, so we roll under to num days in ref month
        XCTAssertEqual(result.day, 30)
        XCTAssertEqual(result.hour, 7)
        XCTAssertEqual(result.minute, 0)
    }
    
    func testDayNoOverflowConversion() {
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let utc = TestHelper.utc
        let ref = TestHelper.date("2024-05-15T00:00:00Z")
        let result = pst.convert(day: 31, hour: 0, minute: 0, to: utc, referenceDate: ref)
        // may 31st does exist, so no roll under
        XCTAssertEqual(result.day, 31)
        XCTAssertEqual(result.hour, 7)
        XCTAssertEqual(result.minute, 0)
    }
    
    func testHourMinuteConversionCrossDayForward() {
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let ref = TestHelper.date("2024-01-15T00:00:00Z")
        let result = pst.convert(hour: 18, minute: 45, to: tokyo, referenceDate: ref)
        XCTAssertEqual(result.hour, 11)
        XCTAssertEqual(result.minute, 45)
    }
    
    func testHourMinuteConversionCrossDayBackward() {
        let ist = TimeZone(identifier: "Asia/Kolkata")!
        let est = TimeZone(identifier: "America/New_York")!
        let ref = TestHelper.date("2024-01-15T00:00:00Z")
        let result = ist.convert(hour: 5, minute: 15, to: est, referenceDate: ref)
        XCTAssertEqual(result.hour, 18)
        XCTAssertEqual(result.minute, 45)
    }

    func testReferenceDateAffectsHourMinuteConversion() {
        let ny = TimeZone(identifier: "America/New_York")!
        let syd = TimeZone(identifier: "Australia/Sydney")!
        let winter = TestHelper.date("2024-01-15T00:00:00Z")
        let summer = TestHelper.date("2024-07-15T00:00:00Z")
        let w = ny.convert(hour: 20, minute: 0, to: syd, referenceDate: winter)
        let s = ny.convert(hour: 20, minute: 0, to: syd, referenceDate: summer)
        XCTAssertEqual(w.hour, 12)
        XCTAssertEqual(s.hour, 10)
        XCTAssertNotEqual(w.hour, s.hour)
    }

    func testReferenceDateAffectsWeekdayConversion() {
        let la = TimeZone(identifier: "America/Los_Angeles")!
        let syd = TimeZone(identifier: "Australia/Sydney")!
        let winter = TestHelper.date("2024-01-15T00:00:00Z")
        let summer = TestHelper.date("2024-07-15T00:00:00Z")
        let w = la.convert(weekdays: [.monday], hour: 6, minute: 0, to: syd, referenceDate: winter)
        let s = la.convert(weekdays: [.monday], hour: 6, minute: 0, to: syd, referenceDate: summer)
        XCTAssertEqual(w, [.tuesday])
        XCTAssertEqual(s, [.monday])
    }
    
    func testWeekdayConversionCrossMidnightForward() {
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let utc = TimeZone(identifier: "UTC")!
        let ref = TestHelper.date("2024-06-15T00:00:00Z")
        let result = pst.convert(weekdays: [.saturday], hour: 23, minute: 30, to: utc, referenceDate: ref)
        XCTAssertEqual(result, [.sunday])
    }
    
    func testWeekdayConversionCrossMidnightBackward() {
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let ref = TestHelper.date("2024-06-15T00:00:00Z")
        let result = tokyo.convert(weekdays: [.monday, .wednesday], hour: 2, minute: 0, to: pst, referenceDate: ref)
        XCTAssertEqual(Set(result), Set([.sunday, .tuesday]))
    }
    
    func testDayHourMinuteConversionNextMonth() {
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let reference = TestHelper.date("2024-02-01T00:00:00Z")
        let (d, h, m) = pst.convert(day: 31, hour: 18, minute: 0, to: tokyo, referenceDate: reference)
        XCTAssertEqual(d, 1)
        XCTAssertEqual(h, 11)
        XCTAssertEqual(m, 0)
    }
    
    func testDayHourMinuteConversionPreviousMonth() {
        let berlin = TimeZone(identifier: "Europe/Berlin")!
        let est = TimeZone(identifier: "America/New_York")!
        let reference = TestHelper.date("2024-03-01T00:00:00Z")
        let (d, h, m) = berlin.convert(day: 1, hour: 0, minute: 30, to: est, referenceDate: reference)
        XCTAssertEqual(d, 29)
        XCTAssertEqual(h, 18)
        XCTAssertEqual(m, 30)
    }
    
    func testDayHourMinuteConversionDSTSpringForward() {
        let est = TimeZone(identifier: "America/New_York")!
        let utc = TimeZone(identifier: "UTC")!
        let reference = TestHelper.date("2024-03-01T12:00:00Z")
        let (d, h, m) = est.convert(day: 10, hour: 2, minute: 30, to: utc, referenceDate: reference)
        XCTAssertEqual(d, 10)
        XCTAssertEqual(h, 7)
        XCTAssertEqual(m, 30)
    }
    
    func testDayHourMinuteConversionDSTFallBack() {
        let est = TimeZone(identifier: "America/New_York")!
        let utc = TimeZone(identifier: "UTC")!
        let reference = TestHelper.date("2024-11-01T12:00:00Z")
        let (d, h, m) = est.convert(day: 3, hour: 1, minute: 30, to: utc, referenceDate: reference)
        XCTAssertEqual(d, 3)
        XCTAssertEqual(h, 5)
        XCTAssertEqual(m, 30)
    }
}
