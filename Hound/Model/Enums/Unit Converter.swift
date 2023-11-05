//
//  Unit Converter.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum UnitConverter {
    
    /// The threshold at which that many multiples of a smaller unit should be converted to a larger unit. For example unitB = 5unitA. If we had 45 unitA, that is only 9 unitB, so we don't convert. If we had 55 unitA, that is 11 unitB, so we convert.
    private static let conversionThreshholdToNextUnit: Double = 5.0
    
    /// For a given logUnit and its numberOfLogUnits, converts to the targetSystem. If the targetSystem is .both, then nothing is done as all units are acceptable. Otherwise, converts between imperial and metric. For example: 1 oz -> 28.3495 grams
    static func convert(forLogUnit logUnit: LogUnit, forNumberOfLogUnits numberOfLogUnits: Double, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnit, Double)? {
        guard targetSystem != .both else {
            // A system that supports both measurement types doesn't need to convert any units
            return (logUnit, numberOfLogUnits)
        }
        
        switch logUnit {
        case .mg:
            return convertUnitMass(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitMass.milligrams), toTargetSystem: targetSystem)
        case .g:
            return convertUnitMass(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitMass.grams), toTargetSystem: targetSystem)
        case .oz:
            return convertUnitMass(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitMass.ounces), toTargetSystem: targetSystem)
        case .lb:
            return convertUnitMass(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitMass.pounds), toTargetSystem: targetSystem)
        case .kg:
            return convertUnitMass(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitMass.kilograms), toTargetSystem: targetSystem)
        case .ml:
            return convertUnitVolume(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitVolume.milliliters), toTargetSystem: targetSystem)
        case .tsp:
            return convertUnitVolume(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitVolume.teaspoons), toTargetSystem: targetSystem)
        case .tbsp:
            return convertUnitVolume(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitVolume.tablespoons), toTargetSystem: targetSystem)
        case .flOz:
            return convertUnitVolume(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitVolume.fluidOunces), toTargetSystem: targetSystem)
        case .cup:
            return convertUnitVolume(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitVolume.cups), toTargetSystem: targetSystem)
        case .l:
            return convertUnitVolume(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitVolume.liters), toTargetSystem: targetSystem)
        case .km:
            return convertUnitLength(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitLength.kilometers), toTargetSystem: targetSystem)
        case .mi:
            return convertUnitLength(forMeasurement: Measurement(value: numberOfLogUnits, unit: UnitLength.miles), toTargetSystem: targetSystem)
        default:
            // Some units can't be converted, e.g. treats
            return (logUnit, numberOfLogUnits)
        }
    }
    
    /// For a given Measurement<UnitMass>, converts it into the units for the targetSystem. Then selects the highest conversion unit where its value is greater than conversionThreshholdToNextUnit. For example: 4.5 kg is too small, so 450 grams is chosen. 5.5 kg is great enough (> threshhold), so 5.5 kg is chosen.
    private static func convertUnitMass(forMeasurement measurement: Measurement<UnitMass>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnit, Double)? {
        switch targetSystem {
        case .imperial:
            let lbConversion = measurement.converted(to: UnitMass.pounds)
            let ozConversion = measurement.converted(to: UnitMass.ounces)
            if lbConversion.value > conversionThreshholdToNextUnit {
                return (.lb, lbConversion.value)
            }
            else {
                return (.oz, ozConversion.value)
            }
        case .metric:
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
        case .both:
            return nil
        }
    }
    
    /// For a given Measurement<UnitVolume>, converts it into the units for the targetSystem. Then selects the highest conversion unit where its value is greater than conversionThreshholdToNextUnit. For example: 4.5 kg is too small, so 450 grams is chosen. 5.5 kg is great enough (> threshhold), so 5.5 kg is chosen.
    private static func convertUnitVolume(forMeasurement measurement: Measurement<UnitVolume>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnit, Double)? {
        switch targetSystem {
        case .imperial:
            let cupsConversion = measurement.converted(to: UnitVolume.cups)
            let flOzConversion = measurement.converted(to: UnitVolume.fluidOunces)
            let tbspConversion = measurement.converted(to: UnitVolume.tablespoons)
            let tspConversion = measurement.converted(to: UnitVolume.teaspoons)
            
            if cupsConversion.value > conversionThreshholdToNextUnit {
                return (.cup, cupsConversion.value)
            }
            else if flOzConversion.value > conversionThreshholdToNextUnit {
                return (.flOz, flOzConversion.value)
            }
            else if tbspConversion.value > conversionThreshholdToNextUnit {
                return (.tbsp, tbspConversion.value)
            }
            else {
                return (.tsp, tspConversion.value)
            }
        case .metric:
            let lConversion = measurement.converted(to: UnitVolume.liters)
            let mlConversion = measurement.converted(to: UnitVolume.milliliters)
            
            if lConversion.value > conversionThreshholdToNextUnit {
                return (.l, lConversion.value)
            }
            else {
                return (.ml, mlConversion.value)
            }
        case .both:
            return nil
        }
    }
    
    /// For a given Measurement<UnitLength>, converts it into the units for the targetSystem.Then selects the highest conversion unit where its value is greater than conversionThreshholdToNextUnit. For example: 4.5 kg is too small, so 450 grams is chosen. 5.5 kg is great enough (> threshhold), so 5.5 kg is chosen.
    private static func convertUnitLength(forMeasurement measurement: Measurement<UnitLength>, toTargetSystem targetSystem: MeasurementSystem) -> (LogUnit, Double)? {
        switch targetSystem {
        case .imperial:
            let milesConversion = measurement.converted(to: UnitLength.miles)
            
            return (.mi, milesConversion.value)
        case .metric:
            let kmConversion = measurement.converted(to: UnitLength.kilometers)
            
            return (.km, kmConversion.value)
        case .both:
            return nil
        }
    }
    
}
