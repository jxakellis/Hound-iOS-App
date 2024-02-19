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

    required init?(coder aDecoder: NSCoder) {
        executionInterval = aDecoder.decodeDouble(forKey: KeyConstant.countdownExecutionInterval.rawValue)

        if executionInterval == 0.0 {
            executionInterval = ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
        }
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeInteger, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
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
    var executionInterval: Double = ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval

    // MARK: - Main

    override init() {
        super.init()
    }

    convenience init(executionInterval: Double) {
        self.init()
        self.executionInterval = executionInterval
    }

}
