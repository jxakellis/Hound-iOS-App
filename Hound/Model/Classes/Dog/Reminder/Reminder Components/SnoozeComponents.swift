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
    
    required convenience init?(coder aDecoder: NSCoder) {
        let executionInterval = aDecoder.decodeOptionalDouble(forKey: Constant.Key.snoozeExecutionInterval.rawValue)
        
        self.init(executionInterval: executionInterval)
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        if let executionInterval = executionInterval {
            aCoder.encode(executionInterval, forKey: Constant.Key.snoozeExecutionInterval.rawValue)
        }
    }
    
    // MARK: - Properties
    
    /// Interval at which a snooze should be last for reminder. If this value isn't nil, then the reminder is snoozing.
    var executionInterval: Double?
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    convenience init(executionInterval: Double? = nil) {
        self.init()
        
        self.executionInterval = executionInterval ?? self.executionInterval
    }
    
    convenience init(fromBody: JSONResponseBody, componentToOverride: SnoozeComponents?) {
        let snoozeExecutionInterval: Double? = fromBody[Constant.Key.snoozeExecutionInterval.rawValue] as? Double ?? componentToOverride?.executionInterval
        
        self.init(executionInterval: snoozeExecutionInterval)
    }
    
    // MARK: - Compare
    
    /// Returns true if all stored properties are equivalent
    func isSame(as other: SnoozeComponents) -> Bool {
        return executionInterval == other.executionInterval
    }
    
    // MARK: - Request
    
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.snoozeExecutionInterval.rawValue] = .double(executionInterval)
        return body
    }
    
}
