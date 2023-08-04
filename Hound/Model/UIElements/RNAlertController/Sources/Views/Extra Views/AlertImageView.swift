//
//  AlertImageView.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 5/2/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import UIKit

class AlertImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            heightAnchor.constraint(lessThanOrEqualToConstant: 120)
            ]
        )
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init(image: UIImage) {
        self.init(frame: .zero)
        self.image = image
    }

}
