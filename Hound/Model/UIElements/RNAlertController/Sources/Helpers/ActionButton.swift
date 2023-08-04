//
//  ActionButton.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 4/24/19.
//  Copyright © 2019 Rayhan. All rights reserved.
//

import UIKit

class ActionButton: NSObject {

    let text: String
    let action: AlertAction
    let type: AlertButtonType

    init(text: String, type: AlertButtonType, action: @escaping AlertAction) {
        self.text = text
        self.action = action
        self.type = type
    }

}
