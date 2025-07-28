//
//  MonthlyComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class MonthlyComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MonthlyComponents()
        copy.zonedDay = self.zonedDay
        copy.zonedHour = self.zonedHour
        copy.zonedMinute = self.zonedMinute
        copy.skippedDate = self.skippedDate
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let zonedDay = aDecoder.decodeOptionalInteger(forKey: Constant.Key.monthlyZonedDay.rawValue)
        let zonedHour = aDecoder.decodeOptionalInteger(forKey: Constant.Key.monthlyZonedHour.rawValue)
        let zonedMinute = aDecoder.decodeOptionalInteger(forKey: Constant.Key.monthlyZonedMinute.rawValue)
        let skippedDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.monthlySkippedDate.rawValue)
        
        self.init(zonedDay: zonedDay, zonedHour: zonedHour, zonedMinute: zonedMinute, skippedDate: skippedDate)
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        aCoder.encode(zonedDay, forKey: Constant.Key.monthlyZonedDay.rawValue)
        aCoder.encode(zonedHour, forKey: Constant.Key.monthlyZonedHour.rawValue)
        aCoder.encode(zonedMinute, forKey: Constant.Key.monthlyZonedMinute.rawValue)
        if let skippedDate = skippedDate {
            aCoder.encode(skippedDate, forKey: Constant.Key.monthlySkippedDate.rawValue)
        }
    }
    
    // MARK: - Properties
    
    /// User-selected day of month in the source time zone (1-31).
    /// If this value exceeds the days in a particular month (e.g. 31 in April), the calculation will roll down to the last day of the month (e.g. April 30).
    private(set) var zonedDay: Int = Constant.Class.ReminderComponent.defaultZonedDay
    /// User-selected hour in the source time zone (0-23).
    private(set) var zonedHour: Int = Constant.Class.ReminderComponent.defaultZonedHour
    /// User-selected minute in the source time zone (0-59).
    private(set) var zonedMinute: Int = Constant.Class.ReminderComponent.defaultZonedMinute
    
    /// Set to non-nil if the next scheduled execution should be skipped (e.g. due to a user-initiated skip).
    var skippedDate: Date?
    var isSkipping: Bool { skippedDate != nil }
    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    convenience init(zonedDay: Int? = nil, zonedHour: Int? = nil, zonedMinute: Int? = nil, skippedDate: Date? = nil) {
        self.init()
        self.zonedDay = zonedDay ?? self.zonedDay
        self.zonedHour = zonedHour ?? self.zonedHour
        self.zonedMinute = zonedMinute ?? self.zonedMinute
        self.skippedDate = skippedDate ?? self.skippedDate
    }
    
    convenience init(fromBody: JSONResponseBody, componentToOverride: MonthlyComponents?) {
        let monthlyZonedDay = fromBody[Constant.Key.monthlyZonedDay.rawValue] as? Int ?? componentToOverride?.zonedDay
        let monthlyZonedHour = fromBody[Constant.Key.monthlyZonedHour.rawValue] as? Int ?? componentToOverride?.zonedHour
        let monthlyZonedMinute = fromBody[Constant.Key.monthlyZonedMinute.rawValue] as? Int ?? componentToOverride?.zonedMinute
        let monthlySkippedDate = (fromBody[Constant.Key.monthlySkippedDate.rawValue] as? String)?.formatISO8601IntoDate() ?? componentToOverride?.skippedDate
        
        self.init(zonedDay: monthlyZonedDay, zonedHour: monthlyZonedHour, zonedMinute: monthlyZonedMinute, skippedDate: monthlySkippedDate)
    }
    
    // MARK: - Functions
    
    func localTimeOfDay(reminderTimeZone: TimeZone, displayTimeZone: TimeZone? = nil) -> (hour: Int, minute: Int) {
        return reminderTimeZone.convert(hour: zonedHour, minute: zonedMinute, to: displayTimeZone ?? reminderTimeZone)
    }
    
    func localDayOfMonth(reminderTimeZone: TimeZone, displayTimeZone: TimeZone? = nil) -> Int {
        let referenceDate = notSkippingExecutionDate(
            reminderExecutionBasis: Date(),
            reminderTimeZone: reminderTimeZone
        )
        
        let (day, _, _) = reminderTimeZone.convert(
            day: zonedDay,
            hour: zonedHour,
            minute: zonedMinute,
            to: displayTimeZone ?? reminderTimeZone,
            referenceDate: referenceDate ?? Constant.Class.Date.default1970Date
        )
        return day
    }
    
    /// Returns a readable recurrence string in the *destination* time zone.
    /// Example: "Every 31st at 7:30 PM" (will adjust hour/minute for destination zone).
    /// NOTE: If the requested day does not exist in a month, the reminder will run on the last valid day of that month (e.g. "31" on April will run April 30).
    func readableRecurrence(reminderExecutionBasis: Date, reminderTimeZone: TimeZone, displayTimeZone: TimeZone? = nil) -> String {
        let referenceDate = notSkippingExecutionDate(
            reminderExecutionBasis: reminderExecutionBasis,
            reminderTimeZone: reminderTimeZone
        )
        
        let (day, hour, minute) = reminderTimeZone.convert(
            day: zonedDay,
            hour: zonedHour,
            minute: zonedMinute,
            to: displayTimeZone ?? reminderTimeZone,
            referenceDate: referenceDate ?? reminderExecutionBasis
        )
        return "Every \(day)\(day.daySuffix()) at \(String.convert(hour: hour, minute: minute))"
    }
    
    // MARK: - Mutation
    
    /// Updates the component using the provided date in the specified time zone.
    func configure(from date: Date, timeZone: TimeZone) {
        let calendar = Calendar.fromZone(timeZone)
        let comps = calendar.dateComponents([.day, .hour, .minute], from: date)
        if let day = comps.day { zonedDay = day }
        if let hour = comps.hour { zonedHour = hour }
        if let minute = comps.minute { zonedMinute = minute }
    }
    
    /// Copies zoned values from another monthly component.
    func apply(from other: MonthlyComponents) {
        zonedDay = other.zonedDay
        zonedHour = other.zonedHour
        zonedMinute = other.zonedMinute
    }
    
    // MARK: - Timing
    
    /// Finds the next valid execution date after `reminderExecutionBasis`, using the user-selected day/hour/minute in the specified reminderTimeZone.
    /// - If isSkipping is true, skips the soonest and returns the following date.
    /// - If the selected day does not exist in a month (e.g. 31st in February), the calculation will roll down to the last day of the month.
    /// - Handles DST and ambiguous/missing times using `.nextTimePreservingSmallerComponents`.
    func nextExecutionDate(reminderExecutionBasis: Date, reminderTimeZone: TimeZone) -> Date? {
        isSkipping
        ? skippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone)
        : notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone)
    }
    
    /// Returns the first valid execution date strictly after the basis, or 1970 if none.
    func notSkippingExecutionDate(reminderExecutionBasis: Date, reminderTimeZone: TimeZone) -> Date? {
        futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone)
            .first(where: { $0 > reminderExecutionBasis })
    }
    
    /// Finds the previous valid execution date before the basis.
    /// Handles day roll-down if day exceeds days in target month, and is robust to DST.
    func previousExecutionDate(reminderExecutionBasis: Date, reminderTimeZone: TimeZone) -> Date? {
        let calendar = Calendar.fromZone(reminderTimeZone)
        var searchBasis = reminderExecutionBasis.addingTimeInterval(-1)
        
        for _ in 0..<12 { // Look back up to 12 months to find a valid previous date
            let daysInMonth = calendar.range(of: .day, in: .month, for: searchBasis)?.count ?? zonedDay
            let targetDay = min(zonedDay, daysInMonth)
            
            var components = calendar.dateComponents(in: reminderTimeZone, from: searchBasis)
            components.day = targetDay
            components.hour = zonedHour
            components.minute = zonedMinute
            components.second = 0
            
            if let previousDate = calendar.date(from: components), previousDate < reminderExecutionBasis {
                return previousDate
            }
            
            // Step back one month if no valid date found yet
            guard let newSearchBasis = calendar.date(byAdding: .month, value: -1, to: searchBasis) else {
                return nil
            }
            searchBasis = newSearchBasis
        }
        
        return nil
    }
    
    /// Returns the next valid execution date after the one that would normally be triggered (skipping state).
    private func skippingExecutionDate(reminderExecutionBasis: Date, reminderTimeZone: TimeZone) -> Date? {
        guard let nextExecution = notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone) else {
            return nil
        }
        let futureDates = futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis, reminderTimeZone: reminderTimeZone)
        return futureDates.first(where: { $0 > nextExecution })
    }
    
    /// Finds up to 3 future execution dates based on the user-selected day/hour/minute in the reminderTimeZone.
    /// - For months where `zonedDay` exceeds days in month, calculation rolls down to last valid day.
    /// - Robust to DST (handles both non-existent and repeated times).
    /// - Always returns strictly increasing dates; searchBasis is advanced by one second each iteration.
    private func futureExecutionDates(reminderExecutionBasis: Date, reminderTimeZone: TimeZone) -> [Date] {
        var dates: [Date] = []
        var searchBasis = reminderExecutionBasis
        let calendar = Calendar.fromZone(reminderTimeZone)
        
        for _ in 0..<3 {
            var components = DateComponents()
            // Clamp the day to the last valid day of the month to avoid rollovers (e.g., "31" in April becomes April 30).
            let daysInMonth = calendar.range(of: .day, in: .month, for: searchBasis)?.count ?? zonedDay
            components.day = min(zonedDay, daysInMonth)
            components.hour = zonedHour
            components.minute = zonedMinute
            components.second = 0
            
            // Use .nextTimePreservingSmallerComponents for DST safety.
            guard let nextDate = calendar.nextDate(
                after: searchBasis,
                matching: components,
                matchingPolicy: .nextTimePreservingSmallerComponents
            ) else {
                break
            }
            dates.append(nextDate)
            // Advance search basis to avoid repeated/ambiguous times.
            searchBasis = nextDate.addingTimeInterval(1)
        }
        
        return dates
    }
    
    // MARK: - Request
    
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.monthlyZonedDay.rawValue] = .int(zonedDay)
        body[Constant.Key.monthlyZonedHour.rawValue] = .int(zonedHour)
        body[Constant.Key.monthlyZonedMinute.rawValue] = .int(zonedMinute)
        body[Constant.Key.monthlySkippedDate.rawValue] = .string(skippedDate?.ISO8601FormatWithFractionalSeconds())
        return body
    }
    
    // MARK: - Compare
    
    func isSame(as other: MonthlyComponents) -> Bool {
        zonedDay == other.zonedDay &&
        zonedHour == other.zonedHour &&
        zonedMinute == other.zonedMinute &&
        skippedDate == other.skippedDate
    }
}
