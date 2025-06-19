//
//  ConstraintConstant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/17/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

let maxScaleFactor = 1.3
let screenWidth = 414.0

enum ConstraintConstant {
    enum Global {
        static let contentInset: CGFloat = 20.0
    }
    enum Header {
        static let labelHeightMultipler: CGFloat = 40.0 / screenWidth
        static let labelMaxHeight: CGFloat = Self.labelHeightMultipler * screenWidth * maxScaleFactor
    }
    enum Button {
        static let circleHeightMultiplier: CGFloat = 100.0 / screenWidth
        static let circleMaxHeight: CGFloat = Self.circleHeightMultiplier * screenWidth * maxScaleFactor
        static let circleInset: CGFloat = 10.0
        
        static let miniCircleHeightMultiplier: CGFloat = Self.circleHeightMultiplier / 2.25
        static let miniCircleMaxHeight: CGFloat = Self.circleMaxHeight / 2.25
        static let miniCircleInset: CGFloat = 5.0
        
        static let screenWideHeightMultiplier: CGFloat = 60.0 / screenWidth
        static let screenWideMaxHeight: CGFloat = Self.screenWideHeightMultiplier * screenWidth * maxScaleFactor
    }
    enum Input {
        static let sectionTitleHeightMultipler: CGFloat = 25.0 / screenWidth
        static let sectionTitleMaxHeight: CGFloat = Self.sectionTitleHeightMultipler * screenWidth * maxScaleFactor
        
        static let intraSectionVerticalSpacing: CGFloat = 10.0
        static let interSectionVerticalSpacing: CGFloat = 45.0
        
        static let heightMultiplier: CGFloat = 45.0 / screenWidth
        static let maxHeight: CGFloat = Self.heightMultiplier * screenWidth * maxScaleFactor
    }
}
