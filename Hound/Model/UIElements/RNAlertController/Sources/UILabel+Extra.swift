//
//  UILabel+Extra.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 5/8/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import UIKit

extension UILabel {

    var isTruncated: Bool? {
        guard let labelText = text else { return nil}
        let labelTextSize = (labelText as NSString)
            .boundingRect(with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
                          options: .usesLineFragmentOrigin,
                          attributes: [.font: font!],
                          context: nil).size
        return labelTextSize.height > bounds.size.height
    }

}
