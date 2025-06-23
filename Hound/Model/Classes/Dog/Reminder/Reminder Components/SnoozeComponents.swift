//
//  SnoozeComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class SnoozeComponents: NSObject, NSCoding, NSCopying {

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SnoozeComponents()
        copy.executionInterval = executionInterval
        return copy
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        executionInterval = aDecoder.decodeOptionalDouble(forKey: KeyConstant.snoozeExecutionInterval.rawValue)
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        if let executionInterval = executionInterval {
            aCoder.encode(executionInterval, forKey: KeyConstant.snoozeExecutionInterval.rawValue)
        }
    }

    // MARK: - Properties

    /// Interval at which a snooze should be last for reminder. If this value isn't nil, then the reminder is snoozing.
    var executionInterval: Double?

    // MARK: - Main

    override init() {
        super.init()
    }

    convenience init(executionInterval: Double?) {
        self.init()

        self.executionInterval = executionInterval
    }

}
