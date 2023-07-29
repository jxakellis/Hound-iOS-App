//
//  GeneralUIImageView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUIImageView: UIImageView {

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
    
    /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    private var storedShouldScaleImagePointSize: Bool = false
     /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    @IBInspectable var shouldScaleImagePointSize: Bool {
        get {
            return storedShouldScaleImagePointSize
        }
        set {
            storedShouldScaleImagePointSize = newValue
            self.scaleImagePointSize()
        }
    }
    
     // MARK: - Main
     
     override init(frame: CGRect) {
         super.init(frame: frame)
         if shouldRoundCorners {
             self.applyCornerRounding()
         }
         if shouldScaleImagePointSize {
             self.scaleImagePointSize()
         }
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         if shouldRoundCorners {
             self.applyCornerRounding()
         }
         if shouldScaleImagePointSize {
             self.scaleImagePointSize()
         }
     }
    
    override var image: UIImage? {
        didSet {
            // Make sure to incur didSet of superclass
            super.image = image
            if shouldScaleImagePointSize {
                self.scaleImagePointSize()
            }
        }
    }
     
     /// Resize corner radius when the bounds change
     override var bounds: CGRect {
         didSet {
             // Make sure to incur didSet of superclass
             super.bounds = bounds
             if shouldRoundCorners {
                 self.applyCornerRounding()
             }
             if shouldScaleImagePointSize {
                 self.scaleImagePointSize()
             }
         }
     }
     
     // MARK: - Functions
    
    private func applyCornerRounding() {
        self.layer.masksToBounds = shouldRoundCorners
        self.layer.cornerRadius = shouldRoundCorners ? self.bounds.height / 2.0 : 0.0
        self.layer.cornerCurve = .continuous
    }
    
    /// If there is a current, symbol image, scales its point size to the smallest dimension of bounds
    private func scaleImagePointSize() {
        guard let image = image, image.isSymbolImage == true else {
            return
        }
        
        let smallestDimension = bounds.height <= bounds.width ? bounds.height : bounds.width
        
        super.image = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension))
    }

}
