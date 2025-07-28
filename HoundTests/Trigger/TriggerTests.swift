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
                           triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 120),
                           triggerManualCondition: true,
                           triggerAlarmCreatedCondition: false)
        XCTAssertEqual(trig.triggerType, .timeDelay)
        XCTAssertEqual(trig.timeDelayComponents.triggerTimeDelay, 120)
        XCTAssertTrue(trig.triggerManualCondition)
        XCTAssertFalse(trig.triggerAlarmCreatedCondition)
        XCTAssertTrue(trig.timeDelayComponents.changeTriggerTimeDelay(300))
        XCTAssertEqual(trig.timeDelayComponents.triggerTimeDelay, 300)
        XCTAssertFalse(trig.timeDelayComponents.changeTriggerTimeDelay(-10))
        XCTAssertEqual(trig.timeDelayComponents.triggerTimeDelay, 300)
    }

    func testFixedTimeInitializationAndChanges() {
        let reaction = TriggerLogReaction(forLogActionTypeId: 1, forLogCustomActionName: nil)
        let reminderResult = TriggerReminderResult(forReminderActionTypeId: 3, forReminderCustomActionName: "potty")
        let trig = Trigger(triggerLogReactions: [reaction],
                           triggerReminderResult: reminderResult,
                           triggerType: .fixedTime,
                           triggerFixedTimeComponents: TriggerFixedTimeComponents(
                               triggerFixedTimeTypeAmount: 1,
                               triggerFixedTimeHour: 6,
                               triggerFixedTimeMinute: 30))
        XCTAssertEqual(trig.triggerType, .fixedTime)
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeTypeAmount, 1)
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeHour, 6)
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeMinute, 30)
        XCTAssertTrue(trig.fixedTimeComponents.changeTriggerFixedTimeTypeAmount(2))
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeTypeAmount, 2)
        XCTAssertFalse(trig.fixedTimeComponents.changeTriggerFixedTimeTypeAmount(-1))
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeTypeAmount, 2)
        XCTAssertTrue(trig.fixedTimeComponents.changeFixedTimeHour(23))
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeHour, 23)
        XCTAssertFalse(trig.fixedTimeComponents.changeFixedTimeHour(25))
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeHour, 23)
        XCTAssertTrue(trig.fixedTimeComponents.changeFixedTimeMinute(45))
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeMinute, 45)
        XCTAssertFalse(trig.fixedTimeComponents.changeFixedTimeMinute(61))
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeMinute, 45)
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
        let trig = Trigger(triggerType: .timeDelay,
                           triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 60))
        let basis = TestHelper.date("2024-01-01T00:00:00Z")
        let next = trig.nextReminderDate(afterDate: basis, in: TestHelper.utc)
        XCTAssertEqual(next, basis.addingTimeInterval(60))
    }

    func testNextReminderDateFixedTime() {
        let trig = Trigger(triggerType: .fixedTime,
                           triggerFixedTimeComponents: TriggerFixedTimeComponents(
                               triggerFixedTimeTypeAmount: 0,
                               triggerFixedTimeHour: 15,
                               triggerFixedTimeMinute: 0))
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
        let trig = Trigger(triggerType: .timeDelay,
                           triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 60))
        let log = Log(forLogActionTypeId: 1)
        guard let rem = trig.createTriggerResultReminder(afterLog: log, in: TestHelper.utc) else { return XCTFail("nil") }
        XCTAssertEqual(rem.reminderActionTypeId, trig.triggerReminderResult.reminderActionTypeId)
        XCTAssertTrue(rem.reminderIsTriggerResult)
        XCTAssertEqual(rem.oneTimeComponents.oneTimeDate, log.logStartDate.addingTimeInterval(60))
    }

    func testSetTriggerLogReactionsRemovesDuplicates() {
        let r1 = TriggerLogReaction(forLogActionTypeId: 1, forLogCustomActionName: nil)
        let dup = TriggerLogReaction(forLogActionTypeId: 1, forLogCustomActionName: nil)
        let trig = Trigger(triggerLogReactions: [r1])
        XCTAssertTrue(trig.setTriggerLogReactions([r1, dup]))
        XCTAssertEqual(trig.triggerLogReactions.count, 1)
        XCTAssertFalse(trig.setTriggerLogReactions([]))
    }

    func testTimeDelayChangeRejectsZero() {
        let trig = Trigger(triggerType: .timeDelay,
                           triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 60))
        XCTAssertFalse(trig.timeDelayComponents.changeTriggerTimeDelay(0))
        XCTAssertEqual(trig.timeDelayComponents.triggerTimeDelay, 60)
    }

    func testFixedTimeChangeRejectsNegative() {
        let trig = Trigger(triggerType: .fixedTime,
                           triggerFixedTimeComponents: TriggerFixedTimeComponents(
                               triggerFixedTimeTypeAmount: 0,
                               triggerFixedTimeHour: 10,
                               triggerFixedTimeMinute: 0))
        XCTAssertFalse(trig.fixedTimeComponents.changeFixedTimeHour(-1))
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeHour, 10)
        XCTAssertFalse(trig.fixedTimeComponents.changeFixedTimeMinute(-5))
        XCTAssertEqual(trig.fixedTimeComponents.triggerFixedTimeMinute, 0)
    }

    func testNextReminderDateTimeDelayUsesEndDate() {
        let trig = Trigger(triggerType: .timeDelay,
                           triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 120))
        let start = TestHelper.date("2024-01-01T10:00:00Z")
        let end = TestHelper.date("2024-01-01T11:00:00Z")
        let log = Log(forLogActionTypeId: 1, forLogStartDate: start, forLogEndDate: end)
        let next = trig.nextReminderDate(afterLog: log, in: TestHelper.utc)
        XCTAssertEqual(next, end.addingTimeInterval(120))
    }

    func testDogTriggerManagerMatching() {
        let trig1 = Trigger(triggerLogReactions: [TriggerLogReaction(forLogActionTypeId: 1, forLogCustomActionName: nil)],
                             triggerType: .timeDelay,
                             triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 60))
        let trig2 = Trigger(triggerLogReactions: [TriggerLogReaction(forLogActionTypeId: 2, forLogCustomActionName: "play")],
                             triggerType: .timeDelay,
                             triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 120))
        let manager = DogTriggerManager(forDogTriggers: [trig1, trig2])
        let m1 = manager.matchingActivatedTriggers(forLog: Log(forLogActionTypeId: 1))
        XCTAssertEqual(m1.map { $0.triggerUUID }, [trig1.triggerUUID])
        let m2 = manager.matchingActivatedTriggers(forLog: Log(forLogActionTypeId: 2, forLogCustomActionName: "play"))
        XCTAssertEqual(m2.map { $0.triggerUUID }, [trig2.triggerUUID])
        XCTAssertTrue(manager.matchingActivatedTriggers(forLog: Log(forLogActionTypeId: 3)).isEmpty)
    }

    func testTriggerComparisonSorting() {
        let t1 = Trigger(triggerType: .timeDelay,
                         triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 30))
        let t2 = Trigger(triggerType: .timeDelay,
                         triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 60))
        let t3 = Trigger(triggerType: .fixedTime,
                         triggerFixedTimeComponents: TriggerFixedTimeComponents(
                             triggerFixedTimeTypeAmount: 0,
                             triggerFixedTimeHour: 8,
                             triggerFixedTimeMinute: 0))
        var arr = [t3, t2, t1]
        arr.sort(by: { $0 < $1 })
        XCTAssertEqual(arr[0].timeDelayComponents.triggerTimeDelay, 30)
        XCTAssertEqual(arr[1].timeDelayComponents.triggerTimeDelay, 60)
        XCTAssertEqual(arr[2].triggerType, .fixedTime)
    }

    func testCreateTriggerResultReminderFixedTime() {
        let trig = Trigger(triggerType: .fixedTime,
                           triggerFixedTimeComponents: TriggerFixedTimeComponents(
                               triggerFixedTimeTypeAmount: 1,
                               triggerFixedTimeHour: 6,
                               triggerFixedTimeMinute: 0))
        let log = Log(forLogActionTypeId: 1, forLogStartDate: TestHelper.date("2024-05-01T00:00:00Z"))
        guard let rem = trig.createTriggerResultReminder(afterLog: log, in: TestHelper.utc) else { return XCTFail("nil") }
        let expected = trig.fixedTimeComponents.nextReminderDate(afterDate: log.logStartDate, in: TestHelper.utc)!
        XCTAssertEqual(rem.oneTimeComponents.oneTimeDate, expected)
    }

    func testReadableTimeOutputs() {
        let td = Trigger(triggerType: .timeDelay,
                         triggerTimeDelayComponents: TriggerTimeDelayComponents(triggerTimeDelay: 3600))
        XCTAssertEqual(td.readableTime(), "1h later")
        let ft = Trigger(triggerType: .fixedTime,
                         triggerFixedTimeComponents: TriggerFixedTimeComponents(
                             triggerFixedTimeTypeAmount: 1,
                             triggerFixedTimeHour: 7,
                             triggerFixedTimeMinute: 30))
        XCTAssertEqual(ft.readableTime().normalizeSpaces(), "next day @ 7:30 AM")
    }
}
