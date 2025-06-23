//
//  MappingLogActionTypeLogUnitType.swift
//  Hound
//
//  Created by Jonathan Xakellis on 06/01/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class MappingLogActionTypeLogUnitType: NSObject, Comparable, NSCoding {
    
    // MARK: - Comparable
    
    static func < (lhs: MappingLogActionTypeLogUnitType, rhs: MappingLogActionTypeLogUnitType) -> Bool {
        return lhs.mappingId < rhs.mappingId
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? MappingLogActionTypeLogUnitType else {
            return false
        }
        return object.mappingId == self.mappingId
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let mappingId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.mappingId.rawValue),
            let logActionTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.logActionTypeId.rawValue),
            let logUnitTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.logUnitTypeId.rawValue)
        else {
            return nil
        }
        self.init(
            forMappingId: mappingId,
            forLogActionTypeId: logActionTypeId,
            forLogUnitTypeId: logUnitTypeId
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(mappingId, forKey: KeyConstant.mappingId.rawValue)
        aCoder.encode(logActionTypeId, forKey: KeyConstant.logActionTypeId.rawValue)
        aCoder.encode(logUnitTypeId, forKey: KeyConstant.logUnitTypeId.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var mappingId: Int
    private(set) var logActionTypeId: Int
    private(set) var logUnitTypeId: Int
    
    // MARK: - Initialization
    
    init(
        forMappingId: Int,
        forLogActionTypeId: Int,
        forLogUnitTypeId: Int
    ) {
        self.mappingId = forMappingId
        self.logActionTypeId = forLogActionTypeId
        self.logUnitTypeId = forLogUnitTypeId
        super.init()
    }
    
    convenience init?(fromBody: [String: Any?]) {
        guard
            let mappingIdVal = fromBody[KeyConstant.mappingId.rawValue] as? Int,
            let logActionTypeIdVal = fromBody[KeyConstant.logActionTypeId.rawValue] as? Int,
            let logUnitTypeIdVal = fromBody[KeyConstant.logUnitTypeId.rawValue] as? Int
        else {
            return nil
        }
        
        self.init(
            forMappingId: mappingIdVal,
            forLogActionTypeId: logActionTypeIdVal,
            forLogUnitTypeId: logUnitTypeIdVal
        )
    }
}
