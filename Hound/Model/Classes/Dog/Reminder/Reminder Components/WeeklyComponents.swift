//
//  WeeklyComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class WeeklyComponents: NSObject, NSCoding, NSCopying, ReminderComponent {

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = WeeklyComponents()
        copy.weekdays = self.weekdays
        copy.UTCHour = self.UTCHour
        copy.UTCMinute = self.UTCMinute
        copy.skippedDate = self.skippedDate

        return copy
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        weekdays = aDecoder.decodeOptionalObject(forKey: KeyConstant.weeklyWeekdays.rawValue) ?? weekdays
        UTCHour = aDecoder.decodeOptionalInteger(forKey: KeyConstant.weeklyUTCHour.rawValue) ?? UTCHour
        UTCMinute = aDecoder.decodeOptionalInteger(forKey: KeyConstant.weeklyUTCMinute.rawValue) ?? UTCMinute
        skippedDate = aDecoder.decodeOptionalObject(forKey: KeyConstant.weeklySkippedDate.rawValue)
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(weekdays, forKey: KeyConstant.weeklyWeekdays.rawValue)
        aCoder.encode(UTCHour, forKey: KeyConstant.weeklyUTCHour.rawValue)
        aCoder.encode(UTCMinute, forKey: KeyConstant.weeklyUTCMinute.rawValue)
        aCoder.encode(skippedDate, forKey: KeyConstant.weeklySkippedDate.rawValue)
    }

    // MARK: - Properties
    
    var readableRecurranceInterval: String {
        switch weekdays {
        case [1, 2, 3, 4, 5, 6, 7]:
            return "Everyday"
        case [1, 7]:
            return "Weekends"
        case [2, 3, 4, 5, 6]:
            return "Weekdays"
        default:
            var string = ""
            
            let shouldAbreviateWeekday = weekdays.count > 1
            for weekdayInt in weekdays {
                switch weekdayInt {
                case 1:
                    string.append(shouldAbreviateWeekday ? "Su, " : "Sunday ")
                case 2:
                    string.append(shouldAbreviateWeekday ? "M, " : "Monday ")
                case 3:
                    string.append(shouldAbreviateWeekday ? "Tu, " : "Tuesday ")
                case 4:
                    string.append(shouldAbreviateWeekday ? "W, " : "Wednesday ")
                case 5:
                    string.append(shouldAbreviateWeekday ? "Th, " : "Thursday ")
                case 6:
                    string.append(shouldAbreviateWeekday ? "F, " : "Friday ")
                case 7:
                    string.append(shouldAbreviateWeekday ? "Sa, " : "Saturday ")
                default:
                    continue
                }
            }

            // Check for case of "Su, M, Tu, " to correct to "Su, M, Tu ", replacing last occurance of ", " with " "
            let lastTwoCharactersIndex = string.index(string.endIndex, offsetBy: -2)
            let lastTwoCharacters = String(string[lastTwoCharactersIndex...])
            if lastTwoCharacters == ", " {
                string.removeLast()
                string.removeLast()
            }
            
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    var readableTimeOfDayInterval: String {
        return String.convertToReadable(fromUTCHour: UTCHour, fromUTCMinute: UTCMinute)
    }
    
    var readableInterval: String {
        return readableRecurranceInterval.appending(" at \(readableTimeOfDayInterval)")
    }

    /// The weekdays on which the reminder should fire. 1 - 7, where 1 is sunday and 7 is saturday.
    private(set) var weekdays: [Int] = [1, 2, 3, 4, 5, 6, 7]
    /// Changes the weekdays, if empty throws an error due to the fact that there needs to be at least one time of week.
    func changeWeekdays(forWeekdays: [Int]) throws {
        let acceptableWeekdays = [1, 2, 3, 4, 5, 6, 7]
        // remove duplicates from forWeekdays
        // remove weekdays that aren't valid from weekdays
        // sort weekdays

        let filteredWeekdays = Array(Set(forWeekdays)).filter({ forWeekday in
            acceptableWeekdays.contains(forWeekday)
        }).sorted()

        if filteredWeekdays.isEmpty {
            throw ErrorConstant.WeeklyComponentsError.weekdayArrayInvalid()
        }

        weekdays = filteredWeekdays
    }

    /// Hour of the day that that the reminder should fire in GMT+0000. [0, 23]
    private(set) var UTCHour: Int = ClassConstant.ReminderComponentConstant.defaultUTCHour
    /// UTCHour but converted to the hour in the user's timezone
    var localHour: Int {
        let hoursFromUTC = Calendar.current.timeZone.secondsFromGMT() / 3600

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
    private(set) var UTCMinute: Int = ClassConstant.ReminderComponentConstant.defaultUTCMinute
    /// UTCMinute but converted to the minute in the user's timezone
    var localMinute: Int {
        let minutesFromUTC = (Calendar.current.timeZone.secondsFromGMT() % 3600) / 60
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

    convenience init(UTCHour: Int, UTCMinute: Int, skippedDate: Date?, sunday: Bool, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool) {
        self.init()
        self.UTCHour = UTCHour
        self.UTCMinute = UTCMinute
        self.skippedDate = skippedDate

        weekdays = []
        if sunday == true {
            weekdays.append(1)
        }
        if monday == true {
            weekdays.append(2)
        }
        if tuesday == true {
            weekdays.append(3)
        }
        if wednesday == true {
            weekdays.append(4)
        }
        if thursday == true {
            weekdays.append(5)
        }
        if friday == true {
            weekdays.append(6)
        }
        if saturday == true {
            weekdays.append(7)
        }

        if weekdays.isEmpty {
            weekdays = [1, 2, 3, 4, 5, 6, 7]
        }
    }

    // MARK: - Functions

    /// This find the next execution date that takes place after the reminderExecutionBasis. It purposelly not factoring in isSkipping.
    func notSkippingExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {

        let futureExecutionDates = futureExecutionDates(forReminderExecutionBasis: reminderExecutionBasis)

        // Default to the first item in the array, as it is most likely the closest to the present
        var soonestFutureExecutionDate: Date = futureExecutionDates.first ?? ClassConstant.DateConstant.default1970Date

        // Find any dates that are closer to the present that the current soonestFutureExecutionDate. If a date is closer to the present that soonestFutureExecutionDate, set soonestFutureExecutionDate to its value
        for futureExecutionDate in futureExecutionDates where reminderExecutionBasis.distance(to: futureExecutionDate) < reminderExecutionBasis.distance(to: soonestFutureExecutionDate) {
            soonestFutureExecutionDate = futureExecutionDate
        }

        return soonestFutureExecutionDate
    }

    /// Returns the date that the reminder should have last sounded an alarm at. This helps in finding alarms that might have been missed
    func previousExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {

        let nextExecutionDate = notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)

        guard weekdays.count > 1 else {
            // only 1 day of week so simply subtract a week
            return Calendar.UTCCalendar.date(byAdding: .day, value: -7, to: nextExecutionDate) ?? ClassConstant.DateConstant.default1970Date
        }

        let futureExecutionDates = futureExecutionDates(forReminderExecutionBasis: reminderExecutionBasis)

        var pastExecutionDates: [Date] = []

        // Take every date and shift it back a week
        for futureExecutionDate in futureExecutionDates {
            pastExecutionDates.append(Calendar.UTCCalendar.date(byAdding: .day, value: -7, to: futureExecutionDate) ?? ClassConstant.DateConstant.default1970Date)
        }

        // Choose date that is likely to be the closest to the present
        var soonestExecutionDate: Date = pastExecutionDates.first ?? ClassConstant.DateConstant.default1970Date

        // Find date that are before the nextExecutionDate while also being closer to nextExecutionDate that soonestExecutionDate
        for pastExecutionDate in pastExecutionDates where
        nextExecutionDate.distance(to: pastExecutionDate) < 0
        && nextExecutionDate.distance(to: pastExecutionDate) > nextExecutionDate.distance(to: soonestExecutionDate) {
            // pastExecutionDate comes before nextExecutionDate while being closer to nextExecutionDate than soonestExecutionDate
            soonestExecutionDate = pastExecutionDate
        }

        return soonestExecutionDate
    }

    /// Factors in isSkipping to figure out the next time of day
    func nextExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {
        isSkipping ? skippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis) : notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
    }

    // MARK: - Private Helper Functions

    /// Produces an array of at least two with all of the future dates that the reminder will fire given the weekday(s), hour, and minute
    private func futureExecutionDates(forReminderExecutionBasis reminderExecutionBasis: Date) -> [Date] {

        // the dates calculated to be reminderExecutionDates
        var futureExecutionDates: [Date] = {
            var futureExecutionDates: [Date] = []

            // iterate throguh all weekdays
            for weekday in weekdays {
                // Add the target weekday to reminderExecutionBasis
                var futureExecutionDate = Calendar.UTCCalendar.date(bySetting: .weekday, value: weekday, of: reminderExecutionBasis) ?? ClassConstant.DateConstant.default1970Date

                // Iterate the futureExecutionDate forward until the first result that matches UTCHour and UTCMinute is found
                futureExecutionDate = Calendar.UTCCalendar.date(bySettingHour: UTCHour, minute: UTCMinute, second: 0, of: futureExecutionDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) ?? ClassConstant.DateConstant.default1970Date

                // Make sure futureExecutionDate is after reminderExecutionBasis
                // Correction for setting components to the same day. e.g. if its 11:00Am friday and you apply 8:30AM Friday to the current date, then it is in the past, this gets around this by making it 8:30AM Next Friday
                if reminderExecutionBasis.distance(to: futureExecutionDate) < 0 {
                    futureExecutionDate = Calendar.UTCCalendar.date(byAdding: .day, value: 7, to: futureExecutionDate) ?? ClassConstant.DateConstant.default1970Date
                }

                futureExecutionDates.append(futureExecutionDate)
            }
            return futureExecutionDates
        }()

        // futureExecutionDates should have at least two dates
        if futureExecutionDates.count <= 1 {
            if let futureExecutionDate = futureExecutionDates.first {
                // Only one weekday is active. Take the execution date for that single weekday and add a duplicate, but a week in the future
                futureExecutionDates.append(Calendar.UTCCalendar.date(byAdding: .day, value: 7, to: futureExecutionDate) ?? ClassConstant.DateConstant.default1970Date)
            }
            else {
                // No weekdays active. Shouldn't happen. Handle by adding 1 week and 2 weeks to reminderExecutionBasis
                futureExecutionDates.append(Calendar.UTCCalendar.date(byAdding: .day, value: 7, to: reminderExecutionBasis) ?? ClassConstant.DateConstant.default1970Date)
                futureExecutionDates.append(Calendar.UTCCalendar.date(byAdding: .day, value: 14, to: reminderExecutionBasis) ?? ClassConstant.DateConstant.default1970Date)
            }
        }

        futureExecutionDates.sort()

        return futureExecutionDates
    }

    /// If a reminder is skipping, then we must find the next soonest reminderExecutionDate. We have to find the execution date that takes place after the skipped execution date (but before any other execution date).
    private func skippingExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {

        let nextExecutionDate = notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)

        guard weekdays.count > 1 else {
            // If only 1 day of week selected so simply add 1 week.
            return Calendar.UTCCalendar.date(byAdding: .day, value: 7, to: nextExecutionDate) ?? ClassConstant.DateConstant.default1970Date
        }

        // If there are multiple dates to be sorted through to find the date that is closer in time to traditionalNextTimeOfDay but still in the future
        let futureExecutionDates = futureExecutionDates(forReminderExecutionBasis: reminderExecutionBasis)

        // Find the futureExecutionDate that is after nextExecutionDate
        var soonestFutureExecutionDate: Date = futureExecutionDates.first(where: { futureExecutionDate in
            nextExecutionDate.distance(to: futureExecutionDate) > 0
        }) ?? ClassConstant.DateConstant.default1970Date

        // Attempt to find futureExecutionDates that are further in the future than nextExecutionDate while being closer to nextExecutionDate than soonestFutureExecutionDate. Doing this will give us the first executionDate that is directly after nextExecutionDate
        for futureExecutionDate in futureExecutionDates where
        nextExecutionDate.distance(to: futureExecutionDate) > 0
        && nextExecutionDate.distance(to: futureExecutionDate) < nextExecutionDate.distance(to: soonestFutureExecutionDate) {
            soonestFutureExecutionDate = futureExecutionDate
        }

        return soonestFutureExecutionDate
    }
}
