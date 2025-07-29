//
//  TriggerFixedTimeComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum TriggerFixedTimeType: String, CaseIterable {
    
    init?(rawValue: String) {
        for type in TriggerFixedTimeType.allCases where type.rawValue.lowercased() == rawValue.lowercased() {
            self = type
            return
        }
        
        self = .day
        return
    }
    
    case day
    case week
    case month
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .day:
            return .day
        case .week:
            return .weekOfYear
        case .month:
            return .month
        }
    }
}

final class TriggerFixedTimeComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TriggerFixedTimeComponents()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        
        copy.triggerFixedTimeType = self.triggerFixedTimeType
        copy.triggerFixedTimeTypeAmount = self.triggerFixedTimeTypeAmount
        copy.triggerFixedTimeHour = self.triggerFixedTimeHour
        copy.triggerFixedTimeMinute = self.triggerFixedTimeMinute
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let triggerFixedTimeType = TriggerFixedTimeType(rawValue: aDecoder.decodeOptionalString(forKey: Constant.Key.triggerFixedTimeType.rawValue) ?? Constant.Class.Trigger.defaultTriggerFixedTimeType.rawValue)
        let triggerFixedTimeTypeAmount = aDecoder.decodeOptionalInteger(forKey: Constant.Key.triggerFixedTimeTypeAmount.rawValue)
        let triggerFixedTimeHour = aDecoder.decodeOptionalInteger(forKey: Constant.Key.triggerFixedTimeHour.rawValue)
        let triggerFixedTimeMinute = aDecoder.decodeOptionalInteger(forKey: Constant.Key.triggerFixedTimeMinute.rawValue)
        
        self.init(
            triggerFixedTimeType: triggerFixedTimeType,
            triggerFixedTimeTypeAmount: triggerFixedTimeTypeAmount,
            triggerFixedTimeHour: triggerFixedTimeHour,
            triggerFixedTimeMinute: triggerFixedTimeMinute,
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(triggerFixedTimeType.rawValue, forKey: Constant.Key.triggerFixedTimeType.rawValue)
        aCoder.encode(triggerFixedTimeTypeAmount, forKey: Constant.Key.triggerFixedTimeTypeAmount.rawValue)
        aCoder.encode(triggerFixedTimeHour, forKey: Constant.Key.triggerFixedTimeHour.rawValue)
        aCoder.encode(triggerFixedTimeMinute, forKey: Constant.Key.triggerFixedTimeMinute.rawValue)
    }
    // MARK: - Properties
    
    /// triggerFixedTimeType isn't used currently. leave as its default of .day
    private(set) var triggerFixedTimeType: TriggerFixedTimeType = Constant.Class.Trigger.defaultTriggerFixedTimeType
    private(set) var triggerFixedTimeTypeAmount: Int = Constant.Class.Trigger.defaultTriggerFixedTimeTypeAmount
    func changeTriggerFixedTimeTypeAmount(_ newAmount: Int) -> Bool {
        guard newAmount >= 0 else { return false }
        triggerFixedTimeTypeAmount = newAmount
        return true
    }
    /// 0-23
    private(set) var triggerFixedTimeHour: Int = Constant.Class.Trigger.defaultTriggerFixedTimeHour
    func changeFixedTimeHour(_ newHour: Int) -> Bool {
        guard (0...23).contains(newHour) else { return false }
        triggerFixedTimeHour = newHour
        return true
    }
    /// 0-59
    private(set) var triggerFixedTimeMinute: Int = Constant.Class.Trigger.defaultTriggerFixedTimeMinute
    func changeFixedTimeMinute(_ newMinute: Int) -> Bool {
        guard (0...59).contains(newMinute) else { return false }
        triggerFixedTimeMinute = newMinute
        return true
    }
    
    // MARK: - Main
    
    init(
        triggerFixedTimeType: TriggerFixedTimeType? = nil,
        triggerFixedTimeTypeAmount: Int? = nil,
        triggerFixedTimeHour: Int? = nil,
        triggerFixedTimeMinute: Int? = nil,
    ) {
        super.init()
        self.triggerFixedTimeType = triggerFixedTimeType ?? self.triggerFixedTimeType
        self.triggerFixedTimeTypeAmount = triggerFixedTimeTypeAmount ?? self.triggerFixedTimeTypeAmount
        self.triggerFixedTimeHour = triggerFixedTimeHour ?? self.triggerFixedTimeHour
        self.triggerFixedTimeMinute = triggerFixedTimeMinute ?? self.triggerFixedTimeMinute
    }
    
    convenience init?(fromBody: JSONResponseBody, componentToOverride: TriggerFixedTimeComponents?) {
        
        let triggerFixedTimeType: TriggerFixedTimeType? = {
            guard let triggerFixedTimeTypeString = fromBody[Constant.Key.triggerFixedTimeType.rawValue] as? String else {
                return nil
            }
            return TriggerFixedTimeType(rawValue: triggerFixedTimeTypeString)
        }() ?? componentToOverride?.triggerFixedTimeType
        
        let triggerFixedTimeTypeAmount = fromBody[Constant.Key.triggerFixedTimeTypeAmount.rawValue] as? Int ?? componentToOverride?.triggerFixedTimeTypeAmount
        let triggerFixedTimeHour = fromBody[Constant.Key.triggerFixedTimeHour.rawValue] as? Int ?? componentToOverride?.triggerFixedTimeHour
        let triggerFixedTimeMinute = fromBody[Constant.Key.triggerFixedTimeMinute.rawValue] as? Int ?? componentToOverride?.triggerFixedTimeMinute
   
        self.init(
            triggerFixedTimeType: triggerFixedTimeType,
            triggerFixedTimeTypeAmount: triggerFixedTimeTypeAmount,
            triggerFixedTimeHour: triggerFixedTimeHour,
            triggerFixedTimeMinute: triggerFixedTimeMinute
        )
    }
    
    // MARK: - Functions
    
    func readableTime() -> String {
        var text = ""
        switch triggerFixedTimeTypeAmount {
        case 0: text += "same day"
        case 1: text += "next day"
        default: text += "\(triggerFixedTimeTypeAmount) days later"
        }
        text += " @ \(String.convert(hour: triggerFixedTimeHour, minute: triggerFixedTimeMinute))"
        return text
    }
    
    func nextReminderDate(afterDate date: Date, in inTimeZone: TimeZone = UserConfiguration.timeZone) -> Date? {
        let calendar = Calendar.fromZone(inTimeZone)

        // Compute the start of day in the user's current time zone so the
        // "day" component aligns with local expectations.
        let startOfDay = calendar.startOfDay(for: date)
        
        // Advance by the configured component (e.g., day, week, month)
        let advanced = calendar.date(byAdding: triggerFixedTimeType.calendarComponent,
                                     value: triggerFixedTimeTypeAmount,
                                     to: startOfDay) ?? Date()

        // Set the hour/minute in the provided TZ
        let executionDate = calendar.date(
            bySettingHour: triggerFixedTimeHour,
            minute: triggerFixedTimeMinute,
            second: 0,
            of: advanced,
            matchingPolicy: .nextTimePreservingSmallerComponents,
            repeatedTimePolicy: .first,
            direction: .forward
        )

        if let executionDate = executionDate, executionDate > date {
            return executionDate
        }
        
        // specified trigger has already happpened e.g. its 6:00pm and trigger is for 5:00PM today, so roll over to next day
        
        // Compute a fallback to the next day
        let nextDay = calendar.date(byAdding: .day, value: 1, to: advanced) ?? advanced
        let nextDayDate = calendar.date(
            bySettingHour: triggerFixedTimeHour,
            minute: triggerFixedTimeMinute,
            second: 0,
            of: nextDay,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        )

        return nextDayDate
    }
    
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.triggerFixedTimeType.rawValue] = .string(triggerFixedTimeType.rawValue)
        body[Constant.Key.triggerFixedTimeTypeAmount.rawValue] = .int(triggerFixedTimeTypeAmount)
        body[Constant.Key.triggerFixedTimeHour.rawValue] = .int(triggerFixedTimeHour)
        body[Constant.Key.triggerFixedTimeMinute.rawValue] = .int(triggerFixedTimeMinute)
        return body
    }
    
    // MARK: - Compare
    
    /// Returns true if all server-synced properties are identical to another trigger
    func isSame(as other: TriggerFixedTimeComponents) -> Bool {
        if triggerFixedTimeType != other.triggerFixedTimeType { return false }
        if triggerFixedTimeTypeAmount != other.triggerFixedTimeTypeAmount { return false }
        if triggerFixedTimeHour != other.triggerFixedTimeHour { return false }
        if triggerFixedTimeMinute != other.triggerFixedTimeMinute { return false }
        return true
    }
}
