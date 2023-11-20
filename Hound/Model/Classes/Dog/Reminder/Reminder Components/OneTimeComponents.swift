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

    // MARK: - Properties

    /// Converts to human friendly form, "January 25 at 7:53 AM"
    var displayableInterval: String {
        let dateYear = Calendar.current.component(.year, from: oneTimeDate)
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let dateFormatter = DateFormatter()
        // January 25 at 7:53 AM OR January 25, 2023 at 7:53 AM
        dateFormatter.setLocalizedDateFormatFromTemplate(dateYear == currentYear ? "MMMMdhma" : "MMMMdyyyyhma")

        return dateFormatter.string(from: oneTimeDate)
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
