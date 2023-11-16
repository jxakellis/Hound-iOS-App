//
//  CalendarExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/23/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension Calendar {
    /// Calendar object with it's time zone set to GMT+0000
    static var UTCCalendar: Calendar {
        var UTCCalendar = Calendar.current
        UTCCalendar.timeZone = TimeZone(secondsFromGMT: 0) ?? UTCCalendar.timeZone
        return UTCCalendar
    }
}
