//
//  countdownComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class CountdownComponents: NSObject, NSCoding, NSCopying {
    
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
        aCoder.encode(executionInterval, forKey: KeyConstant.countdownExecutionInterval.rawValue)
    }
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    convenience init(executionInterval: TimeInterval) {
        self.init()
        self.executionInterval = executionInterval
    }
    
    /// Interval at which a countdown should be last for reminder
    var executionInterval: TimeInterval = ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
    
}
