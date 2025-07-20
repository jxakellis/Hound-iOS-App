//
//  GlobalTypes.swift
//  Hound
//
//  Created by Jonathan Xakellis on 06/01/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class GlobalTypes: NSObject, NSCoding, UserDefaultPersistable {
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let logActionTypes: [LogActionType] = aDecoder.decodeOptionalObject(forKey: Constant.Key.logActionType.rawValue),
            let reminderActionTypes: [ReminderActionType] = aDecoder.decodeOptionalObject(forKey: Constant.Key.reminderActionType.rawValue),
            let mappingLogActionTypeReminderActionType: [MappingLogActionTypeReminderActionType] = aDecoder.decodeOptionalObject(forKey: Constant.Key.mappingLogActionTypeReminderActionType.rawValue),
            let logUnitTypes: [LogUnitType] = aDecoder.decodeOptionalObject(forKey: Constant.Key.logUnitType.rawValue),
            let mappingLogActionTypeLogUnitType: [MappingLogActionTypeLogUnitType] = aDecoder.decodeOptionalObject(forKey: Constant.Key.mappingLogActionTypeLogUnitType.rawValue)
        else {
            return nil
        }
        self.init(
            forLogActionTypes: logActionTypes,
            forReminderActionTypes: reminderActionTypes,
            forMappingLogActionTypeReminderActionType: mappingLogActionTypeReminderActionType,
            forLogUnitTypes: logUnitTypes,
            forMappingLogActionTypeLogUnitType: mappingLogActionTypeLogUnitType
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(logActionTypes, forKey: Constant.Key.logActionType.rawValue)
        aCoder.encode(reminderActionTypes, forKey: Constant.Key.reminderActionType.rawValue)
        aCoder.encode(mappingLogActionTypeReminderActionType, forKey: Constant.Key.mappingLogActionTypeReminderActionType.rawValue)
        aCoder.encode(logUnitTypes, forKey: Constant.Key.logUnitType.rawValue)
        aCoder.encode(mappingLogActionTypeLogUnitType, forKey: Constant.Key.mappingLogActionTypeLogUnitType.rawValue)
    }
    
    // MARK: - UserDefaultPersistable
    
    /// Persists all of the LocalConfiguration variables and the globalGlobalTypes to the specified UserDefaults
    static func persist(toUserDefaults: UserDefaults) {
        guard let globalTypes = GlobalTypes.shared else {
            HoundLogger.general.error("GlobalTypes.persist: GlobalTypes.shared is nil, cannot persist to UserDefaults")
            return
        }
        
        do {
            let dataGlobalTypes = try NSKeyedArchiver.archivedData(withRootObject: globalTypes, requiringSecureCoding: false)
            toUserDefaults.set(dataGlobalTypes, forKey: Constant.Key.globalTypes.rawValue)
        }
        catch {
            HoundLogger.general.error("GlobalTypes.persist: Failed to persist globalTypes with NSKeyedArchiver: \(error)")
        }
    }
    
    /// Load all of the LocalConfiguration variables and the globalGlobalTypes from the specified UserDefaults
    static func load(fromUserDefaults: UserDefaults) {
        guard let dataGlobalTypes = fromUserDefaults.data(forKey: Constant.Key.globalTypes.rawValue) else {
            HoundLogger.general.error("GlobalTypes.load: No data found for globalTypes in UserDefaults")
            GlobalTypes.shared = nil
            return
        }
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: dataGlobalTypes)
            unarchiver.requiresSecureCoding = false
            if let globalTypes = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? GlobalTypes {
                GlobalTypes.shared = globalTypes
            }
            else {
                HoundLogger.general.error("GlobalTypes.load: Failed to decode globalTypes with unarchiver")
                GlobalTypes.shared = nil
                // clear dogManager and previousDogManagerSynchronization as if those try to init without global types, the app will crash
                // client needs to fetch global types from server
                UserDefaults.standard.set(nil, forKey: Constant.Key.previousDogManagerSynchronization.rawValue)
                UserDefaults.standard.set(nil, forKey: Constant.Key.dogManager.rawValue)
            }
        }
        catch {
            HoundLogger.general.error("GlobalTypes.load: Failed to unarchive globalTypes: \(error)")
            GlobalTypes.shared = nil
            // clear dogManager and previousDogManagerSynchronization as if those try to init without global types, the app will crash
            // client needs to fetch global types from server
            UserDefaults.standard.set(nil, forKey: Constant.Key.previousDogManagerSynchronization.rawValue)
            UserDefaults.standard.set(nil, forKey: Constant.Key.dogManager.rawValue)
        }
    }
    
    // MARK: - Properties
    
    private(set) var logActionTypes: [LogActionType]
    private(set) var reminderActionTypes: [ReminderActionType]
    private(set) var mappingLogActionTypeReminderActionType: [MappingLogActionTypeReminderActionType]
    private(set) var logUnitTypes: [LogUnitType]
    private(set) var mappingLogActionTypeLogUnitType: [MappingLogActionTypeLogUnitType]
    
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
            HoundLogger.general.error("GlobalTypes.init: logActionTypes is empty for GlobalTypes")
        }
        if reminderActionTypes.isEmpty {
            HoundLogger.general.error("GlobalTypes.init: reminderActionTypes is empty for GlobalTypes")
        }
        if mappingLogActionTypeReminderActionType.isEmpty {
            HoundLogger.general.error("GlobalTypes.init: mappingLogActionTypeReminderActionType is empty for GlobalTypes")
        }
        if logUnitTypes.isEmpty {
            HoundLogger.general.error("GlobalTypes.init: logUnitTypes is empty for GlobalTypes")
        }
        if mappingLogActionTypeLogUnitType.isEmpty {
            HoundLogger.general.error("GlobalTypes.init: mappingLogActionTypeLogUnitType is empty for GlobalTypes")
        }
        super.init()
    }
    
    convenience init?(fromBody: JSONResponseBody) {
        guard
            let logActionTypeArr = fromBody[Constant.Key.logActionType.rawValue] as? [JSONResponseBody],
            let reminderActionTypeArr = fromBody[Constant.Key.reminderActionType.rawValue] as? [JSONResponseBody],
            let mappingLogActionTypeReminderActionTypeArr = fromBody[Constant.Key.mappingLogActionTypeReminderActionType.rawValue] as? [JSONResponseBody],
            let logUnitTypesArr = fromBody[Constant.Key.logUnitType.rawValue] as? [JSONResponseBody],
            let mappingLogActionTypeLogUnitTypeArr = fromBody[Constant.Key.mappingLogActionTypeLogUnitType.rawValue] as? [JSONResponseBody]
        else {
            HoundLogger.general.error("GlobalTypes.init: Unable to decode types for GlobalTypes. fromBody is as follows \(fromBody)")
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
