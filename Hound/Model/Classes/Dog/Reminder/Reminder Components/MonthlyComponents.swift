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
    
    required init?(coder aDecoder: NSCoder) {
        zonedDay = aDecoder.decodeOptionalInteger(forKey: Constant.Key.monthlyZonedDay.rawValue) ?? zonedDay
        zonedHour = aDecoder.decodeOptionalInteger(forKey: Constant.Key.monthlyZonedHour.rawValue) ?? zonedHour
        zonedMinute = aDecoder.decodeOptionalInteger(forKey: Constant.Key.monthlyZonedMinute.rawValue) ?? zonedMinute
        skippedDate = aDecoder.decodeOptionalObject(forKey: Constant.Key.monthlySkippedDate.rawValue)
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
    
    /// 1-31
    private(set) var zonedDay: Int = Constant.Class.ReminderComponent.defaultZonedDay
    /// 0-23
    private(set) var zonedHour: Int = Constant.Class.ReminderComponent.defaultZonedHour
    /// 0-59
    private(set) var zonedMinute: Int = Constant.Class.ReminderComponent.defaultZonedMinute
    var isSkipping: Bool { skippedDate != nil }
    var skippedDate: Date?
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    convenience init(zonedDay: Int, zonedHour: Int, zonedMinute: Int, skippedDate: Date?) {
        self.init()
        self.zonedDay = zonedDay
        self.zonedHour = zonedHour
        self.zonedMinute = zonedMinute
        self.skippedDate = skippedDate
    }
    
    convenience init?(fromBody: JSONResponseBody, componentToOverride: MonthlyComponents?) {
        let zonedDay = fromBody[Constant.Key.monthlyZonedDay.rawValue] as? Int ?? componentToOverride?.zonedDay
        let zonedHour = fromBody[Constant.Key.monthlyZonedHour.rawValue] as? Int ?? componentToOverride?.zonedHour
        let zonedMinute = fromBody[Constant.Key.monthlyZonedMinute.rawValue] as? Int ?? componentToOverride?.zonedMinute
        let skippedDateString = fromBody[Constant.Key.monthlySkippedDate.rawValue] as? String
        let skippedDate = skippedDateString?.formatISO8601IntoDate() ?? componentToOverride?.skippedDate
        
        guard let day = zonedDay, let hour = zonedHour, let minute = zonedMinute else { return nil }
        
        self.init(zonedDay: day, zonedHour: hour, zonedMinute: minute, skippedDate: skippedDate)
    }
    
    // MARK: - Functions
    
    func readableRecurrence(from zonedTimeZone: TimeZone, to destinationTimeZone: TimeZone) -> String {
        let (hour, minute) = zonedTimeZone.convert(hour: zonedHour, minute: zonedMinute, to: destinationTimeZone)
        return "Every \(zonedDay)\(zonedDay.daySuffix()) at \(String.convert(hour: hour, minute: minute))"
    }
    
    // MARK: - Timing
    
    func nextExecutionDate(reminderExecutionBasis: Date, sourceTimeZone: TimeZone) -> Date {
        return isSkipping ? skippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, sourceTimeZone: sourceTimeZone)
        : notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, sourceTimeZone: sourceTimeZone)
    }
    
    func notSkippingExecutionDate(reminderExecutionBasis: Date, sourceTimeZone: TimeZone) -> Date {
        return futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis, sourceTimeZone: sourceTimeZone)
            .first(where: { $0 > reminderExecutionBasis }) ?? Constant.Class.Date.default1970Date
    }
    
    func previousExecutionDate(reminderExecutionBasis: Date, sourceTimeZone: TimeZone) -> Date {
            let calendar = Calendar(identifier: .gregorian)
            var components = calendar.dateComponents(in: sourceTimeZone, from: reminderExecutionBasis)
            components.day = zonedDay
            components.hour = zonedHour
            components.minute = zonedMinute
            components.second = 0

            guard let previousDate = calendar.nextDate(after: reminderExecutionBasis, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents, direction: .backward) else {
                return Constant.Class.Date.default1970Date
            }

            return previousDate
        }
    
    private func skippingExecutionDate(reminderExecutionBasis: Date, sourceTimeZone: TimeZone) -> Date {
        let nextExecution = notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis, sourceTimeZone: sourceTimeZone)
        let futureDates = futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis, sourceTimeZone: sourceTimeZone)
        return futureDates.first(where: { $0 > nextExecution }) ?? Constant.Class.Date.default1970Date
    }
    
    private func futureExecutionDates(reminderExecutionBasis: Date, sourceTimeZone: TimeZone) -> [Date] {
        var dates: [Date] = []
        var searchBasis = reminderExecutionBasis
        let calendar = Calendar(identifier: .gregorian)
        
        for _ in 0..<3 {
            var components = calendar.dateComponents(in: sourceTimeZone, from: searchBasis)
            let daysInMonth = calendar.range(of: .day, in: .month, for: searchBasis)?.count ?? zonedDay
            components.day = min(zonedDay, daysInMonth)
            components.hour = zonedHour
            components.minute = zonedMinute
            components.second = 0
            
            guard let nextDate = calendar.nextDate(after: searchBasis, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents) else { break }
            
            dates.append(nextDate)
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
        isSkipping == other.isSkipping &&
        skippedDate == other.skippedDate
    }
    
}
