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
        let result = est.convert(hour: 23, minute: 30, to: pst)
        let calendar = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = 2000; comps.month = 1; comps.day = 1
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
        let result = gmt.convert(weekdays: weekdays, hour: 23, minute: 0, to: tokyo)
        var expected = Set<Weekday>()
        let calendar = Calendar(identifier: .gregorian)
        for day in weekdays {
            var comps = DateComponents()
            comps.year = 2000; comps.month = 1; comps.day = 2 + (day.rawValue - 1)
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
        let reference = ISO8601DateFormatter().date(from: "2024-03-30T00:00:00Z")!
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
        let result = ist.convert(hour: 9, minute: 0, to: gmt)
        var comps = DateComponents()
        comps.year = 2000; comps.month = 1; comps.day = 1
        comps.hour = 9; comps.minute = 0; comps.second = 0
        comps.timeZone = ist
        let cal = Calendar(identifier: .gregorian)
        let date = cal.date(from: comps)!
        let expected = cal.dateComponents(in: gmt, from: date)
        XCTAssertEqual(result.hour, expected.hour)
        XCTAssertEqual(result.minute, expected.minute)
    }
}
