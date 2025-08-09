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
        guard let other = object as? MappingLogActionTypeLogUnitType else {
            return false
        }
        return other.mappingId == self.mappingId
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let mappingId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.mappingId.rawValue),
            let logActionTypeId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logActionTypeId.rawValue),
            let logUnitTypeId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logUnitTypeId.rawValue)
        else {
            return nil
        }
        self.init(
            mappingId: mappingId,
            logActionTypeId: logActionTypeId,
            logUnitTypeId: logUnitTypeId
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(mappingId, forKey: Constant.Key.mappingId.rawValue)
        aCoder.encode(logActionTypeId, forKey: Constant.Key.logActionTypeId.rawValue)
        aCoder.encode(logUnitTypeId, forKey: Constant.Key.logUnitTypeId.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var mappingId: Int
    private(set) var logActionTypeId: Int
    private(set) var logUnitTypeId: Int
    
    // MARK: - Initialization
    
    init(
        mappingId: Int,
        logActionTypeId: Int,
        logUnitTypeId: Int
    ) {
        self.mappingId = mappingId
        self.logActionTypeId = logActionTypeId
        self.logUnitTypeId = logUnitTypeId
        super.init()
    }
    
    convenience init?(fromBody: JSONResponseBody) {
        guard
            let mappingIdVal = fromBody[Constant.Key.mappingId.rawValue] as? Int,
            let logActionTypeIdVal = fromBody[Constant.Key.logActionTypeId.rawValue] as? Int,
            let logUnitTypeIdVal = fromBody[Constant.Key.logUnitTypeId.rawValue] as? Int
        else {
            return nil
        }
        
        self.init(
            mappingId: mappingIdVal,
            logActionTypeId: logActionTypeIdVal,
            logUnitTypeId: logUnitTypeIdVal
        )
    }
}
