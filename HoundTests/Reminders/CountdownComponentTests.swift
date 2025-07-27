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

    func testDefaultInitializer() {
        let comp = TestHelper.countdown()
        XCTAssertEqual(comp.executionInterval, Constant.Class.ReminderComponent.defaultCountdownExecutionInterval)
    }

    func testExplicitInitializerValues() {
        let values: [Double] = [60, 3600, 86400]
        for v in values {
            let comp = TestHelper.countdown(v)
            XCTAssertEqual(comp.executionInterval, v)
        }
    }

    func testInitFromBodyUsesValue() {
        let body: JSONResponseBody = [Constant.Key.countdownExecutionInterval.rawValue: 90.0]
        let comp = CountdownComponents(fromBody: body, componentToOverride: nil)
        XCTAssertEqual(comp.executionInterval, 90.0)
    }

    func testInitFromBodyFallsBackToOverride() {
        let override = TestHelper.countdown(120)
        let body: JSONResponseBody = [:]
        let comp = CountdownComponents(fromBody: body, componentToOverride: override)
        XCTAssertEqual(comp.executionInterval, 120)
    }

    func testInitFromBodyInvalidUsesDefault() {
        let body: JSONResponseBody = [Constant.Key.countdownExecutionInterval.rawValue: "foo"]
        let comp = CountdownComponents(fromBody: body, componentToOverride: nil)
        XCTAssertEqual(comp.executionInterval, Constant.Class.ReminderComponent.defaultCountdownExecutionInterval)
    }

    func testCopyProducesIdenticalClone() {
        let values: [Double] = [0, -5, 1, 60, 3600, 86400, Double.greatestFiniteMagnitude, -Double.greatestFiniteMagnitude, Double.leastNormalMagnitude]
        for v in values {
            let original = TestHelper.countdown(v)
            guard let copy = original.copy() as? CountdownComponents else { XCTFail("copy failed"); continue }
            XCTAssertTrue(copy.isSame(as: original))
            XCTAssertFalse(copy === original)
            XCTAssertEqual(copy.executionInterval.bitPattern, original.executionInterval.bitPattern)
        }
    }

    func testIsSameMethod() {
        let a = TestHelper.countdown(60)
        let b = TestHelper.countdown(60)
        let c = TestHelper.countdown(120)
        XCTAssertTrue(a.isSame(as: b))
        XCTAssertFalse(a.isSame(as: c))
    }

    func testCreateBodyMatchesState() {
        let value: Double = 90.5
        let comp = TestHelper.countdown(value)
        let body = comp.createBody()
        let any = body.toAnyDictionary()
        XCTAssertEqual(any[Constant.Key.countdownExecutionInterval.rawValue] as? Double, value)
    }

    func testReadableProperties() {
        let values: [Double] = [1, 60, 3661, -90]
        for v in values {
            let comp = TestHelper.countdown(v)
            let expected = v.readable(capitalizeWords: true, abbreviationLevel: .long)
            XCTAssertEqual(comp.readableTimeOfDay, expected)
            XCTAssertEqual(comp.readableRecurrance, "Every \(expected)")
        }
    }

    func testInitializerRejectsNil() {
        let defaultValue = Constant.Class.ReminderComponent.defaultCountdownExecutionInterval
        let nilComp = TestHelper.countdown(nil)
        XCTAssertEqual(nilComp.executionInterval, defaultValue)
    }

    func testReminderIntegrationAcrossDST() {
        let base = TestHelper.date("2024-03-10T06:30:00Z")
        let tz = TimeZone(identifier: "America/New_York")!
        let rem = Reminder(reminderType: .countdown,
                           reminderExecutionBasis: base,
                           reminderTimeZone: tz,
                           countdownComponents: TestHelper.countdown(3600))
        XCTAssertEqual(rem.reminderExecutionDate, base.addingTimeInterval(3600))
    }

    func testReminderIntegrationDifferentTZ() {
        let base = TestHelper.date("2024-05-01T12:00:00Z")
        let tz = TimeZone(identifier: "Asia/Tokyo")!
        let rem = Reminder(reminderType: .countdown,
                           reminderExecutionBasis: base,
                           reminderTimeZone: tz,
                           countdownComponents: TestHelper.countdown(120))
        XCTAssertEqual(rem.reminderExecutionDate, base.addingTimeInterval(120))
    }

}
