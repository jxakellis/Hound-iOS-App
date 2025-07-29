//
//  TimeZoneExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/24/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension TimeZone {
    
    // Prevent repetitive recalculation of these static properties by caching them
    private struct Cache {
        static let houndTimeZones: [TimeZone] = {
            TimeZone.knownTimeZoneIdentifiers
                .compactMap { TimeZone(identifier: $0) }
                .sorted {
                    let gmtA = $0.secondsFromGMT()
                    let gmtB = $1.secondsFromGMT()
                    if gmtA != gmtB {
                        return gmtA < gmtB
                    }
                    else {
                        return $0.displayName().localizedCaseInsensitiveCompare($1.displayName()) == .orderedAscending
                    }
                }
        }()
        
        static let genericNameCounts: [String: Int] = {
            var counts = [String: Int]()
            for id in TimeZone.knownTimeZoneIdentifiers {
                if let tz = TimeZone(identifier: id) {
                    let name = tz.localizedName(for: .generic, locale: .current) ?? tz.identifier
                    counts[name, default: 0] += 1
                }
            }
            return counts
        }()
    }
    
    static var houndTimeZones: [TimeZone] {
        return Cache.houndTimeZones
    }
    
    func displayName(currentTimeZone: TimeZone? = nil) -> String {
        let genericName = self.localizedName(for: .generic, locale: .current) ?? ""
        let cityName = self.identifier.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? self.identifier
        
        let seconds = self.secondsFromGMT()
        let hours = abs(seconds) / 3600
        let minutes = (abs(seconds) % 3600) / 60
        let sign = seconds >= 0 ? "+" : "-"
        let offsetString = String(format: "%@%02d:%02d", sign, hours, minutes)
        
        let currentSuffix = (self.identifier == currentTimeZone?.identifier) ? " (Current)" : ""
        // Example: "Pacific Time (Los Angeles) -08:00"
        // Only show city if genericName is not unique
        let needsCity = (Cache.genericNameCounts[genericName] ?? 0) > 1
        
        if needsCity {
            return "\(genericName) (\(cityName)) \(offsetString)\(currentSuffix)"
        }
        else {
            return "\(genericName) \(offsetString)\(currentSuffix)"
        }
    }
    
    // MARK: - Time Zone Constructions
    
    /// Creates a TimeZone from an identifier string, or returns nil if the string is invalid or nil.
    static func from(_ str: String?) -> TimeZone? {
        guard let str = str else { return nil }
        return TimeZone(identifier: str)
    }
    
    // MARK: - Conversions
    
    /// Converts a (hour, minute) in this time zone to the same wall time in a target time zone, for display.
    /// Always uses a fixed reference date (2000-01-01) to avoid DST edge cases.
    func convert(hour: Int, minute: Int, to destinationTimeZone: TimeZone) -> (hour: Int, minute: Int) {
        guard self != destinationTimeZone else {
            return (hour, minute)
        }
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = hour
        components.minute = minute
        components.second = 0

        // 1. Use a calendar in the source time zone to build the date.
        let sourceCalendar = Calendar.fromZone(self)
        guard let dateInSource = sourceCalendar.date(from: components) else {
            return (hour, minute)
        }

        // 2. Use destination calendar to extract the new hour/minute.
        let destCalendar = Calendar.fromZone(destinationTimeZone)
        let targetComponents = destCalendar.dateComponents([.hour, .minute], from: dateInSource)
        return (targetComponents.hour ?? hour, targetComponents.minute ?? minute)
    }
    
    /// Converts a list of weekdays (from this time zone) to their equivalents in the target time zone, for a given hour/minute.
    /// Always uses a fixed reference week (starting 2000-01-02) to ensure the weekday value is deterministic.
    func convert(weekdays: [Weekday], hour: Int, minute: Int, to destinationTimeZone: TimeZone) -> [Weekday] {
        guard self != destinationTimeZone else {
            return weekdays // No conversion needed
        }
        var targetWeekdays = Set<Weekday>()
        let sourceCalendar = Calendar.fromZone(self)
        let destCalendar = Calendar.fromZone(destinationTimeZone)
        for weekday in weekdays {
            var components = DateComponents()
            components.year = 2000
            components.month = 1
            components.day = 2 + (weekday.rawValue - 1)
            components.hour = hour
            components.minute = minute
            components.second = 0

            guard let dateInSource = sourceCalendar.date(from: components) else { continue }
            let targetComponents = destCalendar.dateComponents([.weekday], from: dateInSource)
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
    ) -> (day: Int, hour: Int, minute: Int) {
        guard self != destinationTimeZone else {
            return (day, hour, minute) // No conversion needed
        }
        let sourceCalendar = Calendar.fromZone(self)
        
        // Clamp day to last valid day in zoned (source) time zone for month of referenceDate
        let daysInMonthSource = sourceCalendar.range(of: .day, in: .month, for: referenceDate, in: self)?.count ?? day
        let clampedDay = min(day, daysInMonthSource)
        
        // Build the source (zoned) date
        var components = sourceCalendar.dateComponents([.year, .month], from: referenceDate)
        components.day = clampedDay
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        guard let sourceDate = sourceCalendar.date(from: components) else {
            // Defensive: fallback if we can't create a date
            return (clampedDay, hour, minute)
        }
        
        let destinationCalendar = Calendar.fromZone(destinationTimeZone)
        
        // Convert date to destination tz and get day/hour/minute in target tz
        let destComponents = destinationCalendar.dateComponents([.day, .hour, .minute], from: sourceDate)
        
        // Clamp day to last day of month in dest time zone
        let daysInDestMonth = destinationCalendar.range(of: .day, in: .month, for: sourceDate)?.count ?? (destComponents.day ?? clampedDay)
        
        let destDay = min(destComponents.day ?? clampedDay, daysInDestMonth)
        let destHour = destComponents.hour ?? hour
        let destMinute = destComponents.minute ?? minute
        return (destDay, destHour, destMinute)
    }
}
