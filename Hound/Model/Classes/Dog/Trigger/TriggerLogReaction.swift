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
        guard let decodedLogActionTypeId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logActionTypeId.rawValue) else {
            return nil
        }
        let decodedCustomName = aDecoder.decodeOptionalString(forKey: Constant.Key.logCustomActionName.rawValue)
        self.init(logActionTypeId: decodedLogActionTypeId, logCustomActionName: decodedCustomName)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(logActionTypeId, forKey: Constant.Key.logActionTypeId.rawValue)
        aCoder.encode(logCustomActionName, forKey: Constant.Key.logCustomActionName.rawValue)
    }
    
    // MARK: - Properties

    private(set) var logActionTypeId: Int = Constant.Class.Log.defaultLogActionTypeId
    private(set) var logCustomActionName: String = ""
    
    // MARK: - Main

    init(logActionTypeId: Int? = nil, logCustomActionName: String? = nil) {
        self.logActionTypeId = logActionTypeId ?? self.logActionTypeId
        self.logCustomActionName = logCustomActionName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? self.logCustomActionName
        super.init()
    }
    
    convenience init(fromBody: JSONResponseBody, toOverride: TriggerLogReaction?) {
        let logActionTypeId = fromBody[Constant.Key.logActionTypeId.rawValue] as? Int ?? toOverride?.logActionTypeId
        let logCustomActionName = fromBody[Constant.Key.logCustomActionName.rawValue] as? String ?? toOverride?.logCustomActionName
        
        self.init(logActionTypeId: logActionTypeId, logCustomActionName: logCustomActionName)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TriggerLogReaction else {
            return false
        }
        if logActionTypeId != other.logActionTypeId { return false }
        if logCustomActionName != other.logCustomActionName { return false }
        return true
    }
    
    // MARK: - Functions
    
    func readableName(includeMatchingEmoji: Bool) -> String {
        return LogActionType.find(logActionTypeId: logActionTypeId).convertToReadableName(customActionName: logCustomActionName, includeMatchingEmoji: includeMatchingEmoji)
    }
    
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.logActionTypeId.rawValue] = .int(logActionTypeId)
        body[Constant.Key.logCustomActionName.rawValue] = .string(logCustomActionName)
        return body
        
    }
}
