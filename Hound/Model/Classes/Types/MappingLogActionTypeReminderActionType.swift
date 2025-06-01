//
//  MappingLogActionTypeReminderActionType.swift
//  Hound
//
//  Created by Jonathan Xakellis on 06/01/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class MappingLogActionTypeReminderActionType: NSObject, Comparable {

    // MARK: - Comparable

    static func < (lhs: MappingLogActionTypeReminderActionType, rhs: MappingLogActionTypeReminderActionType) -> Bool {
        return lhs.mappingId < rhs.mappingId
    }

    static func == (lhs: MappingLogActionTypeReminderActionType, rhs: MappingLogActionTypeReminderActionType) -> Bool {
        return lhs.mappingId == rhs.mappingId &&
               lhs.logActionTypeId == rhs.logActionTypeId &&
               lhs.reminderActionTypeId == rhs.reminderActionTypeId
    }

    // MARK: - Properties

    private(set) var mappingId: Int
    private(set) var logActionTypeId: Int
    private(set) var reminderActionTypeId: Int

    // MARK: - Initialization

    init(
        forMappingId: Int,
        forLogActionTypeId: Int,
        forReminderActionTypeId: Int
    ) {
        self.mappingId = forMappingId
        self.logActionTypeId = forLogActionTypeId
        self.reminderActionTypeId = forReminderActionTypeId
        super.init()
    }

    convenience init?(fromBody: [String: Any?]) {
        guard
            let mappingIdVal = fromBody[KeyConstant.mappingId.rawValue] as? Int,
            let logActionTypeIdVal = fromBody[KeyConstant.logActionTypeId.rawValue] as? Int,
            let reminderActionTypeIdVal = fromBody[KeyConstant.reminderActionTypeId.rawValue] as? Int
        else {
            return nil
        }

        self.init(
            forMappingId: mappingIdVal,
            forLogActionTypeId: logActionTypeIdVal,
            forReminderActionTypeId: reminderActionTypeIdVal
        )
    }
}
