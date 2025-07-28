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
    
    func testReadablePropertiesVariousDates() throws {
        let sameYear = TestHelper.date("2025-01-02T05:06:07Z")
        let diffYear = TestHelper.date("2024-12-31T23:59:59Z")
        let compSame = OneTimeComponents(oneTimeDate: sameYear)
        let compDiff = OneTimeComponents(oneTimeDate: diffYear)
        XCTAssertEqual(
            compSame.readableDayOfYear(displayTimeZone: .utc),
            sameYear.houndFormatted(
                .template("MMMMd"),
                displayTimeZone: .utc
            )
        )
        XCTAssertEqual(
            compDiff.readableDayOfYear(displayTimeZone: .utc),
            diffYear.houndFormatted(
                .template("MMMMdyyyy"),
                displayTimeZone: .utc
            )
        )
        XCTAssertEqual(
            compSame.readableTimeOfDay(displayTimeZone: .utc),
            sameYear.houndFormatted(
                .template("hma"),
                displayTimeZone: .utc
            )
        )
    }
    
    func testDSTBoundaryHandling() throws {
        let newYork = TimeZone(identifier: "America/New_York")!
        let beforeDST = TestHelper.date("2024-03-10T06:59:00Z") // 1:59 AM EST
        let afterDST = TestHelper.date("2024-03-10T07:01:00Z")  // 3:01 AM EDT
        
        let compBefore = OneTimeComponents(oneTimeDate: beforeDST)
        let compAfter = OneTimeComponents(oneTimeDate: afterDST)
        
        XCTAssertLessThan(
            compBefore.readableTimeOfDay(displayTimeZone: newYork),
            compAfter.readableTimeOfDay(displayTimeZone: newYork)
        )
    }
    
    func testExtremeDateValues() throws {
        let early = Date.distantPast
        let late = Date.distantFuture
        let midnight = TestHelper.date("2024-01-01T00:00:00Z")
        let almostMidnight = TestHelper.date("2024-01-01T23:59:59Z")
        
        let comps = [OneTimeComponents(oneTimeDate: early),
                     OneTimeComponents(oneTimeDate: late),
                     OneTimeComponents(oneTimeDate: midnight),
                     OneTimeComponents(oneTimeDate: almostMidnight)]
        for c in comps {
            XCTAssertNotNil(c.oneTimeDate)
        }
    }
}
