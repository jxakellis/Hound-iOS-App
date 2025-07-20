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
        guard let decodedReminderActionTypeId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.reminderActionTypeId.rawValue) else {
            return nil
        }
        let decodedCustomName = aDecoder.decodeOptionalString(forKey: Constant.Key.reminderCustomActionName.rawValue)
        self.init(forReminderActionTypeId: decodedReminderActionTypeId, forReminderCustomActionName: decodedCustomName)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(reminderActionTypeId, forKey: Constant.Key.reminderActionTypeId.rawValue)
        aCoder.encode(reminderCustomActionName, forKey: Constant.Key.reminderCustomActionName.rawValue)
    }
    
    // MARK: - Properties

    private(set) var reminderActionTypeId: Int = Constant.Class.Reminder.defaultReminderActionTypeId
    private(set) var reminderCustomActionName: String = ""
    
    var readableName: String {
        return ReminderActionType.find(forReminderActionTypeId: reminderActionTypeId).convertToReadableName(customActionName: reminderCustomActionName, includeMatchingEmoji: true)
    }
    
    // MARK: - Main

    init(forReminderActionTypeId: Int? = nil, forReminderCustomActionName: String? = nil) {
        self.reminderActionTypeId = forReminderActionTypeId ?? reminderActionTypeId
        self.reminderCustomActionName = forReminderCustomActionName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? reminderCustomActionName
        super.init()
    }
    
    convenience init(fromBody: JSONResponseBody, toOverride: TriggerReminderResult?) {
        let reminderActionTypeId = fromBody[Constant.Key.reminderActionTypeId.rawValue] as? Int ?? toOverride?.reminderActionTypeId
        let reminderCustomActionName = fromBody[Constant.Key.reminderCustomActionName.rawValue] as? String ?? toOverride?.reminderCustomActionName
        
        self.init(forReminderActionTypeId: reminderActionTypeId, forReminderCustomActionName: reminderCustomActionName)
    }
    
    // MARK: - Functions
    
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.reminderActionTypeId.rawValue] = .int(reminderActionTypeId)
        body[Constant.Key.reminderCustomActionName.rawValue] = .string(reminderCustomActionName)
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
