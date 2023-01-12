//
//  BorderedUITextField.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/30/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class BorderedUITextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        self.layer.borderWidth = VisualConstant.LayerConstant.defaultBorderWidth
        self.layer.borderColor = VisualConstant.LayerConstant.defaultBorderColor
        self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        self.layer.borderWidth = VisualConstant.LayerConstant.defaultBorderWidth
        self.layer.borderColor = VisualConstant.LayerConstant.defaultBorderColor
        self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
    }
}
