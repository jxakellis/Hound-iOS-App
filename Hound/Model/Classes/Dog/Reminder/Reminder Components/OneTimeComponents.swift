//
//  OneTimeComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class OneTimeComponents: NSObject, NSCoding, NSCopying, ReminderComponent {

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = OneTimeComponents()
        copy.oneTimeDate = self.oneTimeDate
        return copy
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        oneTimeDate = aDecoder.decodeOptionalObject(forKey: KeyConstant.oneTimeDate.rawValue) ?? oneTimeDate
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeInteger, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(oneTimeDate, forKey: KeyConstant.oneTimeDate.rawValue)
    }

    // MARK: - Properties
    
    var readableRecurranceInterval: String {
        let dateYear = Calendar.current.component(.year, from: oneTimeDate)
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let dateFormatter = DateFormatter()
        // January 25 OR January 25, 2023
        dateFormatter.setLocalizedDateFormatFromTemplate(dateYear == currentYear ? "MMMMd" : "MMMMdyyyy")

        return dateFormatter.string(from: oneTimeDate)
    }
    
    var readableTimeOfDayInterval: String {
        let dateFormatter = DateFormatter()
        // 7:53 AM
        dateFormatter.setLocalizedDateFormatFromTemplate("hma")

        return dateFormatter.string(from: oneTimeDate)
    }
    
    var readableInterval: String {
        return readableRecurranceInterval.appending(" \(readableTimeOfDayInterval)")
    }

    /// The Date that the alarm should fire
    var oneTimeDate: Date = Date()

    // MARK: - Main

    override init() {
        super.init()
    }

    convenience init(date: Date) {
        self.init()
        self.oneTimeDate = date
    }

}
