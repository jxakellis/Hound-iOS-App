//
//  GeneralLayoutConstraint.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class GeneralLayoutConstraint: NSLayoutConstraint {
    
    // MARK: - Properties
    
    /// The value of constant before scaleFactor was applied. By default, this value is 0.0.
    private var originalConstant: CGFloat = 0.0
    
    /// The factor that constant is multiplied by. By default, this value is 1.0, so the transformation does nothing
    var scaleFactor: CGFloat = 1.0 {
        didSet {
            self.constant = originalConstant
        }
    }
    
    override var constant: CGFloat {
        get {
            return super.constant
        }
        set {
            originalConstant = newValue
            
            super.constant = newValue * (scaleFactor)
        }
    }
    
}
