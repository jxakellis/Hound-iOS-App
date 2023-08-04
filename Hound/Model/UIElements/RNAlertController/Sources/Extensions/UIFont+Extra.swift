//
//  UIFont+Extra.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 4/25/19.
//  Copyright © 2019 Rayhan. All rights reserved.
//

import UIKit

public extension UIFont {

    static var alertTitleFont: UIFont {
        return self.systemFont(ofSize: 18, weight: .semibold)
    }

    static var alertMessageFont: UIFont {
        return self.systemFont(ofSize: 14, weight: .regular)
    }

    static var alertMessageFontBold: UIFont {
        return self.systemFont(ofSize: 14, weight: .bold)
    }

    static var alertMessageFontItalic: UIFont {
        return self.italicSystemFont(ofSize: 14)
    }

    static var alertButtonFontRegular: UIFont {
        return self.systemFont(ofSize: 16, weight: .regular)
    }

    static var alertButtonFontBold: UIFont {
        return self.systemFont(ofSize: 16, weight: .semibold)
    }

}
