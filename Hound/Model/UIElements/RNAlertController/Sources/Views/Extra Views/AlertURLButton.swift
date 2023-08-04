//
//  AlertURLButton.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 5/21/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import UIKit

class AlertURLButton: UIButton {

    convenience init(_ alertURL: AlertURL) {
        self.init(type: .system)
        guard let url = alertURL.url else { return }
        let urlText = alertURL.text == nil ? url.absoluteString : alertURL.text
        setTitle(urlText, for: .normal)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        addAction(for: .touchUpInside) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(url)
            }
        }
    }

}
