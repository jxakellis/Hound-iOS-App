//
//  BorderedUITextView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/30/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class BorderedUITextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
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
