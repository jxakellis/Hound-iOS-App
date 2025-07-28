//
//  StringExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension String {
    
    static func convert(hour: Int, minute: Int) -> String {
        // Build a date with the hour/minute (date is arbitrary, e.g., Jan 1, 2000)
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = hour
        components.minute = minute
        let calendar = Calendar.utc
        guard let date = calendar.date(from: components) else {
            return "\(hour):\(String(format: "%02d", minute))"
        }

        return date.formatted(date: .omitted, time: .shortened)
    }

    /// Only works if the label it is being used on has a single line of text OR has its paragraphs predefined with \n (s).
    func bounding(font: UIFont, height: CGFloat? = nil, width: CGFloat? = nil) -> CGSize {
        let attributedString = NSAttributedString(string: self, attributes: [.font: font])

        let greatestFiniteMagnitudeBounding = attributedString.boundingRect(with:
                                                                    CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        let boundHeight = height ?? greatestFiniteMagnitudeBounding.height
        let boundWidth = width ?? greatestFiniteMagnitudeBounding.width

        return CGSize(width: boundWidth, height: boundHeight)

    }

    /// Takes an ISO8601 string from the Hound server then attempts to create a Date
    func formatISO8601IntoDate() -> Date? {
        // from client
        // 2023-04-06T21:03:15Z
        // from server
        // 2023-04-12T20:40:00.000Z
        let formatterWithMilliseconds = Foundation.ISO8601DateFormatter()
        formatterWithMilliseconds.formatOptions = [.withFractionalSeconds, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFullDate, .withTime]

        let formatterWithoutMilliseconds = Foundation.ISO8601DateFormatter()
        formatterWithoutMilliseconds.formatOptions = [.withDashSeparatorInDate, .withColonSeparatorInTime, .withFullDate, .withTime]

        return formatterWithMilliseconds.date(from: self) ?? formatterWithoutMilliseconds.date(from: self)

    }

    /// If string contains a , or a ",  replaces all occurances of double-quotes with a pair of double quotes then encloses field in double quotes
    func formatIntoCSV() -> String {
        var string = self

        // The string only needs to be modified if it contains double-quotes or commas
        guard string.contains("\"") || string.contains(",") else {
            return string
        }

        // Literal double-quote characters in a CSV are typically represented by a pair of double-quotes.
        string = string.replacingOccurrences(of: "\"", with: "\"\"")

        // To encode a field containing a comma or double-quotes, we must enclose the field in double quotes.
        string = "\"" + string + "\""

        return string
    }
    
    func hasText() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}
