//
//  AlertActionWrapper.swift
//  RNAlertController
//
//  Created by Rayhan on 28/10/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import Foundation

@objc class AlertActionWrapper: NSObject {

    let alertAction: AlertAction

    init(_ action: @escaping AlertAction) {
        alertAction = action
        super.init()
    }

    @objc func invoke() {
        alertAction()
    }

}
