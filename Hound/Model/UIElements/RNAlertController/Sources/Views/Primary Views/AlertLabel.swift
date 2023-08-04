//
//  AlertLabel.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 4/25/19.
//  Copyright © 2019 Rayhan. All rights reserved.
//

import UIKit

class AlertLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        textColor = isDarkInterfaceStyle ? UIColor.white : UIColor.black
        textAlignment = .center
        numberOfLines = 0
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init(text: String, type: AlertLabelType) {
        self.init(frame: .zero)
        self.text = text
        setFont(for: type)
    }

    convenience init(attributedText: NSAttributedString) {
        self.init(frame: .zero)
        self.attributedText = attributedText
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        textColor = isDarkInterfaceStyle ? UIColor.white : UIColor.black
    }

    private func setFont(for type: AlertLabelType) {
        switch type {
        case .title:
            font = UIFont.alertTitleFont
        case .message:
            font = UIFont.alertMessageFont
        }
    }

}
