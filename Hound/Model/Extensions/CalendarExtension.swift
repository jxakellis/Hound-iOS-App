//
//  CalendarExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/23/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension Calendar {
    func range(of component: Calendar.Component, in larger: Calendar.Component, for date: Date, in timeZone: TimeZone) -> Range<Int>? {
        var calendar = self
        calendar.timeZone = timeZone
        return calendar.range(of: component, in: larger, for: date)
    }
    
    static var UTCCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)! // swiftlint:disable:this force_unwrapping
        return cal
    }
}
