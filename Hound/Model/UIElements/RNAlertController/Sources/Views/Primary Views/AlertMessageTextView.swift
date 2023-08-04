//
//  AlertMessageTextView.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 5/12/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import UIKit

class AlertMessageTextView: UITextView {

    convenience init() {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        textAlignment = .center
        setEditableProperties()
        setLinkAttributes()
    }

    func setAttributedTextWithCenterAlignment(_ attributedText: NSAttributedString) {
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        mutableAttributedText.addAttribute(.paragraphStyle,
                                           value: paragraphStyle,
                                           range: NSRange(location: 0, length: attributedText.string.count))
        self.attributedText = mutableAttributedText
    }

    private func setLinkAttributes() {
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.alertButtonTextRegular,
            .underlineColor: UIColor.alertButtonTextRegular,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        linkTextAttributes = linkAttributes
    }

    private func setEditableProperties() {
        isScrollEnabled = false
        isEditable = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        bounces = false
        bouncesZoom = false
        dataDetectorTypes = .all
        delaysContentTouches = false
    }

}
