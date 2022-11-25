//
//  ScaledUILabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ScaledUILabel: UILabel {
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adjustsFontSizeToFitWidth = true
        if self.minimumScaleFactor == 0 {
            self.minimumScaleFactor = 0.72
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.adjustsFontSizeToFitWidth = true
        if self.minimumScaleFactor == 0 {
            self.minimumScaleFactor = 0.72
        }
    }
    
}
