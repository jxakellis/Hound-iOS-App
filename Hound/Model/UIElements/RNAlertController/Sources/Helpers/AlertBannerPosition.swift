//
//  AlertBannerPosition.swift
//  RNAlertController
//
//  Created by Rayhan on 28/10/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import Foundation

/// Describes banner image positions.
@objc public enum AlertBannerPosition: Int {

    /// Banner image is displayed after title and message.
    ///
    /// - Note: Image contentMode is set to `scaleAspectFit`.
    case afterBody

    /// Banner image is displayed before the title.
    ///
    /// - Note: Image contentMode is set to `scaleAspectFill`.
    case beforeBody
}
