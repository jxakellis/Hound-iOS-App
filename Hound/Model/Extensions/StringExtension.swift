//
//  StringExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension String {

    /// Converts dateComponents with .hour and .minute to a readable string, e.g. 8:56AM or 2:23 PM
    static func convertToReadable(fromUTCHour UTCHour: Int, fromUTCMinute UTCMinute: Int) -> String {

        var localHour: Int = {
            let hoursFromUTC = Int(TimeZone.current.secondsFromGMT() / 3600)
            var localHour = UTCHour + hoursFromUTC
            // Verify localHour >= 0
            if localHour < 0 {
                localHour += 24
            }

            // Verify localHour <= 23
            if localHour > 23 {
                localHour = localHour % 24
            }

            return localHour
        }()

        let localMinute: Int = {
            let minutesFromUTC = Int((TimeZone.current.secondsFromGMT() % 3600) / 60 )
            var localMinute = UTCMinute + minutesFromUTC
            // Verify localMinute >= 0
            if localMinute < 0 {
                localMinute += 60
            }

            // Verify localMinute <= 59
            if localMinute > 59 {
                localMinute = localMinute % 60
            }

            return localMinute
        }()

        let amOrPM: String = localHour < 12 ? "AM" : "PM"

        // convert localHour to non-military time
        if localHour > 12 {
            localHour -= 12
        }
        else if localHour == 0 {
            localHour = 12
        }

        // 7:00 PM, 7:10 AM
        return "\(localHour):\(localMinute < 10 ? "0" : "")\(localMinute) \(amOrPM)"
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
