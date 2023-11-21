//
//  GeneralUITabBarController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUITabBarController: UITabBarController {

    /// If true, upon viewDidAppear and viewDidDisappear, the viewController will add or remove itself from the presentation manager's global presenter stack
    var eligibleForGlobalPresenter: Bool = false {
        didSet {
            if eligibleForGlobalPresenter == false {
                PresentationManager.removeGlobalPresenterFromStack(self)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if eligibleForGlobalPresenter {
            PresentationManager.addGlobalPresenterToStack(self)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if eligibleForGlobalPresenter {
            PresentationManager.removeGlobalPresenterFromStack(self)
        }
    }

}
