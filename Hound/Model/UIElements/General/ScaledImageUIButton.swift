//
//  ScaledImageUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ScaledImageUIButton: UIButton {
    
    // MARK: - Properties
    
    private var initalColor: UIColor?
    private var initalIsUserInteractionEnabled: Bool?
    private var isSpinning: Bool {
        return initalColor != nil || initalIsUserInteractionEnabled != nil
    }
    
    /// If ScaledImageUIButton has its bounds changed, its image might need its point size re-scaled
    override var bounds: CGRect {
        didSet {
            scaleImagePointSize()
        }
    }
    
    // MARK: - Main
    
    /// As soon as ScaledImageUIButton is established, its image will need its point size scaled
    override init(frame: CGRect) {
        super.init(frame: frame)
        scaleImagePointSize()
    }
        
    /// As soon as ScaledImageUIButton is established, its image will need its point size scaled
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        scaleImagePointSize()
    }
    
    /// As soon as ScaledImageUIButton gets a new image, its image will need its point size scaled
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        scaleImagePointSize()
    }
    
    // MARK: - Functions
    
    /// If there is a current, symbol image, scales its point size to
    func scaleImagePointSize() {
        guard let currentImage = currentImage, currentImage.isSymbolImage == true else {
            return
        }
        
        let smallestDimension = bounds.height <= bounds.width ? bounds.height : bounds.width
        super.setImage(currentImage.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension)), for: .normal)
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
