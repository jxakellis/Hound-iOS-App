//
//  Unit Converter.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogUnitTypeConverter {
    
    /// For a given logUnit and its numberOfLogUnits, converts to the targetSystem. If the targetSystem is .both, then nothing is done as all units are acceptable. Otherwise, converts between imperial and metric. For example: 1 oz -> 28.3495 grams
    static func convert(forLogUnit logUnit: LogUnitType, forNumberOfLogUnits numberOfLogUnits: Double, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnitType, Double) {
        guard targetSystem != .both else {
            // A system that supports both measurement types doesn't need to convert any units
            return (logUnit, numberOfLogUnits)
        }
        
        if logUnit.isUnitMass {
            return convertUnitMass(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitMass(symbol: logUnit.unitSymbol)), toTargetSystem: targetSystem)
        }
        else if logUnit.isUnitVolume {
            return convertUnitVolume(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitVolume(symbol: logUnit.unitSymbol)), toTargetSystem: targetSystem)
        }
        else if logUnit.isUnitLength {
            return convertUnitLength(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitLength(symbol: logUnit.unitSymbol)), toTargetSystem: targetSystem)
        }
        
        // Some units can't be converted, e.g. treats
        return (logUnit, numberOfLogUnits)
    }
    
    /// For a given Measurement<UnitMass>, converts it into the units for the targetSystem. Then selects the highest conversion unit where its value is greater than conversionThreshholdToNextUnit. For example: 4.5 kg is too small, so 450 grams is chosen. 5.5 kg is great enough (> threshhold), so 5.5 kg is chosen.
    private static func convertUnitMass(forMeasurement measurement: Measurement<UnitMass>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnitType, Double) {
        let gt = GlobalTypes.shared else {
            return nil
        }
        let conversionTypes =
        switch targetSystem {
        case .imperial:
            let lbConversion = measurement.converted(to: UnitMass.pounds)
            let ozConversion = measurement.converted(to: UnitMass.ounces)
            if lbConversion.value > 1.0 {
                return (.lb, lbConversion.value)
            }
            else {
                return (.oz, ozConversion.value)
            }
        case .metric, .both:
            // .both should never happen, but if it does, fall through to metric
            let kgConversion = measurement.converted(to: UnitMass.kilograms)
            let gConversion = measurement.converted(to: UnitMass.grams)
            let mgConversion = measurement.converted(to: UnitMass.milligrams)
            
            if kgConversion.value > conversionThreshholdToNextUnit {
                return (.kg, kgConversion.value)
            }
            else if gConversion.value > conversionThreshholdToNextUnit {
                return (.g, gConversion.value)
            }
            else {
                return (.mg, mgConversion.value)
            }
        }
    }
    
    /// For a given Measurement<UnitVolume>, converts it into the units for the targetSystem. Then selects the highest conversion unit where its value is greater than 1.0. For example: 4.5 kg is too small, so 450 grams is chosen. 5.5 kg is great enough (> threshhold), so 5.5 kg is chosen.
    private static func convertUnitVolume(forMeasurement measurement: Measurement<UnitVolume>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnit, Double) {
        switch targetSystem {
        case .imperial:
            let cupsConversion = measurement.converted(to: UnitVolume.cups)
            let flOzConversion = measurement.converted(to: UnitVolume.fluidOunces)
            let tbspConversion = measurement.converted(to: UnitVolume.tablespoons)
            let tspConversion = measurement.converted(to: UnitVolume.teaspoons)
            
            if cupsConversion.value > 1.0 {
                return (.cup, cupsConversion.value)
            }
            else if flOzConversion.value > 1.0 {
                return (.flOz, flOzConversion.value)
            }
            else if tbspConversion.value > 1.0 {
                return (.tbsp, tbspConversion.value)
            }
            else {
                return (.tsp, tspConversion.value)
            }
        case .metric, .both:
            // .both should never happen, but if it does, fall through to metric
            let lConversion = measurement.converted(to: UnitVolume.liters)
            let mlConversion = measurement.converted(to: UnitVolume.milliliters)
            
            if lConversion.value > 1.0 {
                return (.l, lConversion.value)
            }
            else {
                return (.ml, mlConversion.value)
            }
        }
    }
    
    /// For a given Measurement<UnitLength>, converts it into the units for the targetSystem.Then selects the highest conversion unit where its value is greater than conversionThreshholdToNextUnit. For example: 4.5 kg is too small, so 450 grams is chosen. 5.5 kg is great enough (> threshhold), so 5.5 kg is chosen.
    private static func convertUnitLength(forMeasurement measurement: Measurement<UnitLength>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnit, Double) {
        switch targetSystem {
        case .imperial:
            let milesConversion = measurement.converted(to: UnitLength.miles)
            
            return (.mi, milesConversion.value)
        case .metric, .both:
            // .both should never happen, but if it does, fall through to metric
            let kmConversion = measurement.converted(to: UnitLength.kilometers)
            
            return (.km, kmConversion.value)
        }
    }
    
}
