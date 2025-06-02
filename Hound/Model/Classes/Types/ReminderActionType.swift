//
//  ReminderActionType.swift
//  Hound
//
//  Created by Jonathan Xakellis on 06/01/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class ReminderActionType: NSObject, Comparable {

    // MARK: - Comparable

    static func < (lhs: ReminderActionType, rhs: ReminderActionType) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.reminderActionTypeId < rhs.reminderActionTypeId
    }

    static func == (lhs: ReminderActionType, rhs: ReminderActionType) -> Bool {
        return lhs.reminderActionTypeId == rhs.reminderActionTypeId &&
               lhs.internalValue == rhs.internalValue &&
               lhs.readableValue == rhs.readableValue &&
               lhs.emoji == rhs.emoji &&
               lhs.sortOrder == rhs.sortOrder &&
               lhs.isDefault == rhs.isDefault &&
               lhs.allowsCustom == rhs.allowsCustom
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
        let gt = GlobalTypes.shared!
        
        let matchingMappings = gt.mappingLogActionTypeReminderActionType.filter {
            $0.reminderActionTypeId == self.reminderActionTypeId
        }
        
        let logIds = matchingMappings.map { $0.logActionTypeId }
        
        let results = gt.logActionTypes.filter {
            logIds.contains($0.logActionTypeId)
        }
        
        // all reminder actions should map to at least one log action type
        if (results.count < 1) {
            AppDelegate.generalLogger.warning("Expected to find >= 1 LogActionType for ReminderActionType \(self.reminderActionTypeId), but found \(results.count).")
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

    convenience init?(fromReminderActionTypeBody: [String: Any?]) {
        guard
            let idVal = fromReminderActionTypeBody[KeyConstant.reminderActionTypeId.rawValue] as? Int,
            let internalVal = fromReminderActionTypeBody[KeyConstant.internalValue.rawValue] as? String,
            let readableVal = fromReminderActionTypeBody[KeyConstant.readableValue.rawValue] as? String,
            let emojiVal = fromReminderActionTypeBody[KeyConstant.emoji.rawValue] as? String,
            let sortOrderVal = fromReminderActionTypeBody[KeyConstant.sortOrder.rawValue] as? Int,
            let isDefaultVal = fromReminderActionTypeBody[KeyConstant.isDefault.rawValue] as? Bool,
            let allowsCustomVal = fromReminderActionTypeBody[KeyConstant.allowsCustom.rawValue] as? Bool
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
    
    static func find(forReminderActionTypeId: Int) -> ReminderActionType? {
        return GlobalTypes.shared!.reminderActionTypes.first { $0.reminderActionTypeId == forReminderActionTypeId }
    }

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
