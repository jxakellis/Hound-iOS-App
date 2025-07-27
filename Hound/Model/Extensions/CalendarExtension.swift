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
    
    func withZone(_ timeZone: TimeZone) -> Calendar {
        var calendar = self
        calendar.timeZone = timeZone
        return calendar
    }
    
    static var utc: Calendar {
        return Calendar(identifier: .gregorian).withZone(TimeZone.utc)
    }
}
