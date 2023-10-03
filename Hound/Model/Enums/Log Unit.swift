//
//  Log Unit.swift
//  Hound
//
//  Created by Jonathan Xakellis on 10/2/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/*
 TODO NOW Implementation strategy for log units
 1. create log action function that returns acceptable log units for a given log action
 2. create la function that returns display name for unit given a quantity (e.g. 1 unit, 5 units)
 3. add fields to log data object, create functions to modify values
 4. add a new row to the add log page, which has 2 parts, quantity entry and unit selection
 4a. if we are running low on log page space, change the page to a scrolling one with each field a set size
 5. if user changes log action, and that log action isn't compatible with current units, then set quantity and units to nil
 6. make sure quantity and units are both transmitted to the server when log is converted to a body and receieved when a body is decoded to a log
 7. add logic for custom units just like custom log/reminder type, with separate fields to track value and a specicial localized tracker that suggests custom units that were recently input by the user
 */

enum LogUnit: String, CaseIterable {
    case mg = "mg"
    case g = "g"
    case kg = "kg"
    case oz = "oz"
    case lb = "lb"
    case unit = "unit"
    
    case ml = "ml"
    case l = "l"
    case flOz = "fl oz"
    case cup = "cup"
    
    case count = "count"
    
    case km = "km"
    case mi = "mi"
    
    case min = "min"
    case h = "h"
    
    case occurrence = "occurrence"
    
    case custom = "custom"
}
