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
    func makeDate(_ string: String) -> Date {
        ISO8601DateFormatter().date(from: string)!
    }

    func testNextExecutionNormalMonth() {
        var comp = MonthlyComponents(zonedDay: 15, zonedHour: 10, zonedMinute: 0)
        let tz = TimeZone(identifier: "UTC")!
        let basis = makeDate("2024-01-10T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.day = 15; comps.hour = 10; comps.minute = 0; comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, expected)
    }

    func testNextExecutionDayOverflow() {
        var comp = MonthlyComponents(zonedDay: 31, zonedHour: 8, zonedMinute: 0)
        let tz = TimeZone(identifier: "UTC")!
        let basis = makeDate("2024-04-01T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.day = 30; comps.hour = 8; comps.minute = 0; comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, expected)
    }

    func testSkippingBehavior() {
        var comp = MonthlyComponents(zonedDay: 5, zonedHour: 12, zonedMinute: 0, skippedDate: makeDate("2024-06-05T12:00:00Z"))
        let tz = TimeZone(identifier: "UTC")!
        let basis = makeDate("2024-06-01T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.day = 5; comps.hour = 12; comps.minute = 0; comps.second = 0
        let first = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        let second = cal.nextDate(after: first.addingTimeInterval(1), matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, second)
    }

    func testPreviousExecutionDST() {
        var comp = MonthlyComponents(zonedDay: 14, zonedHour: 2, zonedMinute: 30)
        let tz = TimeZone(identifier: "America/New_York")!
        let basis = makeDate("2024-03-15T12:00:00Z")
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.day = 14; comps.hour = 2; comps.minute = 30; comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents, direction: .backward)!
        XCTAssertEqual(prev, expected)
    }

    func testLocalConversion() {
        var comp = MonthlyComponents(zonedDay: 10, zonedHour: 22, zonedMinute: 15)
        let est = TimeZone(identifier: "America/New_York")!
        let gmt = TimeZone(identifier: "GMT")!
        let ref = makeDate("2024-05-01T00:00:00Z")
        let (day, hour, minute) = est.convert(day: 10, hour: 22, minute: 15, to: gmt, referenceDate: ref)
        let local = comp.readableRecurrence(from: est, to: gmt)
        let str = "Every \(day)\(day.daySuffix()) at \(String.convert(hour: hour, minute: minute))"
        XCTAssertEqual(local, str)
    }
}
