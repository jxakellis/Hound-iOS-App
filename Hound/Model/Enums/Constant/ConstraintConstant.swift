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
    enum Header {
        static let labelHeightMultipler: CGFloat = 40.0 / 414.0
        static let labelMaxHeight: CGFloat = 40.0 * 1.5
    }
    enum Button {
        static let circleWidthMultiplier: CGFloat = 100.0 / 414.0
        static let circleMaxWidth: CGFloat = 100.0 * 1.5
        static let circleInset: CGFloat = 10.0
        
        static let screenWideHeightMultiplier: CGFloat = 50.0 / 414.0
        static let screenWideMaxHeight: CGFloat = 50 * 1.5
    }
    enum Input {
        static let sectionTitleHeightMultipler: CGFloat = 25.0 / 414.0
        static let sectionTitleMaxHeight: CGFloat = 25.0 * 1.5
        static let intraSectionVerticalSpacing: CGFloat = 10.0
        static let interSectionVerticalSpacing: CGFloat = 45.0
        static let heightMultiplier: CGFloat = 45.0 / 414.0
        static let maxHeight: CGFloat = 45.0 * 1.5
    }
}
