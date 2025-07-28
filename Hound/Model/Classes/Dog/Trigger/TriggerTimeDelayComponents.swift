//
//  TriggerTimeDelayComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class TriggerTimeDelayComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TriggerTimeDelayComponents()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        
        copy.triggerTimeDelay = self.triggerTimeDelay
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let triggerTimeDelay = aDecoder.decodeOptionalDouble(forKey: Constant.Key.triggerTimeDelay.rawValue)
        
        self.init(triggerTimeDelay: triggerTimeDelay)
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(triggerTimeDelay, forKey: Constant.Key.triggerTimeDelay.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var triggerTimeDelay: Double = Constant.Class.Trigger.defaultTriggerTimeDelay
    func changeTriggerTimeDelay(_ newTimeDelay: Double) -> Bool {
        guard newTimeDelay > 0 else { return false }
        triggerTimeDelay = newTimeDelay
        return true
    }
    
    // MARK: - Main
    
    init(
        triggerTimeDelay: Double? = nil
    ) {
        super.init()
        self.triggerTimeDelay = triggerTimeDelay ?? self.triggerTimeDelay
    }
    
    /// Provide a dictionary literal of reminder trigger properties to instantiate reminder trigger. Optionally, provide a reminder trigger to override with new properties from fromBody.
    convenience init?(fromBody: JSONResponseBody, componentToOverride: TriggerTimeDelayComponents?) {
        let triggerTimeDelay = fromBody[Constant.Key.triggerTimeDelay.rawValue] as? Double ?? componentToOverride?.triggerTimeDelay
        
        self.init(triggerTimeDelay: triggerTimeDelay)
    }
    
    // MARK: - Functions
    
    func readableTime() -> String {
        return "\(triggerTimeDelay.readable(capitalizeWords: false, abbreviationLevel: .short)) later"
    }
    
    func nextReminderDate(afterDate date: Date) -> Date? {
        return date.addingTimeInterval(triggerTimeDelay)
    }
    
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.triggerTimeDelay.rawValue] = .double(triggerTimeDelay)
        return body
    }
    
    // MARK: - Compare
    
    /// Returns true if all server-synced properties are identical to another trigger
    func isSame(as other: TriggerTimeDelayComponents) -> Bool {
        if triggerTimeDelay != other.triggerTimeDelay { return false }
        return true
    }
}
