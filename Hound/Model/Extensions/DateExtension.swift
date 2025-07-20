//
//  DateExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 12/8/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum HoundDateFormat {
    case formatStyle(date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle)
    case formatterStyle(date: DateFormatter.Style, time: DateFormatter.Style)
    case template(String)
    case custom(String)

    /// Returns a formatted string for the supplied date based on the style.
    func string(from date: Date) -> String {
        switch self {
        case let .formatStyle(dateStyle, timeStyle):
            return date.formatted(date: dateStyle, time: timeStyle)
        case let .formatterStyle(dateStyle, timeStyle):
            let formatter = DateFormatter()
            formatter.dateStyle = dateStyle
            formatter.timeStyle = timeStyle
            return formatter.string(from: date)
        case let .template(template):
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate(template)
            return formatter.string(from: date)
        case let .custom(format):
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.string(from: date)
        }
    }
}

extension Date {

    func ISO8601FormatWithFractionalSeconds() -> String {
        self.ISO8601Format(Date.ISO8601FormatStyle.init(dateSeparator: .dash, dateTimeSeparator: .standard, timeSeparator: .colon, includingFractionalSeconds: true))
    }
    
    func houndFormatted(_ format: HoundDateFormat) -> String {
            format.string(from: self)
        }

    /// Returns a rounded version of targetDate depending on roundingInterval, e.g. targetDate 18:41:51 -> rounded 18:42:00 for RI of 10 but for a RI of 5 rounded 18:41:50
    static func roundDate(targetDate: Date, roundingInterval: Double, roundingMethod: FloatingPointRoundingRule) -> Date {
        let rounded = Date(timeIntervalSinceReferenceDate: (targetDate.timeIntervalSinceReferenceDate / roundingInterval).rounded(roundingMethod) * roundingInterval)
        return rounded
    }
}
