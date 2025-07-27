//
//  WeeklyComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum Weekday: Int, CaseIterable, Comparable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var shortAbbreviation: String {
        switch self {
        case .sunday:    return "Su"
        case .monday:    return "M"
        case .tuesday:   return "Tu"
        case .wednesday: return "W"
        case .thursday:  return "Th"
        case .friday:    return "F"
        case .saturday:  return "Sa"
        }
    }
    var longName: String {
        switch self {
        case .sunday:    return "Sunday"
        case .monday:    return "Monday"
        case .tuesday:   return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday:  return "Thursday"
        case .friday:    return "Friday"
        case .saturday:  return "Saturday"
        }
    }
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool { lhs.rawValue < rhs.rawValue }
}

final class WeeklyComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = WeeklyComponents()
        copy.zonedSunday = self.zonedSunday
        copy.zonedMonday = self.zonedMonday
        copy.zonedTuesday = self.zonedTuesday
        copy.zonedWednesday = self.zonedWednesday
        copy.zonedThursday = self.zonedThursday
        copy.zonedFriday = self.zonedFriday
        copy.zonedSaturday = self.zonedSaturday
        copy.zonedHour = self.zonedHour
        copy.zonedMinute = self.zonedMinute
        copy.skippedDate = self.skippedDate
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let zonedSunday = aDecoder.decodeOptionalBool(forKey: Constant.Key.weeklyZonedSunday.rawValue)
        let zonedMonday = aDecoder.decodeOptionalBool(forKey: Constant.Key.weeklyZonedMonday.rawValue)
        let zonedTuesday = aDecoder.decodeOptionalBool(forKey: Constant.Key.weeklyZonedTuesday.rawValue)
        let zonedWednesday = aDecoder.decodeOptionalBool(forKey: Constant.Key.weeklyZonedWednesday.rawValue)
        let zonedThursday = aDecoder.decodeOptionalBool(forKey: Constant.Key.weeklyZonedThursday.rawValue)
        let zonedFriday = aDecoder.decodeOptionalBool(forKey: Constant.Key.weeklyZonedFriday.rawValue)
        let zonedSaturday = aDecoder.decodeOptionalBool(forKey: Constant.Key.weeklyZonedSaturday.rawValue)
        let zonedHour = aDecoder.decodeOptionalInteger(forKey: Constant.Key.weeklyZonedHour.rawValue)
        let zonedMinute = aDecoder.decodeOptionalInteger(forKey: Constant.Key.weeklyZonedMinute.rawValue)
        let skippedDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.weeklySkippedDate.rawValue)
        
        self.init(
            zonedSunday: zonedSunday,
            zonedMonday: zonedMonday,
            zonedTuesday: zonedTuesday,
            zonedWednesday: zonedWednesday,
            zonedThursday: zonedThursday,
            zonedFriday: zonedFriday,
            zonedSaturday: zonedSaturday,
            zonedHour: zonedHour,
            zonedMinute: zonedMinute,
            skippedDate: skippedDate
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(zonedSunday, forKey: Constant.Key.weeklyZonedSunday.rawValue)
        aCoder.encode(zonedMonday, forKey: Constant.Key.weeklyZonedMonday.rawValue)
        aCoder.encode(zonedTuesday, forKey: Constant.Key.weeklyZonedTuesday.rawValue)
        aCoder.encode(zonedWednesday, forKey: Constant.Key.weeklyZonedWednesday.rawValue)
        aCoder.encode(zonedThursday, forKey: Constant.Key.weeklyZonedThursday.rawValue)
        aCoder.encode(zonedFriday, forKey: Constant.Key.weeklyZonedFriday.rawValue)
        aCoder.encode(zonedSaturday, forKey: Constant.Key.weeklyZonedSaturday.rawValue)
        aCoder.encode(zonedHour, forKey: Constant.Key.weeklyZonedHour.rawValue)
        aCoder.encode(zonedMinute, forKey: Constant.Key.weeklyZonedMinute.rawValue)
        if let skippedDate = skippedDate {
            aCoder.encode(skippedDate, forKey: Constant.Key.weeklySkippedDate.rawValue)
        }
    }
    
    // MARK: - Properties
    
    private var zonedSunday: Bool = true
    private var zonedMonday: Bool = true
    private var zonedTuesday: Bool = true
    private var zonedWednesday: Bool = true
    private var zonedThursday: Bool = true
    private var zonedFriday: Bool = true
    private var zonedSaturday: Bool = true
    var zonedWeekdays: [Weekday] {
        var weekdays: [Weekday] = []
        if zonedSunday { weekdays.append(.sunday) }
        if zonedMonday { weekdays.append(.monday) }
        if zonedTuesday { weekdays.append(.tuesday) }
        if zonedWednesday { weekdays.append(.wednesday) }
        if zonedThursday { weekdays.append(.thursday) }
        if zonedFriday { weekdays.append(.friday) }
        if zonedSaturday { weekdays.append(.saturday) }
        return weekdays
    }
    func setZonedWeekdays(_ weekdays: [Weekday]) -> Bool {
        guard !weekdays.isEmpty else {
            return false
        }
        zonedSunday = weekdays.contains(.sunday)
        zonedMonday = weekdays.contains(.monday)
        zonedTuesday = weekdays.contains(.tuesday)
        zonedWednesday = weekdays.contains(.wednesday)
        zonedThursday = weekdays.contains(.thursday)
        zonedFriday = weekdays.contains(.friday)
        zonedSaturday = weekdays.contains(.saturday)
        return true
    }
    
    var zonedHour: Int = Constant.Class.ReminderComponent.defaultZonedHour
    var zonedMinute: Int = Constant.Class.ReminderComponent.defaultZonedMinute
    
    /// The date at which the user changed the isSkipping to true.  If is skipping is true, then a certain log date was appended. If unskipped, then we have to remove that previously added log. Slight caveat: if the skip log was modified (by the user changing its date) we don't remove it.
    var skippedDate: Date?
    var isSkipping: Bool {
        skippedDate != nil
    }
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    convenience init(
        zonedSunday: Bool? = nil,
        zonedMonday: Bool? = nil,
        zonedTuesday: Bool? = nil,
        zonedWednesday: Bool? = nil,
        zonedThursday: Bool? = nil,
        zonedFriday: Bool? = nil,
        zonedSaturday: Bool? = nil,
        zonedHour: Int? = nil,
        zonedMinute: Int? = nil,
        skippedDate: Date? = nil
    ) {
        self.init()
        self.zonedSunday = zonedSunday ?? self.zonedSunday
        self.zonedMonday = zonedMonday ?? self.zonedMonday
        self.zonedTuesday = zonedTuesday ?? self.zonedTuesday
        self.zonedWednesday = zonedWednesday ?? self.zonedWednesday
        self.zonedThursday = zonedThursday ?? self.zonedThursday
        self.zonedFriday = zonedFriday ?? self.zonedFriday
        self.zonedSaturday = zonedSaturday ?? self.zonedSaturday
        self.zonedHour = zonedHour ?? self.zonedHour
        self.zonedMinute = zonedMinute ?? self.zonedMinute
        self.skippedDate = skippedDate ?? self.skippedDate
    }
    
    convenience init(fromBody: JSONResponseBody, componentToOverride: WeeklyComponents?) {
        let weeklyZonedSunday: Bool? = fromBody[Constant.Key.weeklyZonedSunday.rawValue] as? Bool ?? componentToOverride?.zonedSunday
        let weeklyZonedMonday: Bool? = fromBody[Constant.Key.weeklyZonedMonday.rawValue] as? Bool ?? componentToOverride?.zonedMonday
        let weeklyZonedTuesday: Bool? = fromBody[Constant.Key.weeklyZonedTuesday.rawValue] as? Bool ?? componentToOverride?.zonedTuesday
        let weeklyZonedWednesday: Bool? = fromBody[Constant.Key.weeklyZonedWednesday.rawValue] as? Bool ?? componentToOverride?.zonedWednesday
        let weeklyZonedThursday: Bool? = fromBody[Constant.Key.weeklyZonedThursday.rawValue] as? Bool ?? componentToOverride?.zonedThursday
        let weeklyZonedFriday: Bool? = fromBody[Constant.Key.weeklyZonedFriday.rawValue] as? Bool ?? componentToOverride?.zonedFriday
        let weeklyZonedSaturday: Bool? = fromBody[Constant.Key.weeklyZonedSaturday.rawValue] as? Bool ?? componentToOverride?.zonedSaturday
        let weeklyZonedHour: Int? = fromBody[Constant.Key.weeklyZonedHour.rawValue] as? Int ?? componentToOverride?.zonedHour
        let weeklyZonedMinute: Int? = fromBody[Constant.Key.weeklyZonedMinute.rawValue] as? Int ?? componentToOverride?.zonedMinute
        let weeklySkippedDate: Date? = (fromBody[Constant.Key.weeklySkippedDate.rawValue] as? String)?.formatISO8601IntoDate() ?? componentToOverride?.skippedDate
        
        self.init(
            zonedSunday: weeklyZonedSunday,
            zonedMonday: weeklyZonedMonday,
            zonedTuesday: weeklyZonedTuesday,
            zonedWednesday: weeklyZonedWednesday,
            zonedThursday: weeklyZonedThursday,
            zonedFriday: weeklyZonedFriday,
            zonedSaturday: weeklyZonedSaturday,
            zonedHour: weeklyZonedHour,
            zonedMinute: weeklyZonedMinute,
            skippedDate: weeklySkippedDate
        )
    }
    
    // MARK: - Functions
    
    func localTimeOfDay(from zonedTimeZone: TimeZone, to destinationTimeZone: TimeZone) -> (hour: Int, minute: Int) {
        return zonedTimeZone.convert(hour: zonedHour, minute: zonedMinute, to: destinationTimeZone)
    }
    
    func localWeekdays(from zonedTimeZone: TimeZone, to destinationTimeZone: TimeZone) -> [Weekday] {
        return zonedTimeZone.convert(weekdays: zonedWeekdays, hour: zonedHour, minute: zonedMinute, to: destinationTimeZone)
    }
    
    func readableDaysOfWeek(from zonedTimeZone: TimeZone, to destinationTimeZone: TimeZone) -> String {
        let mappedWeekdays = zonedTimeZone.convert(weekdays: zonedWeekdays, hour: zonedHour, minute: zonedMinute, to: destinationTimeZone)
        switch Set(mappedWeekdays) {
        case Set(Weekday.allCases): return "Everyday"
        case [.sunday, .saturday]: return "Weekends"
        case [.monday, .tuesday, .wednesday, .thursday, .friday]: return "Weekdays"
        default:
            let abbreviate = mappedWeekdays.count > 1
            return mappedWeekdays.sorted().map { abbreviate ? $0.shortAbbreviation : $0.longName }.joined(separator: ", ")
        }
    }
    
    func readableTimeOfDay(from zonedTimeZone: TimeZone, to destinationTimeZone: TimeZone) -> String {
        let (hour, minute) = zonedTimeZone.convert(hour: zonedHour, minute: zonedMinute, to: destinationTimeZone)
        return String.convert(hour: hour, minute: minute)
    }
    
    func readableRecurrance(from zonedTimeZone: TimeZone, to destinationTimeZone: TimeZone) -> String {
        let readableDaysOfWeek = readableDaysOfWeek(from: zonedTimeZone, to: destinationTimeZone)
        let readableTimeOfDay = readableTimeOfDay(from: zonedTimeZone, to: destinationTimeZone)
        return readableDaysOfWeek.appending(" at \(readableTimeOfDay)")
    }

    // MARK: - Mutation

    /// Updates the component using a date in the provided time zone and a set of weekdays.
    /// - Returns: `true` if weekdays were valid and applied.
    @discardableResult
    func configure(from date: Date, timeZone: TimeZone, weekdays: [Weekday]) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents(in: timeZone, from: date)
        zonedHour = comps.hour ?? zonedHour
        zonedMinute = comps.minute ?? zonedMinute
        return setZonedWeekdays(weekdays)
    }
    
    // MARK: - Timing
    
    /// Determines the next execution date, considering isSkipping state, based on `sourceTimeZone`.
    func nextExecutionDate(reminderExecutionBasis: Date, sourceTimeZone: TimeZone) -> Date {
        return isSkipping
        ? skippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, sourceTimeZone: sourceTimeZone)
        : notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, sourceTimeZone: sourceTimeZone)
    }
    
    /// Finds the next execution date after `reminderExecutionBasis`, using zoned weekdays/hours/minutes in the specified `sourceTimeZone`.
    /// Skipping state is NOT factored in.
    /// - Returns: The closest valid future execution date (or default date if none found).
    func notSkippingExecutionDate(reminderExecutionBasis: Date, sourceTimeZone: TimeZone) -> Date {
        let futureDates = futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis, sourceTimeZone: sourceTimeZone)
        return futureDates.first(where: { $0 > reminderExecutionBasis }) ?? Constant.Class.Date.default1970Date
    }
    
    /// If a reminder is skipping, find the next soonest execution date after the skipped one.
    /// Returns: The next valid execution date strictly after the skipped one, or default date if none found.
    private func skippingExecutionDate(reminderExecutionBasis: Date, sourceTimeZone: TimeZone) -> Date {
        let nextExecution = notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, sourceTimeZone: sourceTimeZone)
        // The next execution after the skipped one, robustly (no +7 day fudge).
        let futureDates = futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis, sourceTimeZone: sourceTimeZone)
        return futureDates.first(where: { $0 > nextExecution }) ?? Constant.Class.Date.default1970Date
    }
    
    /// Finds the most recent valid execution date strictly before `reminderExecutionBasis`
    /// based on the component's zoned weekdays, hour, and minute, in the specified `sourceTimeZone`.
    /// Robust to DST and ambiguous/skipped times.
    func previousExecutionDate(reminderExecutionBasis: Date, sourceTimeZone: TimeZone) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var latestPrevious: Date?
        // Try all active weekdays to find the most recent valid date < basis
        for zonedWeekday in zonedWeekdays {
            var components = calendar.dateComponents(in: sourceTimeZone, from: reminderExecutionBasis)
            components.weekday = zonedWeekday.rawValue
            components.hour = zonedHour
            components.minute = zonedMinute
            components.second = 0
            
            // Use direction: .backward to get previous matching
            if let previous = calendar.nextDate(
                after: reminderExecutionBasis,
                matching: components,
                matchingPolicy: .nextTimePreservingSmallerComponents,
                repeatedTimePolicy: .first,
                direction: .backward
            ) {
                if latestPrevious == nil {
                    latestPrevious = previous
                }
                else if let lp = latestPrevious, previous > lp {
                    latestPrevious = previous
                }
            }
        }
        // Return the latest found or your chosen default
        return latestPrevious ?? Constant.Class.Date.default1970Date
    }
    
    /// Computes the next three valid execution dates (in strict chronological order) in the specified source time zone,
    /// using the object's zoned weekdays, hour, and minute, relative to `reminderExecutionBasis`.
    /// This function is robust to DST changes, ambiguous times, and ensures results are always valid for the zone provided.
    private func futureExecutionDates(reminderExecutionBasis: Date, sourceTimeZone: TimeZone) -> [Date] {
        let calendar = Calendar(identifier: .gregorian)
        var dates: [Date] = []
        var searchBasis = reminderExecutionBasis
        
        // Compute the next 3 valid, non-ambiguous, non-skipped occurrences.
        for _ in 0..<3 {
            var soonest: Date?
            for zonedWeekday in zonedWeekdays {
                var components = calendar.dateComponents(in: sourceTimeZone, from: searchBasis)
                components.weekday = zonedWeekday.rawValue
                components.hour = zonedHour
                components.minute = zonedMinute
                components.second = 0
                
                // Use .nextTimePreservingSmallerComponents to handle DST and real-world scheduling.
                if let next = calendar.nextDate(
                    after: searchBasis,
                    matching: components,
                    matchingPolicy: .nextTimePreservingSmallerComponents,
                    repeatedTimePolicy: .first,
                    direction: .forward
                ) {
                    if soonest == nil {
                        soonest = next
                    }
                    else if let s = soonest, next < s {
                        soonest = next
                    }
                }
            }
            if let found = soonest {
                dates.append(found)
                // Advance search basis for next iteration
                searchBasis = found.addingTimeInterval(1)
            }
            else {
                break // No further dates found
            }
        }
        return dates
    }
    
    // MARK: - Compare
    
    /// Returns true if all stored properties are equivalent
    func isSame(as other: WeeklyComponents) -> Bool {
        if zonedSunday != other.zonedSunday { return false }
        if zonedMonday != other.zonedMonday { return false }
        if zonedTuesday != other.zonedTuesday { return false }
        if zonedWednesday != other.zonedWednesday { return false }
        if zonedThursday != other.zonedThursday { return false }
        if zonedFriday != other.zonedFriday { return false }
        if zonedSaturday != other.zonedSaturday { return false }
        if zonedHour != other.zonedHour { return false }
        if zonedMinute != other.zonedMinute { return false }
        if isSkipping != other.isSkipping { return false }
        if skippedDate != other.skippedDate { return false }
        return true
    }
    
    // MARK: - Request
    
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.weeklyZonedSunday.rawValue] = .bool(zonedSunday)
        body[Constant.Key.weeklyZonedMonday.rawValue] = .bool(zonedMonday)
        body[Constant.Key.weeklyZonedTuesday.rawValue] = .bool(zonedTuesday)
        body[Constant.Key.weeklyZonedWednesday.rawValue] = .bool(zonedWednesday)
        body[Constant.Key.weeklyZonedThursday.rawValue] = .bool(zonedThursday)
        body[Constant.Key.weeklyZonedFriday.rawValue] = .bool(zonedFriday)
        body[Constant.Key.weeklyZonedSaturday.rawValue] = .bool(zonedSaturday)
        body[Constant.Key.weeklyZonedHour.rawValue] = .int(zonedHour)
        body[Constant.Key.weeklyZonedMinute.rawValue] = .int(zonedMinute)
        body[Constant.Key.weeklySkippedDate.rawValue] = .string(skippedDate?.ISO8601FormatWithFractionalSeconds())
        return body
    }
}
