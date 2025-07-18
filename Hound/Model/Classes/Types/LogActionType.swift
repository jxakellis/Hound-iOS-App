//
//  LogActionType.swift
//  Hound
//
//  Created by Jonathan Xakellis on 06/01/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogActionType: NSObject, Comparable, NSCoding {
    
    // MARK: - Comparable
    
    static func < (lhs: LogActionType, rhs: LogActionType) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.logActionTypeId < rhs.logActionTypeId
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? LogActionType else {
            return false
        }
        return object.logActionTypeId == self.logActionTypeId
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let decodedLogActionTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.logActionTypeId.rawValue),
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
            forLogActionTypeId: decodedLogActionTypeId,
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
        
        aCoder.encode(logActionTypeId, forKey: KeyConstant.logActionTypeId.rawValue)
        aCoder.encode(internalValue, forKey: KeyConstant.internalValue.rawValue)
        aCoder.encode(readableValue, forKey: KeyConstant.readableValue.rawValue)
        aCoder.encode(emoji, forKey: KeyConstant.emoji.rawValue)
        aCoder.encode(sortOrder, forKey: KeyConstant.sortOrder.rawValue)
        aCoder.encode(isDefault, forKey: KeyConstant.isDefault.rawValue)
        aCoder.encode(allowsCustom, forKey: KeyConstant.allowsCustom.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var logActionTypeId: Int
    private(set) var internalValue: String
    private(set) var readableValue: String
    private(set) var emoji: String
    private(set) var sortOrder: Int
    private(set) var isDefault: Bool
    private(set) var allowsCustom: Bool
    
    var associatedReminderActionType: ReminderActionType? {
        let matchingMappings = GlobalTypes.shared.mappingLogActionTypeReminderActionType.filter {
            $0.logActionTypeId == self.logActionTypeId
        }
        
        let reminderIds = matchingMappings.map { $0.reminderActionTypeId }
        
        let reminderActionTypes = GlobalTypes.shared.reminderActionTypes.filter {
            reminderIds.contains($0.reminderActionTypeId)
        }
        
        // should only be 1 reverse mapping
        // not all log actions have an associated reminder action type
        
        return reminderActionTypes.first
    }
    
    var associatedLogUnitTypes: [LogUnitType] {
        let matchingMappings = GlobalTypes.shared.mappingLogActionTypeLogUnitType.filter {
            $0.logActionTypeId == self.logActionTypeId
        }
        
        let unitIds = matchingMappings.map { $0.logUnitTypeId }
        
        var logUnitTypes = GlobalTypes.shared.logUnitTypes.filter {
            unitIds.contains($0.logUnitTypeId)
        }
        
        logUnitTypes = logUnitTypes.filter { logUnitType in
            switch UserConfiguration.measurementSystem {
            case .imperial:
                return logUnitType.isImperial
            case .metric:
                return logUnitType.isMetric
            case .both:
                // .both should never happen, but if it does, fall through to metric
                return logUnitType.isMetric
            }
        }
        
        return logUnitTypes
    }
    
    // MARK: - Initialization
    
    init(
        forLogActionTypeId: Int,
        forInternalValue: String,
        forReadableValue: String,
        forEmoji: String,
        forSortOrder: Int,
        forIsDefault: Bool,
        forAllowsCustom: Bool
    ) {
        self.logActionTypeId = forLogActionTypeId
        self.internalValue = forInternalValue
        self.readableValue = forReadableValue
        self.emoji = forEmoji
        self.sortOrder = forSortOrder
        self.isDefault = forIsDefault
        self.allowsCustom = forAllowsCustom
        super.init()
    }
    
    convenience init?(fromBody: JSONResponseBody) {
        guard
            let idVal = fromBody[KeyConstant.logActionTypeId.rawValue] as? Int,
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
            forLogActionTypeId: idVal,
            forInternalValue: internalVal,
            forReadableValue: readableVal,
            forEmoji: emojiVal,
            forSortOrder: sortOrderVal,
            forIsDefault: isDefaultVal,
            forAllowsCustom: allowsCustomVal
        )
    }
    
    // MARK: - Readable Conversion
    
    static func find(forLogActionTypeId: Int) -> LogActionType {
        return GlobalTypes.shared.logActionTypes.first { $0.logActionTypeId == forLogActionTypeId } ?? GlobalTypes.shared.logActionTypes[0]
    }
    
    func convertToReadableName(
        customActionName: String?,
        includeMatchingEmoji: Bool = false
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
