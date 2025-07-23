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
            let logUnitTypeId = aDecoder.decodeOptionalInteger(forKey: Constant.Key.logUnitTypeId.rawValue),
            let unitSymbol = aDecoder.decodeOptionalString(forKey: Constant.Key.unitSymbol.rawValue),
            let readableValue = aDecoder.decodeOptionalString(forKey: Constant.Key.readableValue.rawValue),
            let isImperial = aDecoder.decodeOptionalBool(forKey: Constant.Key.isImperial.rawValue),
            let isMetric = aDecoder.decodeOptionalBool(forKey: Constant.Key.isMetric.rawValue),
            let isUnitMass = aDecoder.decodeOptionalBool(forKey: Constant.Key.isUnitMass.rawValue),
            let isUnitVolume = aDecoder.decodeOptionalBool(forKey: Constant.Key.isUnitVolume.rawValue),
            let isUnitLength = aDecoder.decodeOptionalBool(forKey: Constant.Key.isUnitLength.rawValue),
            let sortOrder = aDecoder.decodeOptionalInteger(forKey: Constant.Key.sortOrder.rawValue)
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
        
        aCoder.encode(logUnitTypeId, forKey: Constant.Key.logUnitTypeId.rawValue)
        aCoder.encode(unitSymbol, forKey: Constant.Key.unitSymbol.rawValue)
        aCoder.encode(readableValue, forKey: Constant.Key.readableValue.rawValue)
        aCoder.encode(isImperial, forKey: Constant.Key.isImperial.rawValue)
        aCoder.encode(isMetric, forKey: Constant.Key.isMetric.rawValue)
        aCoder.encode(isUnitMass, forKey: Constant.Key.isUnitMass.rawValue)
        aCoder.encode(isUnitVolume, forKey: Constant.Key.isUnitVolume.rawValue)
        aCoder.encode(isUnitLength, forKey: Constant.Key.isUnitLength.rawValue)
        aCoder.encode(sortOrder, forKey: Constant.Key.sortOrder.rawValue)
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
    
    convenience init?(fromBody: JSONResponseBody) {
        guard
            let idVal = fromBody[Constant.Key.logUnitTypeId.rawValue] as? Int,
            let symbolVal = fromBody[Constant.Key.unitSymbol.rawValue] as? String,
            let readableVal = fromBody[Constant.Key.readableValue.rawValue] as? String,
            let isImperialVal = fromBody[Constant.Key.isImperial.rawValue] as? Bool,
            let isMetricVal = fromBody[Constant.Key.isMetric.rawValue] as? Bool,
            let isMassVal = fromBody[Constant.Key.isUnitMass.rawValue] as? Bool,
            let isVolumeVal = fromBody[Constant.Key.isUnitVolume.rawValue] as? Bool,
            let isLengthVal = fromBody[Constant.Key.isUnitLength.rawValue] as? Bool,
            let sortOrderVal = fromBody[Constant.Key.sortOrder.rawValue] as? Int
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
        guard let found = GlobalTypes.shared.logUnitTypes.first(where: { $0.logUnitTypeId == forLogUnitTypeId }) else {
            HoundLogger.general.error("LogUnitType.find: No LogUnitType found for id \(forLogUnitTypeId). Returning default LogUnitType.")
            return GlobalTypes.shared.logUnitTypes[0]
        }
        return found
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
