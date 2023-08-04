//
//  UIColor+Extra.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 8/23/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import UIKit

public extension UIColor {

    static var alertButtonTextRegular: UIColor {
        return UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1.0)
    }

    static var alertButtonTextDestructive: UIColor {
        return UIColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1.0)
    }

    static var defaultLightBackground: UIColor {
        return UIColor(white: 1, alpha: 0.75)
    }

    static var defaultDarkBackground: UIColor {
        return UIColor(white: 0, alpha: 0.40)
    }

    static var highlightedLightBackground: UIColor {
        return UIColor(white: 1, alpha: 0.35)
    }

    static var highlightedDarkBackground: UIColor {
        return UIColor(white: 0, alpha: 0.0)
    }

}
