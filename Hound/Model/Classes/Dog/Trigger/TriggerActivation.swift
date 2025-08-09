//
//  TriggerActivation.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class TriggerActivation: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TriggerActivation()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        copy.activationDate = self.activationDate
        
        return copy
    }
    
    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        let activationDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.activationDate.rawValue)
        self.init(activationDate: activationDate)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(activationDate, forKey: Constant.Key.activationDate.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TriggerActivation else {
            return false
        }
        return other.activationDate == self.activationDate
    }
    
    // MARK: - Properties

    private(set) var activationDate: Date
    
    // MARK: - Main

    init(activationDate: Date? = nil) {
        self.activationDate = activationDate ?? Date()
        super.init()
    }
    
    convenience init(fromBody: JSONResponseBody, toOverride: TriggerActivation?) {
        let activationDate = (fromBody[Constant.Key.activationDate.rawValue] as? String)?.formatISO8601IntoDate() ?? toOverride?.activationDate
        
        self.init(activationDate: activationDate)
    }
    
    // MARK: - Functions
    
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.activationDate.rawValue] = .string(activationDate.ISO8601FormatWithFractionalSeconds())
        return body
        
    }
}
