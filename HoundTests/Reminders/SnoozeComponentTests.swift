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
        // adding one hour crosses into DST resulting in 2024-03-10T07:30:00Z
        XCTAssertEqual(rem.reminderExecutionDate, TestHelper.date("2024-03-10T07:30:00Z"))
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
        // adding two hours lands in repeated hour at 2024-11-03T06:30:00Z
        XCTAssertEqual(rem.reminderExecutionDate, TestHelper.date("2024-11-03T06:30:00Z"))
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
