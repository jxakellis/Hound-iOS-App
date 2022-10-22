//
//  BorderedUITextView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/30/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class BorderedUITextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.2
        self.layer.borderColor = UIColor.systemGray2.cgColor
        self.layer.cornerRadius = 5.0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.2
        self.layer.borderColor = UIColor.systemGray2.cgColor
        self.layer.cornerRadius = 5.0
    }
}
