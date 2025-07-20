//
//  MonthlyComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class MonthlyComponents: NSObject, NSCoding, NSCopying, ReminderComponent {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MonthlyComponents()
        copy.UTCDay = self.UTCDay
        copy.UTCHour = self.UTCHour
        copy.UTCMinute = self.UTCMinute
        copy.skippedDate = self.skippedDate
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        UTCDay = aDecoder.decodeOptionalInteger(forKey: Constant.Key.monthlyUTCDay.rawValue) ?? UTCDay
        UTCHour = aDecoder.decodeOptionalInteger(forKey: Constant.Key.monthlyUTCHour.rawValue) ?? UTCHour
        UTCMinute = aDecoder.decodeOptionalInteger(forKey: Constant.Key.monthlyUTCMinute.rawValue) ?? UTCMinute
        skippedDate = aDecoder.decodeOptionalObject(forKey: Constant.Key.monthlySkippedDate.rawValue)
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        aCoder.encode(UTCDay, forKey: Constant.Key.monthlyUTCDay.rawValue)
        aCoder.encode(UTCHour, forKey: Constant.Key.monthlyUTCHour.rawValue)
        aCoder.encode(UTCMinute, forKey: Constant.Key.monthlyUTCMinute.rawValue)
        if let skippedDate = skippedDate {
            aCoder.encode(skippedDate, forKey: Constant.Key.monthlySkippedDate.rawValue)
        }
    }
    
    // MARK: - Properties
    
    var readableRecurranceInterval: String {
        return "Every \(UTCDay)\(UTCDay.daySuffix())"
    }
    
    var readableTimeOfDayInterval: String {
        return String.convertToReadable(fromUTCHour: UTCHour, fromUTCMinute: UTCMinute)
    }
    
    var readableInterval: String {
        return readableRecurranceInterval.appending(" \(readableTimeOfDayInterval)")
    }
    
    /// Hour of the day that that the reminder should fire in GMT+0000. [1, 31]
    private(set) var UTCDay: Int = Constant.Class.ReminderComponent.defaultUTCDay
    /// Throws if not within the range of [1,31]
    func changeUTCDay(forDate: Date) {
        UTCDay = Calendar.UTCCalendar.component(.day, from: forDate)
    }
    
    /// Hour of the day that that the reminder should fire in GMT+0000. [0, 23]
    private(set) var UTCHour: Int = Constant.Class.ReminderComponent.defaultUTCHour
    /// UTCHour but converted to the hour in the user's timezone
    var localHour: Int {
        let hoursFromUTC = TimeZone.current.secondsFromGMT() / 3600
        var localHour = UTCHour + hoursFromUTC
        // localHour could be negative, so roll over into positive
        localHour += 24
        // Make sure localHour [0, 23]
        localHour = localHour % 24
        return localHour
    }
    /// Takes a given date and extracts the UTC Hour (GMT+0000) from it.
    func changeUTCHour(forDate: Date) {
        UTCHour = Calendar.UTCCalendar.component(.hour, from: forDate)
    }
    
    /// Minute of the day that that the reminder should fire in GMT+0000. [0, 59]
    private(set) var UTCMinute: Int = Constant.Class.ReminderComponent.defaultUTCMinute
    /// UTCMinute but converted to the minute in the user's timezone
    var localMinute: Int {
        let minutesFromUTC = (TimeZone.current.secondsFromGMT() % 3600) / 60
        var localMinute = UTCMinute + minutesFromUTC
        // localMinute could be negative, so roll over into positive
        localMinute += 60
        // Make sure localMinute [0, 59]
        localMinute = localMinute % 60
        return localMinute
    }
    /// Takes a given date and extracts the UTC minute (GMT+0000) from it.
    func changeUTCMinute(forDate: Date) {
        UTCMinute = Calendar.UTCCalendar.component(.minute, from: forDate)
    }
    
    /// Whether or not the next alarm will be skipped
    var isSkipping: Bool {
        skippedDate != nil
    }
    
    /// The date at which the user changed the isSkipping to true.  If is skipping is true, then a certain log date was appended. If unskipped, then we have to remove that previously added log. Slight caveat: if the skip log was modified (by the user changing its date) we don't remove it.
    var skippedDate: Date?
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    convenience init(UTCDay: Int, UTCHour: Int, UTCMinute: Int, skippedDate: Date?) {
        self.init()
        self.UTCDay = UTCDay
        self.UTCHour = UTCHour
        self.UTCMinute = UTCMinute
        self.skippedDate = skippedDate
        
    }
    
    // MARK: - Functions
    
    /// This find the next execution date that takes place after the reminderExecutionBasis. It purposelly not factoring in isSkipping.
    func notSkippingExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {
        // there will only be two future executions dates for a day, so we take the first one is the one.
        return futureExecutionDates(forReminderExecutionBasis: reminderExecutionBasis).first ?? Constant.Class.Date.default1970Date
    }
    
    func previousExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {
        let nextExecutionDate = notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
        
        return fallShortCorrection(forDate:
                                    Calendar.UTCCalendar.date(byAdding: .month, value: -1, to: nextExecutionDate) ?? Constant.Class.Date.default1970Date
        )
    }
    
    /// Factors in isSkipping to figure out the next time of day
    func nextExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {
        isSkipping ? skippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis) : notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
    }
    
    // MARK: - Private Helper Functions
    
    //// If we add a month to the date, then it might be incorrect and lose accuracy. For example, our day is 31. We are in April so there is only 30 days. Therefore we get a calculated date of April 30th. After adding a month, the result date is May 30th, but it should be 31st because of our day and that May has 31 days. This corrects that.
    private func fallShortCorrection(forDate date: Date) -> Date {
        
        guard UTCDay > Calendar.UTCCalendar.component(.day, from: date) else {
            // when adding a month, the day did not fall short of what was needed
            return date
        }
        
        // when adding a month to the date, the day of month needed fell short of the intented day of month
        
        // We need to find the maximum possible day to set the date to without having it accidentially roll into the next month.
        let targetDayOfMonth: Int = {
            let neededDay = UTCDay
            guard let maximumDay = Calendar.UTCCalendar.range(of: .day, in: .month, for: date)?.count else {
                return neededDay
            }
            
            return neededDay <= maximumDay ? neededDay : maximumDay
        }()
        
        // We have the correct day to set the date to, now we can change it.
        return Calendar.UTCCalendar.date(bySetting: .day, value: targetDayOfMonth, of: date) ?? Constant.Class.Date.default1970Date
        
    }
    
    /// Produces an array of at least two with all of the future dates that the reminder will fire given the day of month, hour, and minute
    private func futureExecutionDates(forReminderExecutionBasis reminderExecutionBasis: Date) -> [Date] {
        
        var futureExecutionDate = reminderExecutionBasis
        
        // finds number of days in the calculated date's month, used for roll over calculations
        guard let numberOfDaysInMonth = Calendar.UTCCalendar.range(of: .day, in: .month, for: futureExecutionDate)?.count else {
            return [Constant.Class.Date.default1970Date, Constant.Class.Date.default1970Date]
        }
        
        // We want to make sure that the day of month we are using isn't greater that the number of days in the target month. If it is, then we could accidentily roll over into the next month. For example, without this functionality, setting the day of Feburary to 31 would cause the date to roll into the next month. But, targetDayOfMonth limits the set to 28/29
        
        let targetDayOfMonth: Int = UTCDay <= numberOfDaysInMonth ? UTCDay : numberOfDaysInMonth
        
        // Set futureExecutionDate to the proper day of month
        futureExecutionDate = Calendar.UTCCalendar.date(bySetting: .day, value: targetDayOfMonth, of: futureExecutionDate) ?? Constant.Class.Date.default1970Date
        
        // Set futureExecutionDate to the proper day of week
        futureExecutionDate = Calendar.UTCCalendar.date(bySettingHour: UTCHour, minute: UTCMinute, second: 0, of: futureExecutionDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) ?? Constant.Class.Date.default1970Date
        
        // We are looking for future dates, not past. Correct dates in past to make them in the future
        
        if reminderExecutionBasis.distance(to: futureExecutionDate) < 0 {
            // Correct for falling short when we add a month
            futureExecutionDate = fallShortCorrection(forDate: Calendar.UTCCalendar.date(byAdding: .month, value: 1, to: futureExecutionDate) ?? Constant.Class.Date.default1970Date)
        }
        var futureExecutionDates = [futureExecutionDate]
        
        // futureExecutionDates should have at least two dates
        futureExecutionDates.append(
            fallShortCorrection(forDate:
                                    Calendar.UTCCalendar.date(byAdding: .month, value: 1, to: futureExecutionDate) ?? Constant.Class.Date.default1970Date
                               )
        )
        
        futureExecutionDates.sort()
        
        return futureExecutionDates
    }
    
    /// If a reminder is skipping, then we must find the next soonest reminderExecutionDate. We have to find the execution date that takes place after the skipped execution date (but before any other execution date).
    private func skippingExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {
        
        let nextExecutionDate = notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
        
        let futureExecutionDates = futureExecutionDates(forReminderExecutionBasis: reminderExecutionBasis)
        var soonestFutureExecutionDate: Date = futureExecutionDates.first(where: { futureExecutionDate in
            nextExecutionDate.distance(to: futureExecutionDate) > 0
        }) ?? Constant.Class.Date.default1970Date
        
        // Attempt to find futureExecutionDates that are further in the future than nextExecutionDate while being closer to nextExecutionDate than soonestFutureExecutionDate
        for futureExecutionDate in futureExecutionDates where
        nextExecutionDate.distance(to: futureExecutionDate) > 0
        && nextExecutionDate.distance(to: futureExecutionDate) < nextExecutionDate.distance(to: soonestFutureExecutionDate) {
            soonestFutureExecutionDate = futureExecutionDate
        }
        
        return soonestFutureExecutionDate
    }
    
    // MARK: - Compare
    
    /// Returns true if all stored properties are equivalent
    func isSame(as other: MonthlyComponents) -> Bool {
        if UTCDay != other.UTCDay { return false }
        if UTCHour != other.UTCHour { return false }
        if UTCMinute != other.UTCMinute { return false }
        if isSkipping != other.isSkipping { return false }
        if skippedDate != other.skippedDate { return false }
        return true
    }
    
}
