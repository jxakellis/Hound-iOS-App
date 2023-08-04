//
//  AlertCheckboxLabel.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 1/14/20.
//  Copyright © 2020 Rayhan Nabi. All rights reserved.
//

import UIKit

final class AlertCheckboxLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        translatesAutoresizingMaskIntoConstraints = false
        textAlignment = .left
        numberOfLines = 0
        font = .systemFont(ofSize: 14, weight: .semibold)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    convenience init(text: String?) {
        self.init(frame: .zero)
        self.text = text
    }

}
