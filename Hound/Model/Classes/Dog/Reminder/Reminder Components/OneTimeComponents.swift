//
//  OneTimeComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class OneTimeComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = OneTimeComponents()
        copy.oneTimeDate = self.oneTimeDate
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        oneTimeDate = aDecoder.decodeObject(forKey: KeyConstant.oneTimeDate.rawValue) as? Date ?? oneTimeDate
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(oneTimeDate, forKey: KeyConstant.oneTimeDate.rawValue)
    }
    
    // MARK: - Main
    
    convenience init(date: Date) {
        self.init()
        self.oneTimeDate = date
    }
    
    // MARK: - Properties
    
    /// Converts to human friendly form, "January 25 at 7:53 AM"
    var displayableInterval: String {
        let dateFormatter = DateFormatter()
        
        let dateYear = Calendar.localCalendar.component(.year, from: oneTimeDate)
        let currentYear = Calendar.localCalendar.component(.year, from: Date())
        
        // January 25
        // January 25, 2023
        let dateTemplate = dateYear == currentYear ? "MMMM d" : "MMMM d, yyyy"
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: dateTemplate, options: 0, locale: Calendar.localCalendar.locale)
        var dateString = dateFormatter.string(from: oneTimeDate)
        
        // January 25 at
        // January 25, 2023 at
        dateString.append(" at ")
        
        // January 25 at 7:53 AM
        // January 25, 2023 at 7:53 AM
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.localCalendar.locale)
        dateString.append(dateFormatter.string(from: oneTimeDate))
        
        return dateString
    }
    
    /// The Date that the alarm should fire
    var oneTimeDate: Date = Date()
}
