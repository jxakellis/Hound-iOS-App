//
//  CustomClasses.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUIAlertController: UIAlertController {
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AlertManager.shared.alertDidComplete()
    }
    
}
