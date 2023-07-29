//
//  GeneralUITableView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/29/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

@IBDesignable final class GeneralUITableView: UITableView {
    
    private var storedShouldAutomaticallyAdjustHeight: Bool = false
    @IBInspectable var shouldAutomaticallyAdjustHeight: Bool {
        get {
            return storedShouldAutomaticallyAdjustHeight
        }
        set {
            self.storedShouldAutomaticallyAdjustHeight = newValue
            
        }
    }
    
    /// If true, VisualConstant.LayerConstant.defaultCornerRadius is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    private var storedShouldRoundCorners: Bool = false
     /// If true, VisualConstant.LayerConstant.defaultCornerRadius is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    @IBInspectable var shouldRoundCorners: Bool {
        get {
            return storedShouldRoundCorners
        }
        set {
            storedShouldRoundCorners = newValue
            self.applyCornerRounding()
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
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        if shouldRoundCorners {
            self.applyCornerRounding()
        }
    }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         if shouldRoundCorners {
             self.applyCornerRounding()
         }
     }
    
    override func reloadData() {
        super.reloadData()
        if shouldAutomaticallyAdjustHeight {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.layer.borderColor = storedBorderColor?.cgColor
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if shouldAutomaticallyAdjustHeight {
            self.layoutIfNeeded()
        }
        return self.contentSize
    }
    
    override var contentSize: CGSize {
        didSet {
            // Make sure to incur didSet of superclass
            super.contentSize = contentSize
            if shouldAutomaticallyAdjustHeight {
                self.invalidateIntrinsicContentSize()
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            if shouldRoundCorners {
                self.applyCornerRounding()
            }
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            // Make sure to incur didSet of superclass
            super.isUserInteractionEnabled = isUserInteractionEnabled
            self.alpha = isUserInteractionEnabled ? 1 : 0.5
        }
    }
    
    // MARK: - Functions
    
    private func applyCornerRounding() {
        self.layer.masksToBounds = shouldRoundCorners
        self.layer.cornerRadius = shouldRoundCorners ? VisualConstant.LayerConstant.defaultCornerRadius : 0.0
        self.layer.cornerCurve = .continuous
    }

}
