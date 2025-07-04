//
//  GenerlViewStyle.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/3/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

struct HoundBorderStyle {
    var borderColor: UIColor
    var borderWidth: Double
    var shouldRoundCorners: Bool
    
    static let thinLabelBorder = HoundBorderStyle(
        borderColor: .label,
        borderWidth: 2,
        shouldRoundCorners: true
    )

    static let labelBorder = HoundBorderStyle(
        borderColor: .label,
        borderWidth: 2,
        shouldRoundCorners: true
    )

    static let thinGrayBorder = HoundBorderStyle(
        borderColor: .systemGray2,
        borderWidth: 1,
        shouldRoundCorners: true
    )
    
    static let greenSelectionBorder = HoundBorderStyle(
        borderColor: .systemGreen,
        borderWidth: 4,
        shouldRoundCorners: true
    )
    
    static let redBorder = HoundBorderStyle(
        borderColor: .systemRed,
        borderWidth: 2,
        shouldRoundCorners: true
    )
}

protocol HoundBorderStylable: AnyObject {
    var borderColor: UIColor? { get set }
    var borderWidth: Double { get set }
    var shouldRoundCorners: Bool { get set }
}

extension HoundBorderStylable where Self: UIView {
    func applyStyle(_ style: HoundBorderStyle) {
        self.borderColor = style.borderColor
        self.borderWidth = style.borderWidth
        self.shouldRoundCorners = style.shouldRoundCorners
    }
}

extension HoundButton: HoundBorderStylable {}
extension HoundLabel: HoundBorderStylable {}
extension HoundTextView: HoundBorderStylable {}
extension HoundTextField: HoundBorderStylable {}
extension HoundView: HoundBorderStylable {}
extension HoundTableView: HoundBorderStylable {}
