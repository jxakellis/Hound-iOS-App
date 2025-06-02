//
//  GlobalTypes.swift
//  Hound
//
//  Created by Jonathan Xakellis on 06/01/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class GlobalTypes: NSObject {

    // MARK: - Properties

    private(set) var logActionTypes: [LogActionType]
    private(set) var reminderActionTypes: [ReminderActionType]
    private(set) var mappingLogActionTypeReminderActionType: [MappingLogActionTypeReminderActionType]
    private(set) var logUnitTypes: [LogUnitType]
    private(set) var mappingLogActionTypeLogUnitType: [MappingLogActionTypeLogUnitType]
    
    static var shared: GlobalTypes?

    // MARK: - Initialization

    init(
        forLogActionTypes: [LogActionType],
        forReminderActionTypes: [ReminderActionType],
        forMappingLogActionTypeReminderActionType: [MappingLogActionTypeReminderActionType],
        forLogUnitTypes: [LogUnitType],
        forMappingLogActionTypeLogUnitType: [MappingLogActionTypeLogUnitType]
    ) {
        self.logActionTypes = forLogActionTypes
        self.reminderActionTypes = forReminderActionTypes
        self.mappingLogActionTypeReminderActionType = forMappingLogActionTypeReminderActionType
        self.logUnitTypes = forLogUnitTypes
        self.mappingLogActionTypeLogUnitType = forMappingLogActionTypeLogUnitType
        super.init()
    }

    convenience init?(fromBody: [String: Any?]) {
        guard
            let logActionTypeArr = fromBody[KeyConstant.logActionType.rawValue] as? [[String: Any?]],
            let reminderActionTypeArr = fromBody[KeyConstant.reminderActionType.rawValue] as? [[String: Any?]],
            let mappingLogActionTypeReminderActionTypeArr = fromBody[KeyConstant.mappingLogActionTypeReminderActionType.rawValue] as? [[String: Any?]],
            let logUnitTypesArr = fromBody[KeyConstant.logUnitType.rawValue] as? [[String: Any?]],
            let mappingLogActionTypeLogUnitTypeArr = fromBody[KeyConstant.mappingLogActionTypeLogUnitType.rawValue] as? [[String: Any?]]
        else {
            return nil
        }

        let latMapped = logActionTypeArr.compactMap { LogActionType(fromLogActionTypeBody: $0) }
        let ratMapped = reminderActionTypeArr.compactMap { ReminderActionType(fromReminderActionTypeBody: $0) }
        let mlatratMapped = mappingLogActionTypeReminderActionTypeArr.compactMap { MappingLogActionTypeReminderActionType(fromBody: $0) }
        let lutMapped = logUnitTypesArr.compactMap { LogUnitType(fromLogUnitTypeBody: $0) }
        let mlatlutMapped = mappingLogActionTypeLogUnitTypeArr.compactMap { MappingLogActionTypeLogUnitType(fromBody: $0) }

        self.init(
            forLogActionTypes: latMapped,
            forReminderActionTypes: ratMapped,
            forMappingLogActionTypeReminderActionType: mlatratMapped,
            forLogUnitTypes: lutMapped,
            forMappingLogActionTypeLogUnitType: mlatlutMapped
        )
    }
}
