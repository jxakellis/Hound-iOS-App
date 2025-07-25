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
        let decodedExecutionInterval: Double? = aDecoder.decodeOptionalDouble(forKey: Constant.Key.countdownExecutionInterval.rawValue)
        self.init(forExecutionInterval: decodedExecutionInterval)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(executionInterval, forKey: Constant.Key.countdownExecutionInterval.rawValue)
    }
    
    // MARK: - Properties
    
    var readableTimeOfDay: String {
        return executionInterval.readable(capitalizeWords: true, abreviateWords: false)
    }
    
    var readableRecurrance: String {
        return "Every \(readableTimeOfDay)"
    }
    
    /// Interval at which a countdown should be last for reminder
    var executionInterval: Double
    
    // MARK: - Main
    
    init(
        forExecutionInterval: Double? = nil
    ) {
        self.executionInterval = forExecutionInterval ?? Constant.Class.ReminderComponent.defaultCountdownExecutionInterval
        super.init()
    }
    
    convenience init?(fromBody: JSONResponseBody, componentToOverride: CountdownComponents?) {
        let executionInterval: Double? = fromBody[Constant.Key.countdownExecutionInterval.rawValue] as? Double ?? componentToOverride?.executionInterval
        guard let executionInterval = executionInterval else {
            return nil
        }
        self.init(forExecutionInterval: executionInterval)
    }
    
    // MARK: - Compare
    
    /// Returns true if all stored properties are equivalent
    func isSame(as other: CountdownComponents) -> Bool {
        return executionInterval == other.executionInterval
    }
    
    // MARK: - Request
    
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.countdownExecutionInterval.rawValue] = .double(executionInterval)
        return body
    }
    
}
