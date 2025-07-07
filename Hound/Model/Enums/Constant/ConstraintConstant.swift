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
    enum Spacing {
        // MARK: Inset of All Content Elements From Bounding View
        static let absoluteHoriInset: CGFloat = 20.0
        static let absoluteVerticalInset: CGFloat = 10.0
        static let absoluteCircleInset: CGFloat = 10.0
        static let absoluteMiniCircleInset: CGFloat = 5.0
        
        // MARK: Spacing Between Content Elements
        static let contentTightIntraHori: CGFloat = 3.75
        static let contentIntraHori: CGFloat = 7.5
        
        static let contentTightIntraVert: CGFloat = 3.75
        static let contentIntraVert: CGFloat = 7.5
        static let contentTallIntraVert: CGFloat = 22.5
        static let contentSectionVert: CGFloat = 45.0
    }
    enum Text {
        // MARK: Header Label & Spacing
        static let headerLabelHeightMultipler: CGFloat = 40.0 / screenWidth
        static let headerLabelMaxHeight: CGFloat = Self.headerLabelHeightMultipler * screenWidth * maxScaleFactor
        
        // MARK: Section Label & Spacing
        static let sectionLabelHeightMultipler: CGFloat = 25.0 / screenWidth
        static let sectionLabelMaxHeight: CGFloat = Self.sectionLabelHeightMultipler * screenWidth * maxScaleFactor
        
        // MARK: Paw With Hands
        static let pawHeightMultiplier: CGFloat = 145.0 / screenWidth
        static let pawMaxHeight: CGFloat = Self.pawHeightMultiplier * screenWidth * maxScaleFactor
    }
    enum Button {
        // MARK: Full Size Circle Button
        static let circleHeightMultiplier: CGFloat = 100.0 / screenWidth
        static let circleMaxHeight: CGFloat = Self.circleHeightMultiplier * screenWidth * maxScaleFactor
        
        // MARK: Mini Circle Button
        static let miniCircleHeightMultiplier: CGFloat = Self.circleHeightMultiplier / 1.8
        static let miniCircleMaxHeight: CGFloat = Self.circleMaxHeight / 1.8
        
        // MARK: Screen Width Circle Button
        static let wideHeightMultiplier: CGFloat = 60.0 / screenWidth
        static let wideMaxHeight: CGFloat = Self.wideHeightMultiplier * screenWidth * maxScaleFactor
        
        // MARK: Chevron Button
        static let chevronAspectRatio: CGFloat = 65.0 / 100.0
    }
    enum Input {
        // MARK: Text Input Field
        static let textFieldHeightMultiplier: CGFloat = 45.0 / screenWidth
        static let textFieldMaxHeight: CGFloat = Self.textFieldHeightMultiplier * screenWidth * maxScaleFactor
        
        // MARK: Text Input Field
        static let textViewHeightMultiplier: CGFloat = 135.0 / screenWidth
        static let textViewMaxHeight: CGFloat = Self.textViewHeightMultiplier * screenWidth * maxScaleFactor
        
        // MARK: Segmented Input Field
        static let segmentedHeightMultiplier: CGFloat = 37.5 / screenWidth
        static let segmentedMaxHeight: CGFloat = Self.segmentedHeightMultiplier * screenWidth * maxScaleFactor
        
        // MARK: Date Picker Field
        static let datePickerHeightMultiplier: CGFloat = 120.0 / screenWidth
        static let datePickerMaxHeight: CGFloat = Self.datePickerHeightMultiplier * screenWidth * maxScaleFactor
        
        static let megaDatePickerHeightMultiplier: CGFloat = datePickerHeightMultiplier * 2.5
        static let megaDatePickerMaxHeight: CGFloat = datePickerMaxHeight * 2.5
    }
}
