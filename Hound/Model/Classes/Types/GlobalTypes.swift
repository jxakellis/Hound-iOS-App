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
    private(set) var mappingLogToReminder: [MappingLogActionTypeReminderActionType]
    
    static var shared: GlobalTypes?

    // MARK: - Initialization

    init(
        forLogActionTypes: [LogActionType],
        forReminderActionTypes: [ReminderActionType],
        forMappingLogToReminder: [MappingLogActionTypeReminderActionType]
    ) {
        self.logActionTypes = forLogActionTypes
        self.reminderActionTypes = forReminderActionTypes
        self.mappingLogToReminder = forMappingLogToReminder
        super.init()
    }

    /// Initialize from a JSON dictionary returned by the server.
    /// Expected keys:
    ///   KeyConstant.logActionType.rawValue -> [[String: Any?]]
    ///   KeyConstant.reminderActionType.rawValue -> [[String: Any?]]
    ///   KeyConstant.mappingLogActionTypeReminderActionType.rawValue -> [[String: Any?]]
    convenience init?(fromBody: [String: Any?]) {
        guard
            let logArray = fromBody[KeyConstant.logActionType.rawValue] as? [[String: Any?]],
            let reminderArray = fromBody[KeyConstant.reminderActionType.rawValue] as? [[String: Any?]],
            let mappingArray = fromBody[KeyConstant.mappingLogActionTypeReminderActionType.rawValue] as? [[String: Any?]]
        else {
            return nil
        }

        let logActionTypes = logArray.compactMap { LogActionType(fromLogActionTypeBody: $0) }
        let reminderActionTypes = reminderArray.compactMap { ReminderActionType(fromReminderActionTypeBody: $0) }
        let mappings = mappingArray.compactMap { MappingLogActionTypeReminderActionType(fromBody: $0) }

        self.init(
            forLogActionTypes: logActionTypes,
            forReminderActionTypes: reminderActionTypes,
            forMappingLogToReminder: mappings
        )
    }
}
