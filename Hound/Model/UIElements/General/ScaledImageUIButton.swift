//
//  ScaledImageUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ScaledImageUIButton: GeneralUIButton {
    
    // MARK: - Properties
    
    /// If ScaledImageUIButton has its bounds changed, its image might need its point size re-scaled
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            scaleCurrentImagePointSize()
        }
    }
    
    // MARK: - Main
    
    /// As soon as ScaledImageUIButton is established, its image will need its point size scaled
    override init(frame: CGRect) {
        super.init(frame: frame)
        scaleCurrentImagePointSize()
    }
        
    /// As soon as ScaledImageUIButton is established, its image will need its point size scaled
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        scaleCurrentImagePointSize()
    }
    
    /// As soon as ScaledImageUIButton gets a new image, its image will need its point size scaled
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        scaleCurrentImagePointSize()
    }
    
    // MARK: - Functions
    
    /// If there is a current, symbol image, scales its point size to the smallest dimension of bounds
    private func scaleCurrentImagePointSize() {
        guard let currentImage = currentImage, currentImage.isSymbolImage == true else {
            return
        }
        
        let smallestDimension = bounds.height <= bounds.width ? bounds.height : bounds.width
        super.setImage(currentImage.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension)), for: .normal)
    }
    
}
