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
    func makeBasis(_ string: String) -> Date {
        ISO8601DateFormatter().date(from: string)!
    }

    func testNextExecutionBasic() {
        let comp = WeeklyComponents(zonedSunday: false,
                                    zonedMonday: true,
                                    zonedTuesday: false,
                                    zonedWednesday: false,
                                    zonedThursday: false,
                                    zonedFriday: false,
                                    zonedSaturday: false,
                                    zonedHour: 9,
                                    zonedMinute: 30)
        let tz = TimeZone(identifier: "America/Los_Angeles")!
        let basis = makeBasis("2024-06-01T12:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        var expected = cal.dateComponents(in: tz, from: basis)
        expected.weekday = Weekday.monday.rawValue
        expected.hour = 9
        expected.minute = 30
        expected.second = 0
        let expectedDate = cal.nextDate(after: basis, matching: expected, matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, expectedDate)
    }

    func testNextExecutionSkipping() {
        let comp = WeeklyComponents(zonedSunday: true, zonedMonday: false, zonedTuesday: false,
                                    zonedWednesday: false, zonedThursday: false,
                                    zonedFriday: false, zonedSaturday: false,
                                    zonedHour: 6, zonedMinute: 0,
                                    skippedDate: makeBasis("2024-06-02T06:00:00Z"))
        let tz = TimeZone(identifier: "UTC")!
        let basis = makeBasis("2024-06-01T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.weekday = Weekday.sunday.rawValue
        comps.hour = 6
        comps.minute = 0
        comps.second = 0
        let first = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        comps.weekday = Weekday.sunday.rawValue
        comps.hour = 6
        let second = cal.nextDate(after: first.addingTimeInterval(1), matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, second)
    }

    func testPreviousExecutionDST() {
        var comp = WeeklyComponents(zonedSunday: false, zonedMonday: true,
                                    zonedTuesday: false, zonedWednesday: false,
                                    zonedThursday: false, zonedFriday: false, zonedSaturday: false,
                                    zonedHour: 2, zonedMinute: 30)
        let tz = TimeZone(identifier: "America/New_York")!
        let basis = makeBasis("2024-03-12T12:00:00Z") // after spring forward
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.weekday = Weekday.monday.rawValue
        comps.hour = 2
        comps.minute = 30
        comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents, direction: .backward)!
        XCTAssertEqual(prev, expected)
    }

    func testLocalConversions() {
        let comp = WeeklyComponents(zonedSunday: true, zonedMonday: false, zonedTuesday: false,
                                    zonedWednesday: false, zonedThursday: false, zonedFriday: false,
                                    zonedSaturday: false, zonedHour: 23, zonedMinute: 0)
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let utc = TimeZone(identifier: "UTC")!
        let localTime = comp.localTimeOfDay(from: pst, to: utc)
        let expected = pst.convert(hour: 23, minute: 0, to: utc)
        XCTAssertEqual(localTime.hour, expected.hour)
        XCTAssertEqual(localTime.minute, expected.minute)
        let localWeekdays = comp.localWeekdays(from: pst, to: utc)
        XCTAssertEqual(Set(localWeekdays), Set(pst.convert(weekdays: [.sunday], hour: 23, minute: 0, to: utc)))
    }

    func testMultipleWeekdayNextAndPrevious() {
        let comp = WeeklyComponents(zonedSunday: false, zonedMonday: true, zonedTuesday: false,
                                    zonedWednesday: true, zonedThursday: false, zonedFriday: false,
                                    zonedSaturday: false, zonedHour: 8, zonedMinute: 45)
        let tz = TimeZone(identifier: "UTC")!
        let basis = makeBasis("2024-05-14T12:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.weekday = Weekday.wednesday.rawValue
        comps.hour = 8
        comps.minute = 45
        comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, expected)
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let prevExpected = cal.nextDate(after: basis, matching: comps,
                                        matchingPolicy: .nextTimePreservingSmallerComponents,
                                        direction: .backward)!
        XCTAssertEqual(prev, prevExpected)
    }

    func testDSTFallBackNextExecution() {
        let comp = WeeklyComponents(zonedSunday: true, zonedMonday: false, zonedTuesday: false,
                                    zonedWednesday: false, zonedThursday: false, zonedFriday: false,
                                    zonedSaturday: false, zonedHour: 1, zonedMinute: 30)
        let tz = TimeZone(identifier: "America/New_York")!
        let basis = makeBasis("2024-10-20T00:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.weekday = Weekday.sunday.rawValue
        comps.hour = 1
        comps.minute = 30
        comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
        XCTAssertEqual(next, expected)
    }
}
