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
        static let contentHoriInset: CGFloat = 20.0
        static let contentVertInset: CGFloat = 10.0
        
        static let intraContentHoriInset: CGFloat = 7.5
    }
    enum PageHeader {
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
    enum Section {
        static let sectionTitleHeightMultipler: CGFloat = 25.0 / screenWidth
        static let sectionTitleMaxHeight: CGFloat = Self.sectionTitleHeightMultipler * screenWidth * maxScaleFactor
        
        static let intraSectionVertSpacing: CGFloat = 7.5
        static let interSectionVertSpacing: CGFloat = 45.0
        
        static let inputHeightMultiplier: CGFloat = 45.0 / screenWidth
        static let inputMaxHeight: CGFloat = Self.inputHeightMultiplier * screenWidth * maxScaleFactor
    }
}
