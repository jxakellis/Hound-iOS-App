//
//  ScaledUITextField.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/30/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class ScaledUITextField: UITextField {
    // MARK: Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.adjustsFontSizeToFitWidth = true
    }
}
