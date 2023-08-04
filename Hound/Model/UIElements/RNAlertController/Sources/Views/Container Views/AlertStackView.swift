//
//  AlertStackView.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 5/2/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import UIKit

class AlertStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .fill
        distribution = .fill
        spacing = 12
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    convenience init(arrangedSubviews: [UIView]) {
        self.init(frame: .zero)
        arrangedSubviews.forEach {
            self.addArrangedSubview($0)
        }
    }

}
