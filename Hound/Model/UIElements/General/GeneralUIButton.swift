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
    
    /// Used in beginSpinning and endSpinning to track state before spin began
    private var initalColor: UIColor?
    /// Used in beginSpinning and endSpinning to track state before spin began
    private var initalIsUserInteractionEnabled: Bool?
    /// Used in beginSpinning and endSpinning to track state before spin began
    private var isSpinning: Bool {
        return initalColor != nil || initalIsUserInteractionEnabled != nil
    }
    
    /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    private var storedShouldRoundCorners: Bool = false
     /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    var shouldRoundCorners: Bool {
        get {
            return storedShouldRoundCorners
        }
        set (newShouldRoundCorners) {
            storedShouldRoundCorners = newShouldRoundCorners
            self.applyCornerRounding()
        }
    }
     
     // MARK: - Main
     
     override init(frame: CGRect) {
         super.init(frame: frame)
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
     }
     
     /// Resize corner radius when the SemiboldUIButton bounds change
     override var bounds: CGRect {
         didSet {
             // Make sure to incur didSet of superclass
             super.bounds = bounds
             self.applyCornerRounding()
         }
     }
     
     // MARK: - Functions
     
    private func applyCornerRounding() {
        self.layer.masksToBounds = shouldRoundCorners ? VisualConstant.LayerConstant.defaultMasksToBounds : false
        self.layer.cornerRadius = shouldRoundCorners ? self.bounds.height / 2.0 : 0.0
    }
    
    func beginSpinning() {
        guard isSpinning == false else {
            return
        }
        
        initalIsUserInteractionEnabled = isUserInteractionEnabled
        isUserInteractionEnabled = false
        initalColor = tintColor
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
        
        if let initalColor = initalColor {
            tintColor = initalColor
            self.initalColor = nil
        }
        if let initalIsUserInteractionEnabled = initalIsUserInteractionEnabled {
            isUserInteractionEnabled = initalIsUserInteractionEnabled
            self.initalIsUserInteractionEnabled = nil
        }
    }

}
