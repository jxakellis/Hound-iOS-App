//
//  DateExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 12/8/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension Date {

    func ISO8601FormatWithFractionalSeconds() -> String {
        self.ISO8601Format(Date.ISO8601FormatStyle.init(dateSeparator: .dash, dateTimeSeparator: .standard, timeSeparator: .colon, includingFractionalSeconds: true))
    }

    /// Returns a rounded version of targetDate depending on roundingInterval, e.g. targetDate 18:41:51 -> rounded 18:42:00 for RI of 10 but for a RI of 5 rounded 18:41:50
    static func roundDate(targetDate: Date, roundingInterval: TimeInterval, roundingMethod: FloatingPointRoundingRule) -> Date {
        let rounded = Date(timeIntervalSinceReferenceDate: (targetDate.timeIntervalSinceReferenceDate / roundingInterval).rounded(roundingMethod) * roundingInterval)
        return rounded
    }
}
