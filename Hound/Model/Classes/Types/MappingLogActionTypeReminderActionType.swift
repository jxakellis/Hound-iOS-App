//
//  MappingLogActionTypeReminderActionType.swift
//  Hound
//
//  Created by Jonathan Xakellis on 06/01/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class MappingLogActionTypeReminderActionType: NSObject, Comparable, NSCoding {
    
    // MARK: - Comparable
    
    static func < (lhs: MappingLogActionTypeReminderActionType, rhs: MappingLogActionTypeReminderActionType) -> Bool {
        return lhs.mappingId < rhs.mappingId
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? MappingLogActionTypeReminderActionType else {
            return false
        }
        return object.mappingId == self.mappingId
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let mappingId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.mappingId.rawValue),
            let logActionTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.logActionTypeId.rawValue),
            let reminderActionTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.reminderActionTypeId.rawValue)
        else {
            return nil
        }
        self.init(
            forMappingId: mappingId,
            forLogActionTypeId: logActionTypeId,
            forReminderActionTypeId: reminderActionTypeId
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(mappingId, forKey: KeyConstant.mappingId.rawValue)
        aCoder.encode(logActionTypeId, forKey: KeyConstant.logActionTypeId.rawValue)
        aCoder.encode(reminderActionTypeId, forKey: KeyConstant.reminderActionTypeId.rawValue)
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
