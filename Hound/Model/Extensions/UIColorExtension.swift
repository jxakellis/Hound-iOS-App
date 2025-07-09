//
//  UIColorExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIColor {
    static let houndYellow: UIColor = {
        return UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                // Softer, richer yellow for dark backgrounds
                return UIColor(red: 235.0 / 255, green: 205.0 / 255, blue: 15.0 / 255, alpha: 1.0)
            }
            else {
                // Gentle, pastel yellow for light backgrounds
                return UIColor(red: 250.0 / 255, green: 220.0 / 255, blue: 30.0 / 255, alpha: 1.0)
            }
        }
    }()
}
