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
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
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
    
    override func reloadData() {
        super.reloadData()
        if shouldAutomaticallyAdjustHeight {
            self.invalidateIntrinsicContentSize()
        }
    }
     
     // MARK: - Functions
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.layer.borderColor = storedBorderColor?.cgColor
        }
    }

}
