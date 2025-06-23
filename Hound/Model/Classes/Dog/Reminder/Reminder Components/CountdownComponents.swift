//
//  countdownComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class CountdownComponents: NSObject, NSCoding, NSCopying, ReminderComponent {

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CountdownComponents()
        copy.executionInterval = executionInterval
        return copy
    }

    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        let decodedExecutionInterval: Double? = aDecoder.decodeOptionalDouble(forKey: KeyConstant.countdownExecutionInterval.rawValue)
        self.init(forExecutionInterval: decodedExecutionInterval)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(executionInterval, forKey: KeyConstant.countdownExecutionInterval.rawValue)
    }

    // MARK: - Properties

    var readableRecurranceInterval: String {
        return "Every"
    }
    
    var readableTimeOfDayInterval: String {
        return executionInterval.readable(capitalizeWords: true, abreviateWords: false)
    }
    
    var readableInterval: String {
        return readableRecurranceInterval.appending(" \(readableTimeOfDayInterval)")
    }

    /// Interval at which a countdown should be last for reminder
    var executionInterval: Double

    // MARK: - Main

    init(
        forExecutionInterval: Double? = nil
    ) {
        self.executionInterval = forExecutionInterval ?? ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
        super.init()
    }

}
