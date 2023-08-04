//
//  AlertButtonType.swift
//  RNAlertController
//
//  Created by Rayhan on 28/10/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import Foundation

/// Describes the appearances of the alert buttons.
@objc public enum AlertButtonType: Int {

    /// Apply the default style to the button.
    case `default` = 0
    /// Apply a style that indicates the action cancels the operation and leaves things unchanged.
    case cancel
    /// Apply a style that indicates the action might change or delete data.
    case destructive
}
