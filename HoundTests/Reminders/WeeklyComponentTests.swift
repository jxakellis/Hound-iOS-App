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
    func date(_ string: String) -> Date {
        return string.formatISO8601IntoDate()!
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
        let basis = date("2024-06-01T12:00:00Z")
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
                                    skippedDate: date("2024-06-02T06:00:00Z"))
        let tz = TimeZone(identifier: "UTC")!
        let basis = date("2024-06-01T00:00:00Z")
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
        let second = cal.nextDate(after: first.addingTimeInterval(1), matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
        XCTAssertEqual(next, second)
    }
    
    func testPreviousExecutionDST() {
        let comp = WeeklyComponents(zonedSunday: false, zonedMonday: true,
                                    zonedTuesday: false, zonedWednesday: false,
                                    zonedThursday: false, zonedFriday: false, zonedSaturday: false,
                                    zonedHour: 2, zonedMinute: 30)
        let tz = TimeZone(identifier: "America/New_York")!
        let basis = date("2024-03-12T12:00:00Z") // after spring forward
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.weekday = Weekday.monday.rawValue
        comps.hour = 2
        comps.minute = 30
        comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents, direction: .backward)
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
        let basis = date("2024-05-14T12:00:00Z")
        let next = comp.nextExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.weekday = Weekday.wednesday.rawValue
        comps.hour = 8
        comps.minute = 45
        comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
        XCTAssertEqual(next, expected)
        let prev = comp.previousExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        let prevExpected = cal.nextDate(after: basis, matching: comps,
                                        matchingPolicy: .nextTimePreservingSmallerComponents,
                                        direction: .backward)
        XCTAssertEqual(prev, prevExpected)
    }
    
    func testDSTFallBackNextExecution() {
        let comp = WeeklyComponents(zonedSunday: true, zonedMonday: false, zonedTuesday: false,
                                    zonedWednesday: false, zonedThursday: false, zonedFriday: false,
                                    zonedSaturday: false, zonedHour: 1, zonedMinute: 30)
        let tz = TimeZone(identifier: "America/New_York")!
        let basis = date("2024-10-20T00:00:00Z")
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
    
    func testDefaultInitValues() {
        let comp = WeeklyComponents()
        XCTAssertEqual(Set(comp.zonedWeekdays), Set(Weekday.allCases))
        XCTAssertEqual(comp.zonedHour, Constant.Class.ReminderComponent.defaultZonedHour)
        XCTAssertEqual(comp.zonedMinute, Constant.Class.ReminderComponent.defaultZonedMinute)
        XCTAssertFalse(comp.isSkipping)
    }
    
    func testConvenienceInitCustomValues() {
        let skip = date("2024-01-05T08:30:00Z")
        let comp = WeeklyComponents(zonedSunday: false,
                                    zonedMonday: true,
                                    zonedTuesday: false,
                                    zonedWednesday: true,
                                    zonedThursday: true,
                                    zonedFriday: false,
                                    zonedSaturday: false,
                                    zonedHour: 0,
                                    zonedMinute: 59,
                                    skippedDate: skip)
        XCTAssertEqual(Set(comp.zonedWeekdays), Set([.monday, .wednesday, .thursday]))
        XCTAssertEqual(comp.zonedHour, 0)
        XCTAssertEqual(comp.zonedMinute, 59)
        XCTAssertEqual(comp.skippedDate, skip)
    }
    
    func testFromBodyInitializerMergesWithOverride() {
        let override = WeeklyComponents(zonedSunday: true, zonedMonday: false,
                                        zonedTuesday: false, zonedWednesday: false,
                                        zonedThursday: false, zonedFriday: false,
                                        zonedSaturday: false, zonedHour: 9, zonedMinute: 0)
        let body: JSONResponseBody = [
            Constant.Key.weeklyZonedSunday.rawValue: false,
            Constant.Key.weeklyZonedHour.rawValue: 22,
            Constant.Key.weeklySkippedDate.rawValue: "2024-07-01T22:00:00Z"
        ]
        let comp = WeeklyComponents(fromBody: body, componentToOverride: override)
        XCTAssertEqual(Set(comp.zonedWeekdays), Set([]))
        XCTAssertEqual(comp.zonedHour, 22)
        XCTAssertEqual(comp.zonedMinute, 0)
        XCTAssertEqual(comp.skippedDate, date("2024-07-01T22:00:00Z"))
    }
    
    func testCopyingProducesIndependentObject() {
        let comp = WeeklyComponents(zonedSunday: true, zonedMonday: false,
                                    zonedTuesday: false, zonedWednesday: false,
                                    zonedThursday: false, zonedFriday: false,
                                    zonedSaturday: false, zonedHour: 10, zonedMinute: 15)
        guard let copy = comp.copy() as? WeeklyComponents else { return XCTFail("bad copy") }
        XCTAssertTrue(comp.isSame(as: copy))
        copy.setZonedWeekdays([.monday])
        copy.zonedHour = 9
        XCTAssertFalse(comp.isSame(as: copy))
        XCTAssertEqual(Set(comp.zonedWeekdays), Set([.sunday]))
        XCTAssertEqual(comp.zonedHour, 10)
    }
    
    func testEncodingDecodingRoundTrip() throws {
        let comp = WeeklyComponents(zonedSunday: false, zonedMonday: true,
                                    zonedTuesday: true, zonedWednesday: false,
                                    zonedThursday: false, zonedFriday: true,
                                    zonedSaturday: false, zonedHour: 23, zonedMinute: 30,
                                    skippedDate: date("2024-02-02T23:30:00Z"))
        let data = try NSKeyedArchiver.archivedData(withRootObject: comp, requiringSecureCoding: false)
        let decoded = try NSKeyedUnarchiver.unarchivedObject(ofClass: WeeklyComponents.self, from: data)
        XCTAssertNotNil(decoded)
        XCTAssertTrue(decoded!.isSame(as: comp))
    }
    
    func testSetZonedWeekdaysValidation() {
        let comp = WeeklyComponents()
        let result = comp.setZonedWeekdays([])
        XCTAssertFalse(result)
        XCTAssertEqual(Set(comp.zonedWeekdays), Set(Weekday.allCases))
        XCTAssertTrue(comp.setZonedWeekdays([.tuesday, .thursday]))
        XCTAssertEqual(Set(comp.zonedWeekdays), Set([.tuesday, .thursday]))
    }
    
    func testConfigureUpdatesComponents() {
        let comp = WeeklyComponents()
        let tz = TimeZone(identifier: "UTC")!
        let date = date("2024-06-01T12:34:00Z")
        let result = comp.configure(from: date, timeZone: tz, weekdays: [.monday])
        XCTAssertTrue(result)
        XCTAssertEqual(comp.zonedHour, 12)
        XCTAssertEqual(comp.zonedMinute, 34)
        XCTAssertEqual(Set(comp.zonedWeekdays), Set([.monday]))
    }
    
    func testConfigureWithInvalidWeekdaysStillUpdatesTime() {
        let comp = WeeklyComponents()
        let tz = TimeZone(identifier: "UTC")!
        let date = date("2024-06-01T01:02:00Z")
        let result = comp.configure(from: date, timeZone: tz, weekdays: [])
        XCTAssertFalse(result)
        XCTAssertEqual(comp.zonedHour, 1)
        XCTAssertEqual(comp.zonedMinute, 2)
        XCTAssertEqual(Set(comp.zonedWeekdays), Set(Weekday.allCases))
    }
    
    func testNextExecutionHandlesDSTSpringForward() {
        let comp = WeeklyComponents(zonedSunday: true, zonedMonday: false, zonedTuesday: false,
                                    zonedWednesday: false, zonedThursday: false,
                                    zonedFriday: false, zonedSaturday: false,
                                    zonedHour: 2, zonedMinute: 30)
        let tz = TimeZone(identifier: "America/New_York")!
        let basis = date("2024-03-01T00:00:00Z")
        let next = comp.notSkippingExecutionDate(reminderExecutionBasis: basis, sourceTimeZone: tz)
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.weekday = Weekday.sunday.rawValue
        comps.hour = 2
        comps.minute = 30
        comps.second = 0
        let expected = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)!
        XCTAssertEqual(next, expected)
    }
    
    func testLocalWeekdaysCrossMidnight() {
        let comp = WeeklyComponents(zonedSunday: true, zonedMonday: false, zonedTuesday: false,
                                    zonedWednesday: false, zonedThursday: false,
                                    zonedFriday: false, zonedSaturday: false,
                                    zonedHour: 23, zonedMinute: 30)
        let utc = TimeZone(identifier: "UTC")!
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let local = comp.localWeekdays(from: utc, to: tokyo)
        XCTAssertEqual(Set(local), Set(utc.convert(weekdays: [.sunday], hour: 23, minute: 30, to: tokyo)))
    }
    
    func testReadableRecurranceFormatting() {
        let comp = WeeklyComponents(zonedSunday: false, zonedMonday: true, zonedTuesday: false,
                                    zonedWednesday: true, zonedThursday: false,
                                    zonedFriday: false, zonedSaturday: false,
                                    zonedHour: 9, zonedMinute: 0)
        let pst = TimeZone(identifier: "America/Los_Angeles")!
        let utc = TimeZone(identifier: "UTC")!
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
        let basis = date("2024-06-01T00:00:00Z")
        let comp = WeeklyComponents(zonedSunday: true, zonedMonday: false, zonedTuesday: false,
                                    zonedWednesday: false, zonedThursday: false,
                                    zonedFriday: false, zonedSaturday: false,
                                    zonedHour: 8, zonedMinute: 0)
        let rem = Reminder(reminderType: .weekly,
                           reminderExecutionBasis: basis,
                           reminderTimeZone: tz,
                           weeklyComponents: comp)
        let first = rem.reminderExecutionDate!
        rem.enableIsSkipping(skippedDate: first)
        let next = rem.reminderExecutionDate!
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.weekday = Weekday.sunday.rawValue
        comps.hour = 8
        comps.minute = 0
        comps.second = 0
        let firstDate = cal.nextDate(after: basis, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
        XCTAssertNotNil(firstDate)
        guard let firstDate = firstDate else {
            return
        }
        let secondDate = cal.nextDate(after: firstDate.addingTimeInterval(1), matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
        XCTAssertEqual(next, secondDate)
    }
}
