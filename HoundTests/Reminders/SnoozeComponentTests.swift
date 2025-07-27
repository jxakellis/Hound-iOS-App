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
        let defaultComp = SnoozeComponents()
        XCTAssertNil(defaultComp.executionInterval)

        let explicit = SnoozeComponents(executionInterval: 120)
        XCTAssertEqual(explicit.executionInterval, 120)

        let explicitNil = SnoozeComponents(executionInterval: nil)
        XCTAssertNil(explicitNil.executionInterval)
    }

    func testExecutionIntervalValues() {
        let values: [Double?] = [nil, 0, -5, 10, 1_000_000]
        for val in values {
            let comp = SnoozeComponents(executionInterval: val)
            XCTAssertEqual(comp.executionInterval, val)
        }
    }

    func testCopyingPreservesValue() {
        let values: [Double?] = [nil, 0, -10, 50, 1_000]
        for val in values {
            let comp = SnoozeComponents(executionInterval: val)
            guard let copy = comp.copy() as? SnoozeComponents else { return XCTFail("Bad copy") }
            XCTAssertFalse(copy === comp)
            XCTAssertEqual(copy.executionInterval, comp.executionInterval)
        }
    }

    func testNSCodingRoundTrip() throws {
        let values: [Double?] = [nil, 0, -5, 1234.5]
        for val in values {
            let comp = SnoozeComponents(executionInterval: val)
            let data = try NSKeyedArchiver.archivedData(withRootObject: comp, requiringSecureCoding: false)
            let decoded = try NSKeyedUnarchiver.unarchivedObject(ofClass: SnoozeComponents.self, from: data)
            XCTAssertEqual(decoded?.executionInterval, val)
        }
    }

    func testIsSameComparison() {
        let base = SnoozeComponents()
        let same = SnoozeComponents()
        XCTAssertTrue(base.isSame(as: same))

        let val1 = SnoozeComponents(executionInterval: 60)
        let val2 = SnoozeComponents(executionInterval: 60)
        XCTAssertTrue(val1.isSame(as: val2))

        let diff = SnoozeComponents(executionInterval: 30)
        XCTAssertFalse(val1.isSame(as: diff))
        XCTAssertFalse(val1.isSame(as: base))
    }

    func testCreateBodyOutput() {
        let none = SnoozeComponents()
        var body = none.createBody()
        if case .double(let d?) = body[Constant.Key.snoozeExecutionInterval.rawValue]!! {
            XCTFail("Expected nil got \(d)")
        }

        let comp = SnoozeComponents(executionInterval: 45)
        body = comp.createBody()
        if case .double(let val?) = body[Constant.Key.snoozeExecutionInterval.rawValue]!! {
            XCTAssertEqual(val, 45)
        } else {
            XCTFail("Missing value")
        }
    }

    func testFromBodyInitialization() {
        let body: JSONResponseBody = [Constant.Key.snoozeExecutionInterval.rawValue: 30]
        let comp = SnoozeComponents(fromBody: body, componentToOverride: nil)
        XCTAssertEqual(comp.executionInterval, 30)

        let override = SnoozeComponents(executionInterval: 60)
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
            oneTimeComponents: OneTimeComponents(oneTimeDate: base),
            snoozeComponents: SnoozeComponents(executionInterval: 3600)
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
            oneTimeComponents: OneTimeComponents(oneTimeDate: base),
            snoozeComponents: SnoozeComponents(executionInterval: 7200)
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
            countdownComponents: CountdownComponents(executionInterval: 60),
            snoozeComponents: SnoozeComponents(executionInterval: 120)
        )
        XCTAssertNotNil(rem.snoozeComponents.executionInterval)
        rem.resetForNextAlarm()
        XCTAssertNil(rem.snoozeComponents.executionInterval)
    }
}
