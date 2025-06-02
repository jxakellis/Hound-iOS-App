//
//  LogActionType.swift
//  Hound
//
//  Created by Jonathan Xakellis on 06/01/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogActionType: NSObject, Comparable {
    
    // MARK: - Comparable
    
    static func < (lhs: LogActionType, rhs: LogActionType) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.logActionTypeId < rhs.logActionTypeId
    }
    
    static func == (lhs: LogActionType, rhs: LogActionType) -> Bool {
        return lhs.logActionTypeId == rhs.logActionTypeId &&
        lhs.internalValue == rhs.internalValue &&
        lhs.readableValue == rhs.readableValue &&
        lhs.emoji == rhs.emoji &&
        lhs.sortOrder == rhs.sortOrder &&
        lhs.isDefault == rhs.isDefault &&
        lhs.allowsCustom == rhs.allowsCustom
    }
    
    // MARK: - Properties
    
    private(set) var logActionTypeId: Int
    private(set) var internalValue: String
    private(set) var readableValue: String
    private(set) var emoji: String
    private(set) var sortOrder: Int
    private(set) var isDefault: Bool
    private(set) var allowsCustom: Bool
    
    var associatedReminderActionType: ReminderActionType {
        let gt = GlobalTypes.shared!;
        
        let matchingMappings = gt.mappingLogActionTypeReminderActionType.filter {
            $0.logActionTypeId == self.logActionTypeId
        }
        
        let reminderIds = matchingMappings.map { $0.reminderActionTypeId }
        
        let reminderActionTypes = gt.reminderActionTypes.filter {
            reminderIds.contains($0.reminderActionTypeId)
        }
        
        // should only be 1 reverse mapping
        // not all log actions have an associated reminder action type
        
        return reminderActionTypes[0]
    }
    
    var associatedLogUnitTypes: [LogUnitType] {
        let gt = GlobalTypes.shared!
        
        let matchingMappings = gt.mappingLogActionTypeLogUnitType.filter {
            $0.logActionTypeId == self.logActionTypeId
        }
        
        let unitIds = matchingMappings.map { $0.logUnitTypeId }
        
        var logUnits = gt.logUnitTypes.filter {
            unitIds.contains($0.logUnitTypeId)
        }
        
        logUnits = logUnits.filter { logUnit in
            switch UserConfiguration.measurementSystem {
            case .imperial:
                return logUnit.isImperial
            case .metric:
                return logUnit.isMetric
            case .both:
                // .both should never happen, but if it does, fall through to metric
                return logUnit.isMetric
            }
        }
        
        return logUnits
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
    
    convenience init?(fromLogActionTypeBody: [String: Any?]) {
        guard
            let idVal = fromLogActionTypeBody[KeyConstant.logActionTypeId.rawValue] as? Int,
            let internalVal = fromLogActionTypeBody[KeyConstant.internalValue.rawValue] as? String,
            let readableVal = fromLogActionTypeBody[KeyConstant.readableValue.rawValue] as? String,
            let emojiVal = fromLogActionTypeBody[KeyConstant.emoji.rawValue] as? String,
            let sortOrderVal = fromLogActionTypeBody[KeyConstant.sortOrder.rawValue] as? Int,
            let isDefaultVal = fromLogActionTypeBody[KeyConstant.isDefault.rawValue] as? Bool,
            let allowsCustomVal = fromLogActionTypeBody[KeyConstant.allowsCustom.rawValue] as? Bool
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
    
    func convertToFinalReadable(
        includeMatchingEmoji: Bool,
        customActionName: String? = nil
    ) -> String {
        var result = ""
        
        if allowsCustom,
           let name = customActionName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !name.isEmpty
        {
            result += name
        } else {
            result += readableValue
        }
        
        if includeMatchingEmoji {
            result += " " + emoji
        }
        
        return result
    }
}
