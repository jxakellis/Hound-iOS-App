//
//  Unit Converter.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogUnitTypeConverter {
    
    /// For a given logUnitType and its numberOfLogUnits, converts to the targetSystem. If the targetSystem is .both, then nothing is done as all units are acceptable. Otherwise, converts between imperial and metric. For example: 1 oz -> 28.3495 grams
    static func convert(forLogUnitType logUnitType: LogUnitType, forNumberOfLogUnits numberOfLogUnits: Double, toTargetSystem: MeasurementSystem) -> (LogUnitType, Double) {
        
        // If the target system accepts both measurement systems, no conversion is needed
        guard toTargetSystem != .both else {
            return (logUnitType, numberOfLogUnits)
        }
        
        // If the log unit already belongs to the target system, leave it as is
        if (toTargetSystem == .imperial && logUnitType.isImperial) ||
            (toTargetSystem == .metric && logUnitType.isMetric) {
            return (logUnitType, numberOfLogUnits)
        }
        
        if logUnitType.isUnitMass, let unit = UnitMass.from(symbol: logUnitType.unitSymbol) {
            return convertUnitMass(forMeasurement: Measurement(value: numberOfLogUnits, unit: unit), toTargetSystem: toTargetSystem)
        }
        else if logUnitType.isUnitVolume, let unit = UnitVolume.from(symbol: logUnitType.unitSymbol) {
            return convertUnitVolume(forMeasurement: Measurement(value: numberOfLogUnits, unit: unit), toTargetSystem: toTargetSystem)
        }
        else if logUnitType.isUnitLength, let unit = UnitLength.from(symbol: logUnitType.unitSymbol) {
            return convertUnitLength(forMeasurement: Measurement(value: numberOfLogUnits, unit: unit), toTargetSystem: toTargetSystem)
        }
        
        // Some units can't be converted, e.g. treats
        return (logUnitType, numberOfLogUnits)
    }
    
    /// For a given Measurement<UnitVolume>, converts it into the units for the targetSystem. Then selects the highest conversion unit where its value is greater than 1.0. For example: .5 kg is too small, so 500 grams is chosen. 1.0 kg is great enough (> threshhold), so 1.0 kg is chosen.
    private static func convertUnitMass(forMeasurement measurement: Measurement<UnitMass>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnitType, Double) {
        let conversions = GlobalTypes.shared.logUnitTypes.filter { logUnitType in
            return logUnitType.isUnitMass && UnitMass.from(symbol: logUnitType.unitSymbol) != nil
        }
            .filter { logUnitType in
                switch targetSystem {
                case .imperial: return logUnitType.isImperial
                case .metric: return logUnitType.isMetric
                    // .both should never happen, but if it does, fall through to metric
                case .both: return logUnitType.isMetric
                }
            }
            .compactMap { lut in
                let unit = UnitMass.from(symbol: lut.unitSymbol)! // swiftlint:disable:this force_unwrapping
                let converted = measurement.converted(to: unit).value
                return (lut, converted)
            }
        
        // We want to return the conversion with the greatest type and a value above 1.0
        // e.g. if we have 24 oz and 1.5 lbs, we want 1.5 lbs since that is a greater unit, but if 8 oz and 0.5 lbs, then return oz
        
        // Sort ascending by the converted value
        let sortedByValue = conversions.sorted { $0.1 < $1.1 }
        
        // Find all with value > 1.0
        let aboveOne = sortedByValue.filter { $0.1 > 1.0 }
        
        // 4) If any > 1.0, pick the last (largest); otherwise pick the final entry in sorted list
        if let best = aboveOne.first {
            return (best.0, best.1)
        }
        
        let fallback = sortedByValue.first! // swiftlint:disable:this force_unwrapping
        return (fallback.0, fallback.1)
    }
    
    /// For a given Measurement<UnitVolume>, converts it into the units for the targetSystem. Then selects the highest conversion unit where its value is greater than 1.0. For example: .5 kg is too small, so 500 grams is chosen. 1.0 kg is great enough (> threshhold), so 1.0 kg is chosen.
    private static func convertUnitVolume(forMeasurement measurement: Measurement<UnitVolume>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnitType, Double) {
        let conversions = GlobalTypes.shared.logUnitTypes.filter { lut in
            return lut.isUnitVolume && UnitVolume.from(symbol: lut.unitSymbol) != nil
        }
            .filter { logUnitType in
                switch targetSystem {
                case .imperial: return logUnitType.isImperial
                case .metric: return logUnitType.isMetric
                    // .both should never happen, but if it does, fall through to metric
                case .both: return logUnitType.isMetric
                }
            }
            .compactMap { lut in
                let unit = UnitVolume.from(symbol: lut.unitSymbol)! // swiftlint:disable:this force_unwrapping
                let converted = measurement.converted(to: unit).value
                return (lut, converted)
            }
        
        // We want to return the conversion with the greatest type and a value above 1.0
        // e.g. if we have 24 oz and 1.5 lbs, we want 1.5 lbs since that is a greater unit, but if 8 oz and 0.5 lbs, then return oz
        
        // Sort ascending by the converted value
        let sortedByValue = conversions.sorted { $0.1 < $1.1 }
        
        // Find all with value > 1.0
        let aboveOne = sortedByValue.filter { $0.1 > 1.0 }
        
        // 4) If any > 1.0, pick the last (largest); otherwise pick the final entry in sorted list
        if let best = aboveOne.first {
            return (best.0, best.1)
        }
        
        let fallback = sortedByValue.first! // swiftlint:disable:this force_unwrapping
        return (fallback.0, fallback.1)
    }
    
    /// For a given Measurement<UnitVolume>, converts it into the units for the targetSystem. Then selects the highest conversion unit where its value is greater than 1.0. For example: .5 kg is too small, so 500 grams is chosen. 1.0 kg is great enough (> threshhold), so 1.0 kg is chosen.
    private static func convertUnitLength(forMeasurement measurement: Measurement<UnitLength>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnitType, Double) {
        let conversions = GlobalTypes.shared.logUnitTypes.filter { lut in
            return lut.isUnitLength && UnitLength.from(symbol: lut.unitSymbol) != nil
        }
            .filter { logUnitType in
                switch targetSystem {
                case .imperial: return logUnitType.isImperial
                case .metric: return logUnitType.isMetric
                    // .both should never happen, but if it does, fall through to metric
                case .both: return logUnitType.isMetric
                }
            }
            .compactMap { lut in
                let unit = UnitLength.from(symbol: lut.unitSymbol)! // swiftlint:disable:this force_unwrapping
                let converted = measurement.converted(to: unit).value
                return (lut, converted)
            }
        
        // We want to return the conversion with the greatest type and a value above 1.0
        // e.g. if we have 24 oz and 1.5 lbs, we want 1.5 lbs since that is a greater unit, but if 8 oz and 0.5 lbs, then return oz
        
        // Sort ascending by the converted value
        let sortedByValue = conversions.sorted { $0.1 < $1.1 }
        
        // Find all with value > 1.0
        let aboveOne = sortedByValue.filter { $0.1 > 1.0 }
        
        // 4) If any > 1.0, pick the last (largest); otherwise pick the final entry in sorted list
        if let best = aboveOne.first {
            return (best.0, best.1)
        }
        
        let fallback = sortedByValue.first! // swiftlint:disable:this force_unwrapping
        return (fallback.0, fallback.1)
    }
    
}
