//
//  TimeZoneExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/24/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation
extension TimeZone {
    static func from(_ str: String?) -> TimeZone? {
        guard let str = str else {
            return nil
        }
        
        return TimeZone(identifier: str)
    }
    
    func convert(hour: Int, minute: Int, to targetTimeZone: TimeZone) -> (hour: Int, minute: Int) {
        var components = DateComponents()
        components.year = 2000 // Arbitrary fixed date to avoid DST edge cases
        components.month = 1
        components.day = 1
        components.hour = hour
        components.minute = minute
        components.second = 0
        components.timeZone = self

        let calendar = Calendar(identifier: .gregorian)
        guard let dateInSource = calendar.date(from: components) else {
            return (hour, minute) // Fallback, shouldn't happen
        }

        // Get hour and minute in target time zone
        let targetComponents = calendar.dateComponents(in: targetTimeZone, from: dateInSource)
        let targetHour = targetComponents.hour ?? hour
        let targetMinute = targetComponents.minute ?? minute

        return (targetHour, targetMinute)
    }
    
    func convert(weekdays: [Weekday], hour: Int, minute: Int, to targetTimeZone: TimeZone) -> [Weekday] {
            var targetWeekdays = Set<Weekday>()
            let calendar = Calendar(identifier: .gregorian)
            for weekday in weekdays {
                // Pick an arbitrary reference week (Monday, Jan 3, 2000 is a Monday)
                var components = DateComponents()
                components.year = 2000
                components.month = 1
                // Sunday = 1, so set the day accordingly
                // Jan 2, 2000 is Sunday, Jan 3 is Monday, etc.
                components.day = 2 + (weekday.rawValue - 1)
                components.hour = hour
                components.minute = minute
                components.second = 0
                components.timeZone = self

                guard let dateInSource = calendar.date(from: components) else { continue }
                // Get the weekday in the target time zone
                let targetComponents = calendar.dateComponents(in: targetTimeZone, from: dateInSource)
                if let targetWeekdayValue = targetComponents.weekday, let targetWeekday = Weekday(rawValue: targetWeekdayValue) {
                    targetWeekdays.insert(targetWeekday)
                }
            }
            return Array(targetWeekdays).sorted()
        }
}
