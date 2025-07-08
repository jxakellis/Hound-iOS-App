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
        guard let object = object as? ReminderActionType else {
            return false
        }
        return object.reminderActionTypeId == self.reminderActionTypeId
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let decodedReminderActionTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.reminderActionTypeId.rawValue),
            let decodedInternalValue = aDecoder.decodeOptionalString(forKey: KeyConstant.internalValue.rawValue),
            let decodedReadableValue = aDecoder.decodeOptionalString(forKey: KeyConstant.readableValue.rawValue),
            let decodedEmoji = aDecoder.decodeOptionalString(forKey: KeyConstant.emoji.rawValue),
            let decodedSortOrder = aDecoder.decodeOptionalInteger(forKey: KeyConstant.sortOrder.rawValue),
            let decodedIsDefault = aDecoder.decodeOptionalBool(forKey: KeyConstant.isDefault.rawValue),
            let decodedAllowsCustom = aDecoder.decodeOptionalBool(forKey: KeyConstant.allowsCustom.rawValue)
        else {
            return nil
        }

        self.init(
            forReminderActionTypeId: decodedReminderActionTypeId,
            forInternalValue: decodedInternalValue,
            forReadableValue: decodedReadableValue,
            forEmoji: decodedEmoji,
            forSortOrder: decodedSortOrder,
            forIsDefault: decodedIsDefault,
            forAllowsCustom: decodedAllowsCustom
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(reminderActionTypeId, forKey: KeyConstant.reminderActionTypeId.rawValue)
        aCoder.encode(internalValue, forKey: KeyConstant.internalValue.rawValue)
        aCoder.encode(readableValue, forKey: KeyConstant.readableValue.rawValue)
        aCoder.encode(emoji, forKey: KeyConstant.emoji.rawValue)
        aCoder.encode(sortOrder, forKey: KeyConstant.sortOrder.rawValue)
        aCoder.encode(isDefault, forKey: KeyConstant.isDefault.rawValue)
        aCoder.encode(allowsCustom, forKey: KeyConstant.allowsCustom.rawValue)
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
            HoundLogger.general.warning("associatedLogActionTypes:\t Expected to find >= 1 LogActionType for ReminderActionType \(self.reminderActionTypeId), but found \(results.count).")
            return []
        }
        
        return results
    }
    
    // MARK: - Initialization
    
    init(
        forReminderActionTypeId: Int,
        forInternalValue: String,
        forReadableValue: String,
        forEmoji: String,
        forSortOrder: Int,
        forIsDefault: Bool,
        forAllowsCustom: Bool
    ) {
        self.reminderActionTypeId = forReminderActionTypeId
        self.internalValue = forInternalValue
        self.readableValue = forReadableValue
        self.emoji = forEmoji
        self.sortOrder = forSortOrder
        self.isDefault = forIsDefault
        self.allowsCustom = forAllowsCustom
        super.init()
    }
    
    convenience init?(fromBody: [String: Any?]) {
        guard
            let idVal = fromBody[KeyConstant.reminderActionTypeId.rawValue] as? Int,
            let internalVal = fromBody[KeyConstant.internalValue.rawValue] as? String,
            let readableVal = fromBody[KeyConstant.readableValue.rawValue] as? String,
            let emojiVal = fromBody[KeyConstant.emoji.rawValue] as? String,
            let sortOrderVal = fromBody[KeyConstant.sortOrder.rawValue] as? Int,
            let isDefaultVal = fromBody[KeyConstant.isDefault.rawValue] as? Bool,
            let allowsCustomVal = fromBody[KeyConstant.allowsCustom.rawValue] as? Bool
        else {
            return nil
        }
        
        self.init(
            forReminderActionTypeId: idVal,
            forInternalValue: internalVal,
            forReadableValue: readableVal,
            forEmoji: emojiVal,
            forSortOrder: sortOrderVal,
            forIsDefault: isDefaultVal,
            forAllowsCustom: allowsCustomVal
        )
    }
    
    // MARK: - Readable Conversion
    
    static func find(forReminderActionTypeId: Int) -> ReminderActionType {
        return GlobalTypes.shared.reminderActionTypes.first { $0.reminderActionTypeId == forReminderActionTypeId } ?? GlobalTypes.shared.reminderActionTypes[0]
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
