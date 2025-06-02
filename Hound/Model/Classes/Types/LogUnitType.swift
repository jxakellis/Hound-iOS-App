//
//  LogUnitType.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/1/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogUnitType: NSObject, Comparable {

    // MARK: - Comparable

    static func < (lhs: LogUnitType, rhs: LogUnitType) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.logUnitTypeId < rhs.logUnitTypeId
    }

    static func == (lhs: LogUnitType, rhs: LogUnitType) -> Bool {
        return lhs.logUnitTypeId == rhs.logUnitTypeId &&
               lhs.unitSymbol == rhs.unitSymbol &&
               lhs.readableValue == rhs.readableValue &&
               lhs.isImperial == rhs.isImperial &&
               lhs.isMetric == rhs.isMetric &&
               lhs.isUnitMass == rhs.isUnitMass &&
               lhs.isUnitVolume == rhs.isUnitVolume &&
               lhs.isUnitLength == rhs.isUnitLength &&
               lhs.sortOrder == rhs.sortOrder
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

    convenience init?(fromLogUnitTypeBody: [String: Any?]) {
        guard
            let idVal = fromLogUnitTypeBody[KeyConstant.logUnitTypeId.rawValue] as? Int,
            let symbolVal = fromLogUnitTypeBody[KeyConstant.unitSymbol.rawValue] as? String,
            let readableVal = fromLogUnitTypeBody[KeyConstant.readableValue.rawValue] as? String,
            let isImperialVal = fromLogUnitTypeBody[KeyConstant.isImperial.rawValue] as? Bool,
            let isMetricVal = fromLogUnitTypeBody[KeyConstant.isMetric.rawValue] as? Bool,
            let isMassVal = fromLogUnitTypeBody[KeyConstant.isUnitMass.rawValue] as? Bool,
            let isVolumeVal = fromLogUnitTypeBody[KeyConstant.isUnitVolume.rawValue] as? Bool,
            let isLengthVal = fromLogUnitTypeBody[KeyConstant.isUnitLength.rawValue] as? Bool,
            let sortOrderVal = fromLogUnitTypeBody[KeyConstant.sortOrder.rawValue] as? Int
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
    
    static func find(forLogUnitTypeId: Int) -> LogUnitType? {
        return GlobalTypes.shared!.logUnitTypes.first { $0.logUnitTypeId == forLogUnitTypeId }
    }
    
    /// Produces a logNumberOfLogUnits that is more readable to the user. We accomplish this by rounding the double to two decimal places. Additionally, the decimal separator is varied based on locale (e.g. period in U.S.)
    static func convertDoubleToRoundedString(forLogNumberOfLogUnits logNumberOfLogUnits: Double?) -> String? {
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
    
    /// Produces a logUnit that is more readable to the user. We accomplish this by changing the plurality of a log unit if needed : "cup" -> "cups" (changed needed if numberOfUnits != 1); "g" -> "g" (no change needed ever).
    func convertDoubleToPluralityString(forLogNumberOfLogUnits: Double?) -> String? {
        let logNumberOfLogUnits = forLogNumberOfLogUnits ?? 0.0
        
        return (abs(logNumberOfLogUnits - 1.0) < 0.0001) ? self.readableValue : self.readableValue.appending("s")
    }
    
    /// Produces a logUnit and logNumberOfLogUnits that is more readable to the user. Converts the unit and value of units into the correct system.For example: .cup, 1.5 -> "1.5 cups"; .g, 1.0 -> "1g"
    func convertedMeasurementString(forLogNumberOfLogUnits: Double, toTargetSystem: MeasurementSystem) -> String? {
        let (convertedLogUnit, convertedLogNumberOfLogUnits) = LogUnitTypeConverter.convert(forLogUnit: self, forNumberOfLogUnits: forLogNumberOfLogUnits, toTargetSystem: toTargetSystem)

        // Take our raw values and convert them to something more readable
        let convertDoubleToPluralityString = convertedLogUnit.convertDoubleToPluralityString(forLogNumberOfLogUnits: convertedLogNumberOfLogUnits)
        let readableIndividualLogNumberOfLogUnits = LogUnitType.convertDoubleToRoundedString(forLogNumberOfLogUnits: convertedLogNumberOfLogUnits)
        
        guard let convertDoubleToPluralityString = convertDoubleToPluralityString, let readableIndividualLogNumberOfLogUnits = readableIndividualLogNumberOfLogUnits else {
            // If we reach this point it likely measure that readableIndividualLogNumberOfLogUnits was < 0.01, which would wouldn't be displayed, so nil was returned
            return nil
        }
        
        return "\(readableIndividualLogNumberOfLogUnits) \(convertDoubleToPluralityString)"
    }
}
