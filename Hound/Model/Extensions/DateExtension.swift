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
    case template(String)
    
    /// Returns a formatted string for the supplied date based on the style, in the given time zone.
    func string(from date: Date, localizedTo: TimeZone? = nil) -> String {
        switch self {
        case let .formatStyle(dateStyle, timeStyle):
            var style = Date.FormatStyle(date: dateStyle, time: timeStyle, timeZone: localizedTo ?? .autoupdatingCurrent)
            return date.formatted(style)
        case let .template(template):
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate(template)
            if let tz = localizedTo {
                formatter.timeZone = tz
            }
            return formatter.string(from: date)
        }
    }
}

extension Date {
    
    func ISO8601FormatWithFractionalSeconds() -> String {
        self.ISO8601Format(Date.ISO8601FormatStyle.init(dateSeparator: .dash, dateTimeSeparator: .standard, timeSeparator: .colon, includingFractionalSeconds: true))
    }
    
    func houndFormatted(_ format: HoundDateFormat, localizedTo: TimeZone? = nil) -> String {
        format.string(from: self, localizedTo: localizedTo)
    }
    
    /// Returns a rounded version of targetDate depending on roundingInterval, e.g. targetDate 18:41:51 -> rounded 18:42:00 for RI of 10 but for a RI of 5 rounded 18:41:50
    static func roundDate(targetDate: Date, roundingInterval: Double, roundingMethod: FloatingPointRoundingRule) -> Date {
        let rounded = Date(timeIntervalSinceReferenceDate: (targetDate.timeIntervalSinceReferenceDate / roundingInterval).rounded(roundingMethod) * roundingInterval)
        return rounded
    }
}
