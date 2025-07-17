//
//  TriggerLogReaction.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/10/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class TriggerLogReaction: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TriggerLogReaction()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        copy.logActionTypeId = self.logActionTypeId
        copy.logCustomActionName = self.logCustomActionName
        
        return copy
    }
    
    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        guard let decodedLogActionTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.logActionTypeId.rawValue) else {
            return nil
        }
        let decodedCustomName = aDecoder.decodeOptionalString(forKey: KeyConstant.logCustomActionName.rawValue)
        self.init(forLogActionTypeId: decodedLogActionTypeId, forLogCustomActionName: decodedCustomName)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(logActionTypeId, forKey: KeyConstant.logActionTypeId.rawValue)
        aCoder.encode(logCustomActionName, forKey: KeyConstant.logCustomActionName.rawValue)
    }
    
    // MARK: - Properties

    private(set) var logActionTypeId: Int = ClassConstant.LogConstant.defaultLogActionTypeId
    private(set) var logCustomActionName: String = ""
    
    var readableName: String {
        return LogActionType.find(forLogActionTypeId: logActionTypeId).convertToReadableName(customActionName: logCustomActionName, includeMatchingEmoji: true)
    }
    
    // MARK: - Main

    init(forLogActionTypeId: Int? = nil, forLogCustomActionName: String? = nil) {
        self.logActionTypeId = forLogActionTypeId ?? logActionTypeId
        self.logCustomActionName = forLogCustomActionName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? logCustomActionName
        super.init()
    }
    
    convenience init(fromBody: [String: Any?], toOverride: TriggerLogReaction?) {
        let logActionTypeId = fromBody[KeyConstant.logActionTypeId.rawValue] as? Int ?? toOverride?.logActionTypeId
        let logCustomActionName = fromBody[KeyConstant.logCustomActionName.rawValue] as? String ?? toOverride?.logCustomActionName
        
        self.init(forLogActionTypeId: logActionTypeId, forLogCustomActionName: logCustomActionName)
    }
    
    // MARK: - Functions
    
    func createBody() -> [String: JSONValue] {
        var body: [String: JSONValue] = [:]
        body[KeyConstant.logActionTypeId.rawValue] = .int(logActionTypeId)
        body[KeyConstant.logCustomActionName.rawValue] = .string(logCustomActionName)
        return body
        
    }
    
    // MARK: - Compare
    
    /// Returns true if all server-synced properties are identical to another trigger
    func isSame(as other: TriggerLogReaction) -> Bool {
        if logActionTypeId != other.logActionTypeId { return false }
        if logCustomActionName != other.logCustomActionName { return false }
        return true
    }
    
}
