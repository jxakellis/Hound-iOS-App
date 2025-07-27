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
    static let utc = TimeZone(identifier: "UTC")!
    static let utcCalendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = utc
        return cal
    }()
    
    static func date(_ string: String) -> Date {
        return string.formatISO8601IntoDate()!
    }
}
