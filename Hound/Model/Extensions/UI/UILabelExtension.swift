//
//  UILabelExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/30/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UILabel {
    func outline(outlineColor: UIColor, insideColor foregroundColor: UIColor, outlineWidth: CGFloat) {
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor: outlineColor,
            NSAttributedString.Key.foregroundColor: foregroundColor,
            NSAttributedString.Key.strokeWidth: outlineWidth,
            NSAttributedString.Key.font: font ?? UIFont.systemFontSize
        ] as [NSAttributedString.Key: Any]
        self.attributedText = NSMutableAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
    }
}
