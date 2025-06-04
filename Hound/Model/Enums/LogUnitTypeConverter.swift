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
        var targetSystem = toTargetSystem
        if targetSystem == .both {
            // .both should never happen, but if it does, fall through to metric
            targetSystem = .metric
        }
        
        if logUnitType.isUnitMass {
            return convertUnitMass(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitMass(symbol: logUnitType.unitSymbol)), toTargetSystem: targetSystem)
        }
        else if logUnitType.isUnitVolume {
            return convertUnitVolume(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitVolume(symbol: logUnitType.unitSymbol)), toTargetSystem: targetSystem)
        }
        else if logUnitType.isUnitLength {
            return convertUnitLength(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitLength(symbol: logUnitType.unitSymbol)), toTargetSystem: targetSystem)
        }
        
        // Some units can't be converted, e.g. treats
        return (logUnitType, numberOfLogUnits)
    }
    
    /// For a given Measurement<UnitVolume>, converts it into the units for the targetSystem. Then selects the highest conversion unit where its value is greater than 1.0. For example: .5 kg is too small, so 500 grams is chosen. 1.0 kg is great enough (> threshhold), so 1.0 kg is chosen.
    private static func convertUnitMass(forMeasurement measurement: Measurement<UnitMass>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnitType, Double) {
        let conversions = GlobalTypes.shared.logUnitTypes.filter { logUnitType in
            return logUnitType.isUnitMass
        }
        .filter { logUnitType in
            switch UserConfiguration.measurementSystem {
            case .imperial: return logUnitType.isImperial
            case .metric: return logUnitType.isMetric
            // .both should never happen, but if it does, fall through to metric
            case .both: return logUnitType.isMetric
            }
        }
        .compactMap { lut in
            let unit = UnitMass(symbol: lut.unitSymbol)
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
        if let best = aboveOne.last {
            return (best.0, best.1)
        }
        
        let fallback = sortedByValue.last! // swiftlint:disable:this force_unwrapping
        return (fallback.0, fallback.1)
    }
    
    /// For a given Measurement<UnitVolume>, converts it into the units for the targetSystem. Then selects the highest conversion unit where its value is greater than 1.0. For example: .5 kg is too small, so 500 grams is chosen. 1.0 kg is great enough (> threshhold), so 1.0 kg is chosen.
    private static func convertUnitVolume(forMeasurement measurement: Measurement<UnitVolume>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnitType, Double) {
        let conversions = GlobalTypes.shared.logUnitTypes.filter { logUnitType in
            return logUnitType.isUnitVolume
        }
        .filter { logUnitType in
            switch UserConfiguration.measurementSystem {
            case .imperial: return logUnitType.isImperial
            case .metric: return logUnitType.isMetric
            // .both should never happen, but if it does, fall through to metric
            case .both: return logUnitType.isMetric
            }
        }
        .compactMap { lut in
            let unit = UnitVolume(symbol: lut.unitSymbol)
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
        if let best = aboveOne.last {
            return (best.0, best.1)
        }
        
        let fallback = sortedByValue.last! // swiftlint:disable:this force_unwrapping
        return (fallback.0, fallback.1)
    }
    
    /// For a given Measurement<UnitVolume>, converts it into the units for the targetSystem. Then selects the highest conversion unit where its value is greater than 1.0. For example: .5 kg is too small, so 500 grams is chosen. 1.0 kg is great enough (> threshhold), so 1.0 kg is chosen.
    private static func convertUnitLength(forMeasurement measurement: Measurement<UnitLength>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnitType, Double) {
        let conversions = GlobalTypes.shared.logUnitTypes.filter { logUnitType in
            return logUnitType.isUnitLength
        }
        .filter { logUnitType in
            switch UserConfiguration.measurementSystem {
            case .imperial: return logUnitType.isImperial
            case .metric: return logUnitType.isMetric
            // .both should never happen, but if it does, fall through to metric
            case .both: return logUnitType.isMetric
            }
        }
        .compactMap { lut in
            let unit = UnitLength(symbol: lut.unitSymbol)
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
        if let best = aboveOne.last {
            return (best.0, best.1)
        }
        
        let fallback = sortedByValue.last! // swiftlint:disable:this force_unwrapping
        return (fallback.0, fallback.1)
    }
    
}
