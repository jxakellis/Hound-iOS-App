//
//  TestHelper.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation
@testable import Hound

final class TestHelper {
    static var utc: TimeZone {
        return TimeZone(identifier: "UTC")!
    }
    
    static var utcCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = utc
        return cal
    }
    
    static func calendar(_ timeZone: TimeZone) -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        return cal
    }
    
    static func date(_ string: String) -> Date {
        return string.formatISO8601IntoDate()!
    }
}
