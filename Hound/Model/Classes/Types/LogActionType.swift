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
            let decodedLogActionTypeId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logActionTypeId.rawValue),
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
            logActionTypeId: decodedLogActionTypeId,
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
        
        aCoder.encode(logActionTypeId, forKey: Constant.Key.logActionTypeId.rawValue)
        aCoder.encode(internalValue, forKey: Constant.Key.internalValue.rawValue)
        aCoder.encode(readableValue, forKey: Constant.Key.readableValue.rawValue)
        aCoder.encode(emoji, forKey: Constant.Key.emoji.rawValue)
        aCoder.encode(sortOrder, forKey: Constant.Key.sortOrder.rawValue)
        aCoder.encode(isDefault, forKey: Constant.Key.isDefault.rawValue)
        aCoder.encode(allowsCustom, forKey: Constant.Key.allowsCustom.rawValue)
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
                return logUnitType.isMetric || logUnitType.isImperial
            }
        }
        
        return logUnitTypes
    }
    
    // MARK: - Initialization
    
    init(
        logActionTypeId: Int,
        internalValue: String,
        readableValue: String,
        emoji: String,
        sortOrder: Int,
        isDefault: Bool,
        allowsCustom: Bool
    ) {
        self.logActionTypeId = logActionTypeId
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
            let idVal = fromBody[Constant.Key.logActionTypeId.rawValue] as? Int,
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
            logActionTypeId: idVal,
            internalValue: internalVal,
            readableValue: readableVal,
            emoji: emojiVal,
            sortOrder: sortOrderVal,
            isDefault: isDefaultVal,
            allowsCustom: allowsCustomVal
        )
    }
    
    // MARK: - Readable Conversion
    
    static func find(logActionTypeId: Int) -> LogActionType {
        guard let found = GlobalTypes.shared.logActionTypes.first(where: { $0.logActionTypeId == logActionTypeId }) else {
            HoundLogger.general.error("LogActionType.find: No LogActionType found for id \(logActionTypeId). Returning default LogActionType.")
            return GlobalTypes.shared.logActionTypes[0]
        }
        return found
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
