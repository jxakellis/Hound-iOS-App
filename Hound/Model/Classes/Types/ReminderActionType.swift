//
//  ReminderActionType.swift
//  Hound
//
//  Created by Jonathan Xakellis on 06/01/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class ReminderActionType: NSObject, Comparable, NSCoding {
    
    // MARK: - Comparable
    
    static func < (lhs: ReminderActionType, rhs: ReminderActionType) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.reminderActionTypeId < rhs.reminderActionTypeId
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ReminderActionType else {
            return false
        }
        return other.reminderActionTypeId == self.reminderActionTypeId
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let decodedReminderActionTypeId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.reminderActionTypeId.rawValue),
            let decodedInternalValue = aDecoder.decodeOptionalString(forKey: Constant.Key.internalValue.rawValue),
            let decodedReadableValue = aDecoder.decodeOptionalString(forKey: Constant.Key.readableValue.rawValue),
            let decodedEmoji = aDecoder.decodeOptionalString(forKey: Constant.Key.emoji.rawValue),
            let decodedSortOrder = aDecoder.decodeOptionalInteger(forKey: Constant.Key.sortOrder.rawValue),
            let decodedIsDefault = aDecoder.decodeOptionalBool(forKey: Constant.Key.isDefault.rawValue),
            let decodedAllowsCustom = aDecoder.decodeOptionalBool(forKey: Constant.Key.allowsCustom.rawValue)
        else {
            return nil
        }

        self.init(
            reminderActionTypeId: decodedReminderActionTypeId,
            internalValue: decodedInternalValue,
            readableValue: decodedReadableValue,
            emoji: decodedEmoji,
            sortOrder: decodedSortOrder,
            isDefault: decodedIsDefault,
            allowsCustom: decodedAllowsCustom
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(reminderActionTypeId, forKey: Constant.Key.reminderActionTypeId.rawValue)
        aCoder.encode(internalValue, forKey: Constant.Key.internalValue.rawValue)
        aCoder.encode(readableValue, forKey: Constant.Key.readableValue.rawValue)
        aCoder.encode(emoji, forKey: Constant.Key.emoji.rawValue)
        aCoder.encode(sortOrder, forKey: Constant.Key.sortOrder.rawValue)
        aCoder.encode(isDefault, forKey: Constant.Key.isDefault.rawValue)
        aCoder.encode(allowsCustom, forKey: Constant.Key.allowsCustom.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var reminderActionTypeId: Int
    private(set) var internalValue: String
    private(set) var readableValue: String
    private(set) var emoji: String
    private(set) var sortOrder: Int
    private(set) var isDefault: Bool
    private(set) var allowsCustom: Bool
    
    var associatedLogActionTypes: [LogActionType] {
        let matchingMappings = GlobalTypes.shared.mappingLogActionTypeReminderActionType.filter {
            $0.reminderActionTypeId == self.reminderActionTypeId
        }
        
        let logIds = matchingMappings.map { $0.logActionTypeId }
        
        let results = GlobalTypes.shared.logActionTypes.filter {
            logIds.contains($0.logActionTypeId)
        }
        
        // all reminder actions should map to at least one log action type
        if results.count < 1 {
            HoundLogger.general.warning("associatedLogActionTypes: Expected to find >= 1 LogActionType for ReminderActionType \(self.reminderActionTypeId), but found \(results.count).")
            return []
        }
        
        return results
    }
    
    // MARK: - Initialization
    
    init(
        reminderActionTypeId: Int,
        internalValue: String,
        readableValue: String,
        emoji: String,
        sortOrder: Int,
        isDefault: Bool,
        allowsCustom: Bool
    ) {
        self.reminderActionTypeId = reminderActionTypeId
        self.internalValue = internalValue
        self.readableValue = readableValue
        self.emoji = emoji
        self.sortOrder = sortOrder
        self.isDefault = isDefault
        self.allowsCustom = allowsCustom
        super.init()
    }
    
    convenience init?(fromBody: JSONResponseBody) {
        guard
            let idVal = fromBody[Constant.Key.reminderActionTypeId.rawValue] as? Int,
            let internalVal = fromBody[Constant.Key.internalValue.rawValue] as? String,
            let readableVal = fromBody[Constant.Key.readableValue.rawValue] as? String,
            let emojiVal = fromBody[Constant.Key.emoji.rawValue] as? String,
            let sortOrderVal = fromBody[Constant.Key.sortOrder.rawValue] as? Int,
            let isDefaultVal = fromBody[Constant.Key.isDefault.rawValue] as? Bool,
            let allowsCustomVal = fromBody[Constant.Key.allowsCustom.rawValue] as? Bool
        else {
            return nil
        }
        
        self.init(
            reminderActionTypeId: idVal,
            internalValue: internalVal,
            readableValue: readableVal,
            emoji: emojiVal,
            sortOrder: sortOrderVal,
            isDefault: isDefaultVal,
            allowsCustom: allowsCustomVal
        )
    }
    
    // MARK: - Readable Conversion
    
    static func find(reminderActionTypeId: Int) -> ReminderActionType {
        guard let found = GlobalTypes.shared.reminderActionTypes.first(where: { $0.reminderActionTypeId == reminderActionTypeId }) else {
            HoundLogger.general.error("ReminderActionType.find: No ReminderActionType found for id \(reminderActionTypeId). Returning default ReminderActionType.")
            return GlobalTypes.shared.reminderActionTypes[0]
        }
        return found
    }
    
    func convertToReadableName(
        customActionName: String?,
        includeMatchingEmoji: Bool = false,
    ) -> String {
        var result = ""
        
        if allowsCustom, let name = customActionName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            result += name
        }
        else {
            result += readableValue
        }
        
        if includeMatchingEmoji {
            result += " " + emoji
        }
        
        return result
    }
}
