//
//  IntExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/24/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension Int {
    /// Takes the given day of month and appends an appropiate suffix of st, nd, rd, or th, e.g. 31 returns st, 20 returns th, 2 returns nd
    func daySuffix() -> String {
        switch self {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
}
