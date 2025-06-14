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
    
    // TODO RT save a version of this so that the app can open from complete close. attempt to fetch updated GT when app launches but if not just use persisted version
    static var shared: GlobalTypes!

    // MARK: - Initialization

    init(
        forLogActionTypes: [LogActionType],
        forReminderActionTypes: [ReminderActionType],
        forMappingLogActionTypeReminderActionType: [MappingLogActionTypeReminderActionType],
        forLogUnitTypes: [LogUnitType],
        forMappingLogActionTypeLogUnitType: [MappingLogActionTypeLogUnitType]
    ) {
        self.logActionTypes = forLogActionTypes.sorted()
        self.reminderActionTypes = forReminderActionTypes.sorted()
        self.mappingLogActionTypeReminderActionType = forMappingLogActionTypeReminderActionType.sorted()
        self.logUnitTypes = forLogUnitTypes.sorted()
        self.mappingLogActionTypeLogUnitType = forMappingLogActionTypeLogUnitType.sorted()
        if logActionTypes.isEmpty {
            AppDelegate.generalLogger.error("logActionTypes is empty for GlobalTypes")
        }
        if reminderActionTypes.isEmpty {
            AppDelegate.generalLogger.error("reminderActionTypes is empty for GlobalTypes")
        }
        if mappingLogActionTypeReminderActionType.isEmpty {
            AppDelegate.generalLogger.error("mappingLogActionTypeReminderActionType is empty for GlobalTypes")
        }
        if logUnitTypes.isEmpty {
            AppDelegate.generalLogger.error("logUnitTypes is empty for GlobalTypes")
        }
        if mappingLogActionTypeLogUnitType.isEmpty {
            AppDelegate.generalLogger.error("mappingLogActionTypeLogUnitType is empty for GlobalTypes")
        }
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
            AppDelegate.generalLogger.error("Unable to decode types for GlobalTypes. fromBody is as follows \(fromBody)")
            return nil
        }

        let latMapped = logActionTypeArr.compactMap { LogActionType(fromBody: $0) }
        let ratMapped = reminderActionTypeArr.compactMap { ReminderActionType(fromBody: $0) }
        let mlatratMapped = mappingLogActionTypeReminderActionTypeArr.compactMap { MappingLogActionTypeReminderActionType(fromBody: $0) }
        let lutMapped = logUnitTypesArr.compactMap { LogUnitType(fromBody: $0) }
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
