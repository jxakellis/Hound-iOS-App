//
//  CountdownComponentTests.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import XCTest
@testable import Hound

final class CountdownComponentsTests: XCTestCase {

    func testReminderIntegrationAcrossDST() {
        let base = TestHelper.date("2024-03-10T06:30:00Z")
        let tz = TimeZone(identifier: "America/New_York")!
        let rem = Reminder(reminderType: .countdown,
                           reminderExecutionBasis: base,
                           reminderTimeZone: tz,
                           countdownComponents: TestHelper.countdown(3600))
        // 1 hour countdown crosses DST start -> 2024-03-10T07:30:00Z
        XCTAssertEqual(rem.reminderExecutionDate, TestHelper.date("2024-03-10T07:30:00Z"))
    }

    func testReminderIntegrationDifferentTZ() {
        let base = TestHelper.date("2024-05-01T12:00:00Z")
        let tz = TimeZone(identifier: "Asia/Tokyo")!
        let rem = Reminder(reminderType: .countdown,
                           reminderExecutionBasis: base,
                           reminderTimeZone: tz,
                           countdownComponents: TestHelper.countdown(120))
        // 2 minute countdown results in 2024-05-01T12:02:00Z
        XCTAssertEqual(rem.reminderExecutionDate, TestHelper.date("2024-05-01T12:02:00Z"))
    }

}
