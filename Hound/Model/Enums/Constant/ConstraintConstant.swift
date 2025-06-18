//
//  ConstraintConstant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/17/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ConstraintConstant {
    enum Global {
        static let contentInset: CGFloat = 20.0
    }
    enum Button {
        static let circleButtonWidthMultiplier: CGFloat = 100.0 / 414.0
        static let circleButtonMaxWidth: CGFloat = 150.0
        static let circleButtonInset: CGFloat = 10.0
    }
    enum Input {
        static let inputHeightMultiplier: CGFloat = 45.0 / 414.0
        static let inputMaxHeight: CGFloat = 90.0
    }
}
