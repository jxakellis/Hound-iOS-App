//
//  TriggerTests.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import XCTest
@testable import Hound

final class TriggerTests: XCTestCase {

    func testTimeDelayInitializationAndChanges() {
        let reaction = TriggerLogReaction(forLogActionTypeId: 2, forLogCustomActionName: "walk")
        let reminderResult = TriggerReminderResult(forReminderActionTypeId: 4, forReminderCustomActionName: nil)
        let trig = Trigger(triggerLogReactions: [reaction],
                           triggerReminderResult: reminderResult,
                           triggerType: .timeDelay,
                           triggerTimeDelay: 120,
                           triggerManualCondition: true,
                           triggerAlarmCreatedCondition: false)
        XCTAssertEqual(trig.triggerType, .timeDelay)
        XCTAssertEqual(trig.triggerTimeDelay, 120)
        XCTAssertTrue(trig.triggerManualCondition)
        XCTAssertFalse(trig.triggerAlarmCreatedCondition)
        XCTAssertTrue(trig.changeTriggerTimeDelay(forTimeDelay: 300))
        XCTAssertEqual(trig.triggerTimeDelay, 300)
        XCTAssertFalse(trig.changeTriggerTimeDelay(forTimeDelay: -10))
        XCTAssertEqual(trig.triggerTimeDelay, 300)
    }

    func testFixedTimeInitializationAndChanges() {
        let reaction = TriggerLogReaction(forLogActionTypeId: 1, forLogCustomActionName: nil)
        let reminderResult = TriggerReminderResult(forReminderActionTypeId: 3, forReminderCustomActionName: "potty")
        let trig = Trigger(triggerLogReactions: [reaction],
                           triggerReminderResult: reminderResult,
                           triggerType: .fixedTime,
                           forTriggerFixedTimeTypeAmount: 1,
                           forTriggerFixedTimeHour: 6,
                           forTriggerFixedTimeMinute: 30)
        XCTAssertEqual(trig.triggerType, .fixedTime)
        XCTAssertEqual(trig.triggerFixedTimeTypeAmount, 1)
        XCTAssertEqual(trig.triggerFixedTimeHour, 6)
        XCTAssertEqual(trig.triggerFixedTimeMinute, 30)
        XCTAssertTrue(trig.changeTriggerFixedTimeTypeAmount(forAmount: 2))
        XCTAssertEqual(trig.triggerFixedTimeTypeAmount, 2)
        XCTAssertFalse(trig.changeTriggerFixedTimeTypeAmount(forAmount: -1))
        XCTAssertEqual(trig.triggerFixedTimeTypeAmount, 2)
        XCTAssertTrue(trig.changeFixedTimeHour(forHour: 23))
        XCTAssertEqual(trig.triggerFixedTimeHour, 23)
        XCTAssertFalse(trig.changeFixedTimeHour(forHour: 25))
        XCTAssertEqual(trig.triggerFixedTimeHour, 23)
        XCTAssertTrue(trig.changeFixedTimeMinute(forMinute: 45))
        XCTAssertEqual(trig.triggerFixedTimeMinute, 45)
        XCTAssertFalse(trig.changeFixedTimeMinute(forMinute: 61))
        XCTAssertEqual(trig.triggerFixedTimeMinute, 45)
    }

    func testShouldActivateTrigger() {
        let reaction1 = TriggerLogReaction(forLogActionTypeId: 1, forLogCustomActionName: nil)
        let reaction2 = TriggerLogReaction(forLogActionTypeId: 2, forLogCustomActionName: "play")
        let trig = Trigger(triggerLogReactions: [reaction1, reaction2])
        var log = Log(forLogActionTypeId: 1, forLogCustomActionName: nil)
        XCTAssertTrue(trig.shouldActivateTrigger(forLog: log))
        log = Log(forLogActionTypeId: 2, forLogCustomActionName: "play")
        XCTAssertTrue(trig.shouldActivateTrigger(forLog: log))
        log = Log(forLogActionTypeId: 2, forLogCustomActionName: "foo")
        XCTAssertFalse(trig.shouldActivateTrigger(forLog: log))
        trig.triggerManualCondition = false
        log = Log(forLogActionTypeId: 1, forLogCustomActionName: nil)
        XCTAssertFalse(trig.shouldActivateTrigger(forLog: log))
        trig.triggerManualCondition = true
        trig.triggerAlarmCreatedCondition = false
        log = Log(forLogActionTypeId: 1, forLogCustomActionName: nil, forCreatedByReminderUUID: UUID())
        XCTAssertFalse(trig.shouldActivateTrigger(forLog: log))
    }

    func testNextReminderDateTimeDelay() {
        let trig = Trigger(triggerType: .timeDelay, triggerTimeDelay: 60)
        let basis = TestHelper.date("2024-01-01T00:00:00Z")
        let next = trig.nextReminderDate(afterDate: basis, in: TestHelper.utc)
        XCTAssertEqual(next, basis.addingTimeInterval(60))
    }

    func testNextReminderDateFixedTime() {
        let trig = Trigger(triggerType: .fixedTime,
                           forTriggerFixedTimeTypeAmount: 0,
                           forTriggerFixedTimeHour: 15,
                           forTriggerFixedTimeMinute: 0)
        let basis = TestHelper.date("2024-05-10T14:00:00Z")
        let tz = TimeZone(identifier: "UTC")!
        let next = trig.nextReminderDate(afterDate: basis, in: tz)!
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        var comps = cal.dateComponents(in: tz, from: basis)
        comps.hour = 15; comps.minute = 0; comps.second = 0
        let expected = cal.date(from: comps)!
        XCTAssertEqual(next, expected)
        // when past time, roll over next day
        let pastBasis = TestHelper.date("2024-05-10T16:00:00Z")
        let rollover = trig.nextReminderDate(afterDate: pastBasis, in: tz)!
        let expectedRoll = cal.date(byAdding: .day, value: 1, to: expected)!
        XCTAssertEqual(rollover, expectedRoll)
    }

    func testCreateTriggerResultReminder() {
        let trig = Trigger(triggerType: .timeDelay, triggerTimeDelay: 60)
        let log = Log(forLogActionTypeId: 1)
        guard let rem = trig.createTriggerResultReminder(afterLog: log, in: TestHelper.utc) else { return XCTFail("nil") }
        XCTAssertEqual(rem.reminderActionTypeId, trig.triggerReminderResult.reminderActionTypeId)
        XCTAssertTrue(rem.reminderIsTriggerResult)
        XCTAssertEqual(rem.oneTimeComponents.oneTimeDate, log.logStartDate.addingTimeInterval(60))
    }
}
