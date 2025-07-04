//
//  LogUnitType.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/1/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogUnitType: NSObject, Comparable, NSCoding {
    
    // MARK: - Comparable
    
    static func < (lhs: LogUnitType, rhs: LogUnitType) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.logUnitTypeId < rhs.logUnitTypeId
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? LogUnitType else {
            return false
        }
        return object.logUnitTypeId == self.logUnitTypeId
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let logUnitTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.logUnitTypeId.rawValue),
            let unitSymbol = aDecoder.decodeOptionalString(forKey: KeyConstant.unitSymbol.rawValue),
            let readableValue = aDecoder.decodeOptionalString(forKey: KeyConstant.readableValue.rawValue),
            let isImperial = aDecoder.decodeOptionalBool(forKey: KeyConstant.isImperial.rawValue),
            let isMetric = aDecoder.decodeOptionalBool(forKey: KeyConstant.isMetric.rawValue),
            let isUnitMass = aDecoder.decodeOptionalBool(forKey: KeyConstant.isUnitMass.rawValue),
            let isUnitVolume = aDecoder.decodeOptionalBool(forKey: KeyConstant.isUnitVolume.rawValue),
            let isUnitLength = aDecoder.decodeOptionalBool(forKey: KeyConstant.isUnitLength.rawValue),
            let sortOrder = aDecoder.decodeOptionalInteger(forKey: KeyConstant.sortOrder.rawValue)
        else {
            return nil
        }
        
        self.init(
            forLogUnitTypeId: logUnitTypeId,
            forUnitSymbol: unitSymbol,
            forReadableValue: readableValue,
            forIsImperial: isImperial,
            forIsMetric: isMetric,
            forIsUnitMass: isUnitMass,
            forIsUnitVolume: isUnitVolume,
            forIsUnitLength: isUnitLength,
            forSortOrder: sortOrder
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(logUnitTypeId, forKey: KeyConstant.logUnitTypeId.rawValue)
        aCoder.encode(unitSymbol, forKey: KeyConstant.unitSymbol.rawValue)
        aCoder.encode(readableValue, forKey: KeyConstant.readableValue.rawValue)
        aCoder.encode(isImperial, forKey: KeyConstant.isImperial.rawValue)
        aCoder.encode(isMetric, forKey: KeyConstant.isMetric.rawValue)
        aCoder.encode(isUnitMass, forKey: KeyConstant.isUnitMass.rawValue)
        aCoder.encode(isUnitVolume, forKey: KeyConstant.isUnitVolume.rawValue)
        aCoder.encode(isUnitLength, forKey: KeyConstant.isUnitLength.rawValue)
        aCoder.encode(sortOrder, forKey: KeyConstant.sortOrder.rawValue)
    }
    
    // MARK: - Properties
    
    private(set) var logUnitTypeId: Int
    private(set) var unitSymbol: String
    private(set) var readableValue: String
    private(set) var isImperial: Bool
    private(set) var isMetric: Bool
    private(set) var isUnitMass: Bool
    private(set) var isUnitVolume: Bool
    private(set) var isUnitLength: Bool
    private(set) var sortOrder: Int
    
    // MARK: - Initialization
    
    init(
        forLogUnitTypeId: Int,
        forUnitSymbol: String,
        forReadableValue: String,
        forIsImperial: Bool,
        forIsMetric: Bool,
        forIsUnitMass: Bool,
        forIsUnitVolume: Bool,
        forIsUnitLength: Bool,
        forSortOrder: Int
    ) {
        self.logUnitTypeId = forLogUnitTypeId
        self.unitSymbol = forUnitSymbol
        self.readableValue = forReadableValue
        self.isImperial = forIsImperial
        self.isMetric = forIsMetric
        self.isUnitMass = forIsUnitMass
        self.isUnitVolume = forIsUnitVolume
        self.isUnitLength = forIsUnitLength
        self.sortOrder = forSortOrder
        super.init()
    }
    
    convenience init?(fromBody: [String: Any?]) {
        guard
            let idVal = fromBody[KeyConstant.logUnitTypeId.rawValue] as? Int,
            let symbolVal = fromBody[KeyConstant.unitSymbol.rawValue] as? String,
            let readableVal = fromBody[KeyConstant.readableValue.rawValue] as? String,
            let isImperialVal = fromBody[KeyConstant.isImperial.rawValue] as? Bool,
            let isMetricVal = fromBody[KeyConstant.isMetric.rawValue] as? Bool,
            let isMassVal = fromBody[KeyConstant.isUnitMass.rawValue] as? Bool,
            let isVolumeVal = fromBody[KeyConstant.isUnitVolume.rawValue] as? Bool,
            let isLengthVal = fromBody[KeyConstant.isUnitLength.rawValue] as? Bool,
            let sortOrderVal = fromBody[KeyConstant.sortOrder.rawValue] as? Int
        else {
            return nil
        }
        
        self.init(
            forLogUnitTypeId: idVal,
            forUnitSymbol: symbolVal,
            forReadableValue: readableVal,
            forIsImperial: isImperialVal,
            forIsMetric: isMetricVal,
            forIsUnitMass: isMassVal,
            forIsUnitVolume: isVolumeVal,
            forIsUnitLength: isLengthVal,
            forSortOrder: sortOrderVal
        )
    }
    
    // MARK: - Functions
    
    static func find(forLogUnitTypeId: Int) -> LogUnitType {
        return GlobalTypes.shared.logUnitTypes.first { $0.logUnitTypeId == forLogUnitTypeId } ?? GlobalTypes.shared.logUnitTypes[0]
    }
    
    /// Produces a logNumberOfLogUnits that is more readable to the user. We accomplish this by rounding the double to two decimal places. Additionally, the decimal separator is varied based on locale (e.g. period in U.S.)
    static func readableRoundedNumUnits(forLogNumberOfLogUnits logNumberOfLogUnits: Double?) -> String? {
        guard let logNumberOfLogUnits = logNumberOfLogUnits, logNumberOfLogUnits >= 0.01 else {
            // If logNumberOfLogUnits isn't greater than 0.01, we have nothing to display, return nil
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: logNumberOfLogUnits as NSNumber)
    }
    
    static func convertStringToDouble(forLogNumberOfLogUnits logNumberOfLogUnits: String?) -> Double? {
        guard let logNumberOfLogUnits = logNumberOfLogUnits else {
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let doubleValue = formatter.number(from: logNumberOfLogUnits)?.doubleValue
        
        // If logNumberOfLogUnits isn't greater than 0.01, we have nothing to display, return nil
        return (doubleValue ?? 0.0) >= 0.01 ? doubleValue : nil
    }
    
    /// Produces a logUnitType that is more readable to the user. We accomplish this by changing the plurality of a log unit if needed : "cup" -> "cups" (changed needed if numberOfUnits != 1); "g" -> "g" (no change needed ever).
    func pluralReadableValueNoNumUnits(forLogNumberOfLogUnits: Double?) -> String? {
        let logNumberOfLogUnits = forLogNumberOfLogUnits ?? 0.0
        
        return (abs(logNumberOfLogUnits - 1.0) < 0.0001) ? self.readableValue : self.readableValue.appending("s")
    }
    
    /// Produces a logUnitType and logNumberOfLogUnits that is more readable to the user. Converts the unit and value of units into the correct system.For example: .cup, 1.5 -> "1.5 cups"; .g, 1.0 -> "1g" Also if the logUnit is in the wrong measurement system, e.g. its grams and the user wants imperial,
    func pluralReadableValueWithNumUnits(forLogNumberOfLogUnits: Double, toTargetSystem: MeasurementSystem = UserConfiguration.measurementSystem) -> String? {
        let (convertedLogUnit, convertedLogNumberOfLogUnits) = LogUnitTypeConverter.convert(forLogUnitType: self, forNumberOfLogUnits: forLogNumberOfLogUnits, toTargetSystem: toTargetSystem)
        
        // Take our raw values and convert them to something more readable
        let pluralReadableValueNoNumUnits = convertedLogUnit.pluralReadableValueNoNumUnits(forLogNumberOfLogUnits: convertedLogNumberOfLogUnits)
        let readableNumUnits = LogUnitType.readableRoundedNumUnits(forLogNumberOfLogUnits: convertedLogNumberOfLogUnits)
        
        guard let pluralReadableValueNoNumUnits = pluralReadableValueNoNumUnits, let readableNumUnits = readableNumUnits else {
            // If we reach this point it likely measure that readableIndividualLogNumberOfLogUnits was < 0.01, which would wouldn't be displayed, so nil was returned
            return nil
        }
        
        return "\(readableNumUnits) \(pluralReadableValueNoNumUnits)"
    }
}
