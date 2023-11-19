//
//  TimeIntervalExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension TimeInterval {

    /**
     Converts a TimeInterval to a readable string.
        Examples:
        (1800.0, true, true): 30 Mins
        (1800.0, true, false): 30 Minutes
        (1800.0, false, true): 30 mins
        (1800.0, false, false): 30 minutes
        (5400.0, false, true) 1 hr 30 mins
     */
    func readable(capitalizeWords: Bool, abreviateWords: Bool) -> String {
        let totalSeconds = abs(Int(self.rounded()))

        let numberOfWeeks = Int((totalSeconds / (86400)) / 7)
        let numberOfDays = Int((totalSeconds / (86400)) % 7)
        let numberOfHours = Int((totalSeconds % (86400)) / (3600))
        let numberOfMinutes = Int((totalSeconds % 3600) / 60)
        let numberOfSeconds = Int((totalSeconds % 3600) % 60)
        
        var secondString = (abreviateWords ? "Sec" : "Second").appending(numberOfSeconds > 1 ? "s" : "")
        secondString = capitalizeWords ? secondString : secondString.lowercased()
        
        var minuteString = (abreviateWords ? "Min" : "Minute").appending(numberOfMinutes > 1 ? "s" : "")
        minuteString = capitalizeWords ? minuteString : minuteString.lowercased()
        
        var hourString = (abreviateWords ? "Hr" : "Hour").appending(numberOfHours > 1 ? "s" : "")
        hourString = capitalizeWords ? hourString : hourString.lowercased()
        
        var dayString = (abreviateWords ? "D" : "Day").appending(numberOfDays > 1 ? "s" : "")
        dayString = capitalizeWords ? dayString : dayString.lowercased()
        
        var weekString = (abreviateWords ? "Wk" : "Week").appending(numberOfWeeks > 1 ? "s" : "")
        weekString = capitalizeWords ? weekString : weekString.lowercased()
        
        var string = ""

        switch totalSeconds {
        case 0..<60:
            string.append("\(numberOfSeconds) \(secondString) ")
        case 60..<3600:
            string.append("\(numberOfMinutes) \(minuteString) ")
        case 3600..<86400:
            string.append("\(numberOfHours) \(hourString) ")
            if numberOfMinutes > 0 {
                string.append("\(numberOfMinutes) \(minuteString)) ")
            }
        case 86400..<604800:
            string.append("\(numberOfDays) \(dayString) ")
            if numberOfHours > 0 {
                string.append("\(numberOfHours) \(hourString) ")
            }
        default:
            string.append("\(numberOfWeeks) \(weekString) ")
            if numberOfDays > 0 {
                string.append("\(numberOfDays) \(dayString) ")
            }
        }

        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
