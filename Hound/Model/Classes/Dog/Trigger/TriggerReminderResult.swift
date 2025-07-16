//
//  TriggerReminderResult.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/10/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class TriggerReminderResult: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TriggerReminderResult()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        copy.reminderActionTypeId = self.reminderActionTypeId
        copy.reminderCustomActionName = self.reminderCustomActionName
        
        return copy
    }
    
    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        guard let decodedReminderActionTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.reminderActionTypeId.rawValue) else {
            return nil
        }
        let decodedCustomName = aDecoder.decodeOptionalString(forKey: KeyConstant.reminderCustomActionName.rawValue)
        self.init(forReminderActionTypeId: decodedReminderActionTypeId, forReminderCustomActionName: decodedCustomName)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(reminderActionTypeId, forKey: KeyConstant.reminderActionTypeId.rawValue)
        aCoder.encode(reminderCustomActionName, forKey: KeyConstant.reminderCustomActionName.rawValue)
    }
    
    // MARK: - Properties

    private(set) var reminderActionTypeId: Int = ClassConstant.ReminderConstant.defaultReminderActionTypeId
    private(set) var reminderCustomActionName: String = ""
    
    // MARK: - Main

    init(forReminderActionTypeId: Int? = nil, forReminderCustomActionName: String? = nil) {
        self.reminderActionTypeId = forReminderActionTypeId ?? reminderActionTypeId
        self.reminderCustomActionName = forReminderCustomActionName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? reminderCustomActionName
        super.init()
    }
    
    convenience init(fromBody: [String: Any?], toOverride: TriggerReminderResult?) {
        let reminderActionTypeId = fromBody[KeyConstant.reminderActionTypeId.rawValue] as? Int ?? toOverride?.reminderActionTypeId
        let reminderCustomActionName = fromBody[KeyConstant.reminderCustomActionName.rawValue] as? String ?? toOverride?.reminderCustomActionName
        
        self.init(forReminderActionTypeId: reminderActionTypeId, forReminderCustomActionName: reminderCustomActionName)
    }
    
    // MARK: - Functions
    
    func createBody() -> [String: JSONValue] {
        var body: [String: JSONValue] = [:]
        body[KeyConstant.reminderActionTypeId.rawValue] = .int(reminderActionTypeId)
        body[KeyConstant.reminderCustomActionName.rawValue] = .string(reminderCustomActionName)
        return body
        
    }
    
    // MARK: - Compare
    
    /// Returns true if all server-synced properties are identical to another trigger
    func isSame(as other: TriggerReminderResult) -> Bool {
        if reminderActionTypeId != other.reminderActionTypeId { return false }
        if reminderCustomActionName != other.reminderCustomActionName { return false }
        return true
    }
    
}
