//
//  SnoozeComponentTests.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import XCTest
@testable import Hound

final class SnoozeComponentsTests: XCTestCase {

    func testInitializationStates() {
        let defaultComp = TestHelper.snooze(nil)
        XCTAssertNil(defaultComp.executionInterval)

        let explicit = TestHelper.snooze(120)
        XCTAssertEqual(explicit.executionInterval, 120)

        let explicitNil = TestHelper.snooze(nil)
        XCTAssertNil(explicitNil.executionInterval)
    }

    func testExecutionIntervalValues() {
        let values: [Double?] = [nil, 0, -5, 10, 1_000_000]
        for val in values {
            let comp = TestHelper.snooze(val)
            XCTAssertEqual(comp.executionInterval, val)
        }
    }

    func testCopyingPreservesValue() {
        let values: [Double?] = [nil, 0, -10, 50, 1_000]
        for val in values {
            let comp = TestHelper.snooze(val)
            guard let copy = comp.copy() as? SnoozeComponents else { return XCTFail("Bad copy") }
            XCTAssertFalse(copy === comp)
            XCTAssertEqual(copy.executionInterval, comp.executionInterval)
        }
    }

    func testIsSameComparison() {
        let base = TestHelper.snooze(nil)
        let same = TestHelper.snooze(nil)
        XCTAssertTrue(base.isSame(as: same))

        let val1 = TestHelper.snooze(60)
        let val2 = TestHelper.snooze(60)
        XCTAssertTrue(val1.isSame(as: val2))

        let diff = TestHelper.snooze(30)
        XCTAssertFalse(val1.isSame(as: diff))
        XCTAssertFalse(val1.isSame(as: base))
    }

    func testCreateBodyOutput() {
        let none = TestHelper.snooze(nil)
        var body = none.createBody()
        if case .double(let d?) = body[Constant.Key.snoozeExecutionInterval.rawValue]!! {
            XCTFail("Expected nil got \(d)")
        }

        let comp = TestHelper.snooze(45)
        body = comp.createBody()
        if case .double(let val?) = body[Constant.Key.snoozeExecutionInterval.rawValue]!! {
            XCTAssertEqual(val, 45)
        } else {
            XCTFail("Missing value")
        }
    }

    func testFromBodyInitialization() {
        let body: JSONResponseBody = [Constant.Key.snoozeExecutionInterval.rawValue: 30.0]
        let comp = SnoozeComponents(fromBody: body, componentToOverride: nil)
        XCTAssertEqual(comp.executionInterval, 30)

        let override = TestHelper.snooze(60)
        let missing = SnoozeComponents(fromBody: [:], componentToOverride: override)
        XCTAssertEqual(missing.executionInterval, 60)

        let invalid: JSONResponseBody = [Constant.Key.snoozeExecutionInterval.rawValue: "foo"]
        let fallback = SnoozeComponents(fromBody: invalid, componentToOverride: nil)
        XCTAssertNil(fallback.executionInterval)
    }

    func testSnoozeAcrossDSTSpringForward() {
        let tz = TimeZone(identifier: "America/New_York")!
        let base = TestHelper.date("2024-03-10T06:30:00Z") // 1:30 EST before jump
        let rem = Reminder(
            reminderType: .oneTime,
            reminderExecutionBasis: base,
            reminderTimeZone: tz,
            oneTimeComponents: TestHelper.oneTime(date: base),
            snoozeComponents: TestHelper.snooze(3600)
        )
        let expected = base.addingTimeInterval(3600)
        XCTAssertEqual(rem.reminderExecutionDate, expected)
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        let comps = cal.dateComponents([.hour, .minute], from: expected)
        XCTAssertEqual(comps.hour, 3) // becomes 3:30 after spring forward
        XCTAssertEqual(comps.minute, 30)
    }

    func testSnoozeAcrossDSTFallBack() {
        let tz = TimeZone(identifier: "America/New_York")!
        let base = TestHelper.date("2024-11-03T04:30:00Z") // 0:30 EDT before fall back
        let rem = Reminder(
            reminderType: .oneTime,
            reminderExecutionBasis: base,
            reminderTimeZone: tz,
            oneTimeComponents: TestHelper.oneTime(date: base),
            snoozeComponents: TestHelper.snooze(7200)
        )
        let expected = base.addingTimeInterval(7200)
        XCTAssertEqual(rem.reminderExecutionDate, expected)
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        let comps = cal.dateComponents([.hour, .minute], from: expected)
        XCTAssertEqual(comps.hour, 1) // lands in repeated hour
        XCTAssertEqual(comps.minute, 30)
    }

    func testResetForNextAlarmClearsSnooze() {
        let base = TestHelper.date("2024-05-01T00:00:00Z")
        let rem = Reminder(
            reminderType: .countdown,
            reminderExecutionBasis: base,
            reminderTimeZone: TimeZone(identifier: "UTC"),
            countdownComponents: TestHelper.countdown(60),
            snoozeComponents: TestHelper.snooze(120)
        )
        XCTAssertNotNil(rem.snoozeComponents.executionInterval)
        rem.resetForNextAlarm()
        XCTAssertNil(rem.snoozeComponents.executionInterval)
    }
}
