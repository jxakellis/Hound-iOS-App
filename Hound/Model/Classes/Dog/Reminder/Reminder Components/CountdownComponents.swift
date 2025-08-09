//
//  countdownComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
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
    
    required convenience init?(coder aDecoder: NSCoder) {
        let executionInterval = aDecoder.decodeOptionalDouble(forKey: Constant.Key.countdownExecutionInterval.rawValue)
        self.init(executionInterval: executionInterval)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(executionInterval, forKey: Constant.Key.countdownExecutionInterval.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CountdownComponents else {
            return false
        }
        return executionInterval == other.executionInterval
    }
    
    // MARK: - Properties
    
    var readableTimeOfDay: String {
        return executionInterval.readable(capitalizeWords: true, abbreviationLevel: .long)
    }
    
    var readableRecurrance: String {
        return "Every \(readableTimeOfDay)"
    }
    
    /// Interval at which a countdown should be last for reminder
    var executionInterval: Double = Constant.Class.ReminderComponent.defaultCountdownExecutionInterval
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    init(executionInterval: Double? = nil) {
        super.init()
        self.executionInterval = executionInterval ?? self.executionInterval
    }
    
    convenience init(fromBody: JSONResponseBody, componentToOverride: CountdownComponents?) {
        let countdownExecutionInterval: Double? = fromBody[Constant.Key.countdownExecutionInterval.rawValue] as? Double ?? componentToOverride?.executionInterval
        
        self.init(executionInterval: countdownExecutionInterval)
    }

    // MARK: - Request
    
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.countdownExecutionInterval.rawValue] = .double(executionInterval)
        return body
    }
    
}
