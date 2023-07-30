//
//  GeneralUITableView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/29/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

@IBDesignable final class GeneralUITableView: UITableView {
    
    @IBInspectable var shouldAutomaticallyAdjustHeight: Bool = false {
        didSet {
            if shouldAutomaticallyAdjustHeight {
                self.invalidateIntrinsicContentSize()
                self.layoutIfNeeded()
            }
        }
    }
    
    /// If true, VisualConstant.LayerConstant.defaultCornerRadius is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    @IBInspectable var shouldRoundCorners: Bool = false {
        didSet {
            self.updateCornerRoundingIfNeeded()
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
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }
    
    // MARK: Override Properties
    
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
            updateCornerRoundingIfNeeded()
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            // Make sure to incur didSet of superclass
            super.isUserInteractionEnabled = isUserInteractionEnabled
            self.alpha = isUserInteractionEnabled ? 1 : 0.5
        }
    }
    
    // MARK: - Main
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        updateCornerRoundingIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateCornerRoundingIfNeeded()
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
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }
    
    // MARK: - Functions
    
    private func updateCornerRoundingIfNeeded() {
        self.layer.masksToBounds = shouldRoundCorners
        self.layer.cornerRadius = shouldRoundCorners ? VisualConstant.LayerConstant.defaultCornerRadius : 0.0
        self.layer.cornerCurve = .continuous
    }
    
}
