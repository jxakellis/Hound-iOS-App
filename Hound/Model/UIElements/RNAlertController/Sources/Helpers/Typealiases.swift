//
//  Typealiases.swift
//  RNAlertController
//
//  Created by Rayhan on 28/10/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import Foundation

/// Action block to perform when a button is pressed.
public typealias AlertAction = () -> Void

/// Action block when a picker item is selected.
public typealias AlertPickerAction = (AlertPickerRow) -> Void

/// Action block to perform when a date is selected.
public typealias AlertDatePickerAction = (Date) -> Void

/// Action block to perform when checkbox is selected or deselected
public typealias AlertCheckboxAction = (Bool) -> Void
