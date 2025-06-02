//
//  MappingLogActionTypeLogUnitType.swift
//  Hound
//
//  Created by Jonathan Xakellis on 06/01/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class MappingLogActionTypeLogUnitType: NSObject, Comparable {

    // MARK: - Comparable

    static func < (lhs: MappingLogActionTypeLogUnitType, rhs: MappingLogActionTypeLogUnitType) -> Bool {
        return lhs.mappingId < rhs.mappingId
    }

    static func == (lhs: MappingLogActionTypeLogUnitType, rhs: MappingLogActionTypeLogUnitType) -> Bool {
        return lhs.mappingId == rhs.mappingId &&
               lhs.logActionTypeId == rhs.logActionTypeId &&
               lhs.logUnitTypeId == rhs.logUnitTypeId
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
