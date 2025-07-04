//
//  GenerlViewStyle.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/3/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

struct GeneralViewBorder {
    var borderColor: UIColor
    var borderWidth: Double
    var shouldRoundCorners: Bool
    
    static let thinLabelBorder = GeneralViewBorder(
        borderColor: .label,
        borderWidth: 2,
        shouldRoundCorners: true
    )

    static let labelBorder = GeneralViewBorder(
        borderColor: .label,
        borderWidth: 2,
        shouldRoundCorners: true
    )

    static let thinGrayBorder = GeneralViewBorder(
        borderColor: .systemGray2,
        borderWidth: 1,
        shouldRoundCorners: true
    )
    
    static let greenSelectionBorder = GeneralViewBorder(
        borderColor: .systemGreen,
        borderWidth: 4,
        shouldRoundCorners: true
    )
    
    static let redBorder = GeneralViewBorder(
        borderColor: .systemRed,
        borderWidth: 2,
        shouldRoundCorners: true
    )
}

protocol GeneralBorderStylable: AnyObject {
    var borderColor: UIColor? { get set }
    var borderWidth: Double { get set }
    var shouldRoundCorners: Bool { get set }
}

extension GeneralBorderStylable where Self: UIView {
    func applyStyle(_ style: GeneralViewBorder) {
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shouldRoundCorners = shouldRoundCorners
    }
}

extension GeneralUIButton: GeneralBorderStylable {}
extension GeneralUILabel: GeneralBorderStylable {}
extension GeneralUITextView: GeneralBorderStylable {}
extension GeneralUITextField: GeneralBorderStylable {}
extension GeneralUIView: GeneralBorderStylable {}
extension GeneralUITableView: GeneralBorderStylable {}
