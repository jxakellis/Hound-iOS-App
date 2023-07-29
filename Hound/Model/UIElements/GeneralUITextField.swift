//
//  GeneralUITextField.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/30/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

@IBDesignable final class GeneralUITextField: UITextField {
    
    // MARK: - Properties
    
    /// If true, self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius. Otherwise, self.layer.cornerRadius = 0.
    private var storedShouldRoundCorners: Bool = false
    
    /// If true, self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius. Otherwise, self.layer.cornerRadius = 0.
    @IBInspectable var shouldRoundCorners: Bool {
        get {
            return storedShouldRoundCorners
        }
        set {
            storedShouldRoundCorners = newValue
            self.layer.cornerRadius = newValue ? VisualConstant.LayerConstant.defaultCornerRadius : 0.0
            self.layer.masksToBounds = shouldRoundCorners
            self.layer.cornerCurve = .continuous
        }
    }
    
    @IBInspectable var borderWidth: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    
    private var storedBorderColor: UIColor?
    @IBInspectable var borderColor: UIColor? {
        get {
            return storedBorderColor
        }
        set {
            self.storedBorderColor = newValue
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.layer.borderColor = storedBorderColor?.cgColor
        }
    }
}
