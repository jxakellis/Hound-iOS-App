//
//  UIView+Appearance.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 9/27/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import UIKit

public extension UIView {

    var isDarkInterfaceStyle: Bool {
        if #available(iOS 12.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        }
        else {
            return false
        }
    }

}
