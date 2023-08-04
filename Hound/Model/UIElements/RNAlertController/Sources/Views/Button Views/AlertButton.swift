//
//  AlertButton.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 8/23/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import UIKit

class AlertButton: UIButton {

    override open var isHighlighted: Bool {
        didSet {
            setHighlightedColor()
        }
    }

    convenience init() {
        self.init(type: .custom)
        setBackgroundColor()
        setConstraint()
    }

    func setTitle(_ title: String, for type: AlertButtonType) {
        let textAttributes = createAttributes(for: type)
        let attributedTitle = NSAttributedString(string: title, attributes: textAttributes)
        setAttributedTitle(attributedTitle, for: .normal)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setBackgroundColor()
        setHighlightedColor()
    }

    private func createAttributes(for type: AlertButtonType) -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()
        switch type {
        case .cancel:
            attributes[.font] = UIFont.alertButtonFontBold
            attributes[.foregroundColor] = UIColor.alertButtonTextRegular
        case .destructive:
            attributes[.font] = UIFont.alertButtonFontRegular
            attributes[.foregroundColor] = UIColor.alertButtonTextDestructive
        case .default:
            attributes[.font] = UIFont.alertButtonFontRegular
            attributes[.foregroundColor] = UIColor.alertButtonTextRegular
        }
        return attributes
    }

    private func setConstraint() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44)
            ]
        )
    }

    private func setBackgroundColor() {
        backgroundColor = isDarkInterfaceStyle ? UIColor.defaultDarkBackground : UIColor.defaultLightBackground
    }

    private func setHighlightedColor() {
        if isHighlighted {
            backgroundColor = isDarkInterfaceStyle ?
                UIColor.highlightedDarkBackground :
                UIColor.highlightedLightBackground
        }
        else {
            backgroundColor = isDarkInterfaceStyle ?
                UIColor.defaultDarkBackground :
                UIColor.defaultLightBackground
        }
    }

}
