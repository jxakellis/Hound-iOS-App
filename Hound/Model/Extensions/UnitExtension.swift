//
//  UnitFoundationExtensions.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/18/25.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension UnitMass {
    /// Returns the Foundation UnitMass for a given symbol string (e.g. "mg", "oz"), or nil if not recognized.
    static func from(symbol: String) -> UnitMass? {
        switch symbol {
        case "kg": return .kilograms
        case "g": return .grams
        case "dg": return .decigrams
        case "cg": return .centigrams
        case "mg": return .milligrams
        case "μg": return .micrograms
        case "ng": return .nanograms
        case "pg": return .picograms
        case "oz": return .ounces
        case "lb": return .pounds
        case "st": return .stones
        case "t": return .metricTons
        case "tn": return .shortTons
        case "ct": return .carats
        case "oz t": return .ouncesTroy
        case "slug": return .slugs
        default: return nil
        }
    }
}

// MARK: - UnitLength Symbol Mapping

extension UnitLength {
    /// Returns the Foundation UnitLength for a given symbol string (e.g. "cm", "ft"), or nil if not recognized.
    static func from(symbol: String) -> UnitLength? {
        switch symbol {
        case "Mm": return .megameters
        case "km": return .kilometers
        case "hm": return .hectometers
        case "dam": return .decameters
        case "m": return .meters
        case "dm": return .decimeters
        case "cm": return .centimeters
        case "mm": return .millimeters
        case "μm": return .micrometers
        case "nm": return .nanometers
        case "pm": return .picometers
        case "in": return .inches
        case "ft": return .feet
        case "yd": return .yards
        case "mi": return .miles
        case "smi": return .scandinavianMiles
        case "ly": return .lightyears
        case "nmi": return .nauticalMiles
        case "fathom": return .fathoms
        case "fur": return .furlongs
        case "au": return .astronomicalUnits
        case "pc": return .parsecs
        default: return nil
        }
    }
}

// MARK: - UnitVolume Symbol Mapping

extension UnitVolume {
    /// Returns the Foundation UnitVolume for a given symbol string (e.g. "L", "gal", "mL"), or nil if not recognized.
    static func from(symbol: String) -> UnitVolume? {
        switch symbol {
        case "ML": return .megaliters
        case "kL": return .kiloliters
        case "L": return .liters
        case "dL": return .deciliters
        case "cL": return .centiliters
        case "mL": return .milliliters
        case "km³": return .cubicKilometers
        case "m³": return .cubicMeters
        case "dm³": return .cubicDecimeters
        case "cm³": return .cubicCentimeters
        case "mm³": return .cubicMillimeters
        case "in³": return .cubicInches
        case "ft³": return .cubicFeet
        case "yd³": return .cubicYards
        case "mi³": return .cubicMiles
        case "ac ft": return .acreFeet
        case "bu": return .bushels
        case "tsp": return .teaspoons
        case "tbsp": return .tablespoons
        case "fl oz": return .fluidOunces
        case "cup": return .cups
        case "pt": return .pints
        case "qt": return .quarts
        case "gal": return .gallons
        case "imp tsp": return .imperialTeaspoons
        case "imp tbsp": return .imperialTablespoons
        case "imp fl oz": return .imperialFluidOunces
        case "imp pt": return .imperialPints
        case "imp qt": return .imperialQuarts
        case "imp gal": return .imperialGallons
        case "mcup": return .metricCups
        default: return nil
        }
    }
}
