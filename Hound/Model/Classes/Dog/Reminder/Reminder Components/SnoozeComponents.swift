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
        executionInterval = aDecoder.decodeDouble(forKey: KeyConstant.snoozeExecutionInterval.rawValue)
        
        if let executionInterval = executionInterval, executionInterval == 0.0 {
            self.executionInterval = nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT. If encoding something that requires needs to be decoded with a function other than decodeObject (e.g. decodeInteger, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        if let executionInterval = executionInterval {
            aCoder.encode(executionInterval, forKey: KeyConstant.snoozeExecutionInterval.rawValue)
        }
    }
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    convenience init(executionInterval: TimeInterval?) {
        self.init()
        
        self.executionInterval = executionInterval
    }
    
    // MARK: - Properties
    
    /// Interval at which a snooze should be last for reminder. If this value isn't nil, then the reminder is snoozing.
    var executionInterval: TimeInterval?
}
