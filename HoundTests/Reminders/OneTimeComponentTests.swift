//
//  OneTimeComponentTests.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import XCTest
@testable import Hound

final class OneTimeComponentsTests: XCTestCase {
    
    func withTimezone<T>(_ identifier: String, _ body: () throws -> T) rethrows -> T {
        let original = getenv("TZ").flatMap { String(cString: $0) }
        setenv("TZ", identifier, 1)
        NSTimeZone.resetSystemTimeZone()
        defer {
            if let orig = original { setenv("TZ", orig, 1) } else { unsetenv("TZ") }
            NSTimeZone.resetSystemTimeZone()
        }
        return try body()
    }

    func testInitializerDefaultAndExplicit() {
        let before = Date()
        let defaultComp = OneTimeComponents()
        let after = Date()
        XCTAssertGreaterThanOrEqual(defaultComp.oneTimeDate, before)
        XCTAssertLessThanOrEqual(defaultComp.oneTimeDate, after)

        let date = TestHelper.date("2024-05-05T12:00:00Z")
        let explicitComp = OneTimeComponents(oneTimeDate: date)
        XCTAssertEqual(explicitComp.oneTimeDate, date)
    }

    func testCopyAndCodingRoundTrip() throws {
        let date = TestHelper.date("2024-06-01T00:00:00Z")
        let comp = OneTimeComponents(oneTimeDate: date)
        guard let copy = comp.copy() as? OneTimeComponents else { return XCTFail("copy failed") }
        XCTAssertNotEqual(ObjectIdentifier(comp), ObjectIdentifier(copy))
        XCTAssertEqual(copy.oneTimeDate, comp.oneTimeDate)

        let data = try NSKeyedArchiver.archivedData(withRootObject: comp, requiringSecureCoding: false)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        let decoded = OneTimeComponents(coder: unarchiver)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.oneTimeDate, comp.oneTimeDate)
    }

    func testIsSameComparison() {
        let date = TestHelper.date("2024-07-04T15:00:00Z")
        let a = OneTimeComponents(oneTimeDate: date)
        let b = OneTimeComponents(oneTimeDate: date)
        XCTAssertTrue(a.isSame(as: b))
        let c = OneTimeComponents(oneTimeDate: date.addingTimeInterval(60))
        XCTAssertFalse(a.isSame(as: c))
    }

    func testCreateBodyMatchesISO8601() {
        let date = TestHelper.date("2024-08-10T11:22:33Z")
        let comp = OneTimeComponents(oneTimeDate: date)
        let body = comp.createBody()
        guard let value = body[Constant.Key.oneTimeDate.rawValue] ?? nil else {
            return XCTFail("missing value")
        }
        if case let .string(str?) = value {
            XCTAssertEqual(str, date.ISO8601FormatWithFractionalSeconds())
        } else {
            XCTFail("unexpected JSON value")
        }
    }

    func testReadablePropertiesVariousDates() throws {
        try withTimezone("America/New_York") {
            let currentYear = Calendar.current.component(.year, from: Date())
            let sameYear = TestHelper.date("\(currentYear)-01-02T05:06:07Z")
            let diffYear = TestHelper.date("\(currentYear - 1)-12-31T23:59:59Z")
            let compSame = OneTimeComponents(oneTimeDate: sameYear)
            let compDiff = OneTimeComponents(oneTimeDate: diffYear)
            XCTAssertEqual(compSame.readableDayOfYear, sameYear.houndFormatted(.template("MMMMd")))
            XCTAssertEqual(compDiff.readableDayOfYear, diffYear.houndFormatted(.template("MMMMdyyyy")))
            XCTAssertEqual(compSame.readableTimeOfDay, sameYear.houndFormatted(.template("hma")))
            XCTAssertTrue(compSame.readableRecurrance.contains(compSame.readableDayOfYear))
            XCTAssertTrue(compSame.readableRecurrance.contains(compSame.readableTimeOfDay))
        }
    }

    func testDSTBoundaryHandling() throws {
        try withTimezone("America/New_York") {
            let beforeDST = TestHelper.date("2024-03-10T06:59:00Z") // 1:59 AM EST
            let afterDST = TestHelper.date("2024-03-10T07:01:00Z")  // 3:01 AM EDT
            let compBefore = OneTimeComponents(oneTimeDate: beforeDST)
            let compAfter = OneTimeComponents(oneTimeDate: afterDST)
            XCTAssertLessThan(compBefore.readableTimeOfDay, compAfter.readableTimeOfDay)
        }
    }

    func testExtremeDateValues() throws {
        try withTimezone("UTC") {
            let early = Date.distantPast
            let late = Date.distantFuture
            let midnight = TestHelper.date("2024-01-01T00:00:00Z")
            let almostMidnight = TestHelper.date("2024-01-01T23:59:59Z")
            let comps = [OneTimeComponents(oneTimeDate: early),
                         OneTimeComponents(oneTimeDate: late),
                         OneTimeComponents(oneTimeDate: midnight),
                         OneTimeComponents(oneTimeDate: almostMidnight)]
            for c in comps { XCTAssertNotNil(c.oneTimeDate) }
        }
    }
}
