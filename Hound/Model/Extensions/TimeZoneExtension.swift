//
//  TimeZoneExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/24/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension TimeZone {
    /// Creates a TimeZone from an identifier string, or returns nil if the string is invalid or nil.
    static func from(_ str: String?) -> TimeZone? {
        guard let str = str else { return nil }
        return TimeZone(identifier: str)
    }

    /// Converts a (hour, minute) in this time zone to the same wall time in a target time zone, for display.
    /// Always uses a fixed reference date (2000-01-01) to avoid DST edge cases.
    func convert(hour: Int, minute: Int, to targetTimeZone: TimeZone) -> (hour: Int, minute: Int) {
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = hour
        components.minute = minute
        components.second = 0
        components.timeZone = self

        let calendar = Calendar(identifier: .gregorian)
        guard let dateInSource = calendar.date(from: components) else {
            return (hour, minute) // Defensive fallback
        }
        let targetComponents = calendar.dateComponents(in: targetTimeZone, from: dateInSource)
        return (targetComponents.hour ?? hour, targetComponents.minute ?? minute)
    }

    /// Converts a list of weekdays (from this time zone) to their equivalents in the target time zone, for a given hour/minute.
    /// Always uses a fixed reference week (starting 2000-01-02) to ensure the weekday value is deterministic.
    func convert(weekdays: [Weekday], hour: Int, minute: Int, to targetTimeZone: TimeZone) -> [Weekday] {
        var targetWeekdays = Set<Weekday>()
        let calendar = Calendar(identifier: .gregorian)
        for weekday in weekdays {
            var components = DateComponents()
            components.year = 2000
            components.month = 1
            components.day = 2 + (weekday.rawValue - 1) // Jan 2, 2000 is a Sunday
            components.hour = hour
            components.minute = minute
            components.second = 0
            components.timeZone = self

            guard let dateInSource = calendar.date(from: components) else { continue }
            let targetComponents = calendar.dateComponents(in: targetTimeZone, from: dateInSource)
            if let targetWeekdayValue = targetComponents.weekday,
               let targetWeekday = Weekday(rawValue: targetWeekdayValue) {
                targetWeekdays.insert(targetWeekday)
            }
        }
        return Array(targetWeekdays).sorted()
    }

    /// Converts a day-of-month/hour/minute from this (zoned/source) time zone into the destination time zone,
    /// including roll-under for months with fewer days, and proper handling of DST/cross-midnight transitions.
    /// - Parameters:
    ///   - day: The user-selected day of the month in the source time zone (1-31)
    ///   - hour: User-selected hour in source time zone
    ///   - minute: User-selected minute in source time zone
    ///   - destinationTimeZone: The tz to display for the user
    ///   - referenceDate: Any date in the desired month (typically next execution date or today)
    /// - Returns: (day, hour, minute) in the destination time zone, after all corrections.
    func convert(
        day: Int,
        hour: Int,
        minute: Int,
        to destinationTimeZone: TimeZone,
        referenceDate: Date
    ) -> (day: Int, hour: Int, minute: Int) // swiftlint:disable:this large_tuple
    {
        let calendar = Calendar(identifier: .gregorian)
        // Clamp day to last valid day in zoned (source) time zone for month of referenceDate
        let daysInMonthSource = calendar.range(of: .day, in: .month, for: referenceDate, in: self)?.count ?? day
        let clampedDay = min(day, daysInMonthSource)
        // Build the source (zoned) date
        var components = calendar.dateComponents(in: self, from: referenceDate)
        components.day = clampedDay
        components.hour = hour
        components.minute = minute
        components.second = 0

        guard let zonedDate = calendar.date(from: components) else {
            // Defensive: fallback if we can't create a date
            return (clampedDay, hour, minute)
        }

        // Convert date to destination tz and get day/hour/minute in target tz
        let localComponents = calendar.dateComponents(in: destinationTimeZone, from: zonedDate)
        // Clamp day to valid range in destination tz (handles roll-under if, for example, the 31st maps to the 30th)
        let daysInMonthDest = calendar.range(of: .day, in: .month, for: zonedDate, in: destinationTimeZone)?.count ?? clampedDay
        let localDay = min(localComponents.day ?? clampedDay, daysInMonthDest)
        let localHour = localComponents.hour ?? hour
        let localMinute = localComponents.minute ?? minute
        return (localDay, localHour, localMinute)
    }
}
