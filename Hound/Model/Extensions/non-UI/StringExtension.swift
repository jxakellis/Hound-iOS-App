//
//  StringExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension String {
    
    /// Converts a time interval to a more readable string to display. E.g. (1800.0, true) to 30 Minutes or (7320.0, false) to 2 hours 2 minutes. Capital letters dictates whether or not the labels are capitalized (minute vs Minute)
    static func convertToReadable(fromTimeInterval timeInterval: TimeInterval, capitalizeLetters: Bool = true) -> String {
        let intTime = abs(Int(timeInterval.rounded()))
        
        let numWeeks = Int((intTime / (86400)) / 7)
        let numDays = Int((intTime / (86400)) % 7)
        let numHours = Int((intTime % (86400)) / (3600))
        let numMinutes = Int((intTime % 3600) / 60)
        let numSeconds = Int((intTime % 3600) % 60)
        
        var readableString = ""
        
        switch intTime {
        case 0..<60:
            readableString.append("\(numSeconds) Second\(numSeconds > 1 ? "s" : "") ")
        case 60..<3600:
            readableString.append("\(numMinutes) Minute\(numMinutes > 1 ? "s" : "") ")
        case 3600..<86400:
            readableString.append("\(numHours) Hour\(numHours > 1 ? "s" : "") ")
            if numMinutes > 0 {
                readableString.append("\(numMinutes) Minute\(numMinutes > 1 ? "s" : "") ")
            }
        case 86400..<604800:
            readableString.append("\(numDays) Day\(numDays > 1 ? "s" : "") ")
            if numHours > 0 {
                readableString.append("\(numHours) Hour\(numHours > 1 ? "s" : "") ")
            }
        default:
            readableString.append("\(numWeeks) Week\(numWeeks > 1 ? "s" : "") ")
            if numDays > 0 {
                readableString.append("\(numDays) Day\(numDays > 1 ? "s" : "") ")
            }
        }
        
        if readableString.last == " "{
            readableString.removeLast()
        }
        
        if capitalizeLetters == false {
            return readableString.lowercased()
        }
        else {
            return readableString
        }
    }
    
    /// Converts dateComponents with .hour and .minute to a readable string, e.g. 8:56AM or 2:23 PM
    static func convertToReadable(fromUTCHour UTCHour: Int, fromUTCMinute UTCMinute: Int) -> String {
        
        var localHour: Int = {
            let hoursFromUTC = Int(Calendar.localCalendar.timeZone.secondsFromGMT() / 3600)
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
            let minutesFromUTC = Int((Calendar.localCalendar.timeZone.secondsFromGMT() % 3600) / 60 )
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
        
        let amOrPM: String = {
            if localHour < 12 {
                return "AM"
            }
            else {
                return "PM"
            }
        }()
        
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
    
    /// Converts a date into a readable string. The year is only added if its different from the current. e.g. 8:58 PM March 7, 2023
    static func convertToReadable(fromDate date: Date) -> String {
        
        var dateString = ""
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.localCalendar.locale)
        dateString = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM d", options: 0, locale: Calendar.localCalendar.locale)
        dateString.append(" \(dateFormatter.string(from: date))")
        
        let day = Calendar.localCalendar.component(.day, from: date)
        dateString.append(day.daySuffix())
        
        let year = Calendar.localCalendar.component(.year, from: date)
        if year != Calendar.localCalendar.component(.year, from: Date()) {
            dateString.append(", \(year)")
        }
        
        return dateString
    }
    
    /// Adds given text with given font to the start of the string, converts whole thing to NSAttributedString
    func addingFontToBeginning(text: String, font customFont: UIFont) -> NSAttributedString {
        let originalString = NSMutableAttributedString(string: self)
        
        let customFontAttribute = [NSAttributedString.Key.font: customFont]
        let customAttributedString = NSMutableAttributedString(string: text, attributes: customFontAttribute)
        
        customAttributedString.append(originalString)
        
        return customAttributedString
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
        
        return formatterWithMilliseconds.date(from: self) ?? formatterWithoutMilliseconds.date(from: self) ?? nil
        
    }
}
