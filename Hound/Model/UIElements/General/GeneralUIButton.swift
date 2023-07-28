//
//  GeneralUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/19/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUIButton: UIButton {
    
    // MARK: - Properties
    
    /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    private var storedShouldRoundCorners: Bool = false
     /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    @IBInspectable var shouldRoundCorners: Bool {
        get {
            return storedShouldRoundCorners
        }
        set {
            storedShouldRoundCorners = newValue
            self.applyCornerRounding()
        }
    }
    
    /// If true, upon .touchUpInside the button will dismiss the closest parent UIViewController.
    private var storedShouldDismissParentViewController: Bool = false
    /// If true, upon .touchUpInside the button will dismiss the closest parent UIViewController.
    @IBInspectable var shouldDismissParentViewController: Bool {
        get {
            return storedShouldDismissParentViewController
        }
        set {
            storedShouldDismissParentViewController = newValue
            if newValue {
                self.addTarget(self, action: #selector(dismissParentViewController), for: .touchUpInside)
            }
            else {
                self.removeTarget(self, action: #selector(dismissParentViewController), for: .touchUpInside)
            }
        }
    }
    @objc private func dismissParentViewController() {
        self.parentViewController?.dismiss(animated: true)
    }
    
    @IBInspectable var titleLabelTextColor: UIColor? {
        get {
            return self.titleLabel?.textColor
        }
        set {
            self.setTitleColor(newValue, for: .normal)
        }
    }
    
    @IBInspectable var buttonBackgroundColor: UIColor? {
        get {
            return self.backgroundColor
        }
        set {
            self.backgroundColor = newValue
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
    
    /// Used in beginSpinning and endSpinning to track state before spin began
    private var beforeSpinTintColor: UIColor?
    /// Used in beginSpinning and endSpinning to track state before spin began
    private var beforeSpinUserInteractionEnabled: Bool?
    /// Used in beginSpinning and endSpinning to track state before spin began
    private var isSpinning: Bool {
        return beforeSpinTintColor != nil || beforeSpinUserInteractionEnabled != nil
    }
     
     // MARK: - Main
     
     override init(frame: CGRect) {
         super.init(frame: frame)
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
     }
     
     /// Resize corner radius when the bounds change
     override var bounds: CGRect {
         didSet {
             // Make sure to incur didSet of superclass
             super.bounds = bounds
             self.applyCornerRounding()
         }
     }
     
     // MARK: - Functions
      
    func beginSpinning() {
        guard isSpinning == false else {
            return
        }
        
        beforeSpinUserInteractionEnabled = isUserInteractionEnabled
        isUserInteractionEnabled = false
        beforeSpinTintColor = tintColor
        tintColor = UIColor.systemGray2
        
        spin()
        
        func spin() {
            guard isSpinning == true else {
                return
            }
            // begin spin
            UIView.animate(withDuration: 0.43, delay: 0, options: .curveLinear) {
                
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                
            } completion: { _ in
                guard self.isSpinning == true else {
                    return
                }
                // end spin
                UIView.animate(withDuration: 0.43, delay: 0, options: .curveLinear) {
                    
                    self.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
                } completion: { _ in
                    guard self.isSpinning == true else {
                        return
                    }
                    spin()
                }
            }
        }
    }
    
    func endSpinning() {
        guard isSpinning == true else {
            return
        }
        
        transform = .identity
        
        if let beforeSpinTintColor = beforeSpinTintColor {
            tintColor = beforeSpinTintColor
            self.beforeSpinTintColor = nil
        }
        if let beforeSpinUserInteractionEnabled = beforeSpinUserInteractionEnabled {
            isUserInteractionEnabled = beforeSpinUserInteractionEnabled
            self.beforeSpinUserInteractionEnabled = nil
        }
    }
    
    private func applyCornerRounding() {
        self.layer.masksToBounds = shouldRoundCorners
        self.layer.cornerRadius = shouldRoundCorners ? self.bounds.height / 2.0 : 0.0
        self.layer.cornerCurve = .continuous
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.layer.borderColor = storedBorderColor?.cgColor
        }
    }

}
