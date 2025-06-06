//
//  GeneralUITabBarController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUITabBarController: UITabBarController, GeneralUIProtocol, GeneralUIKitProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - GeneralUIProtocol
    
    internal func setupGeneratedViews() {
        addSubViews()
        setupConstraints()
    }
    
    internal func addSubViews() {
        return
    }
    
    internal func setupConstraints() {
        return
    }
    
    // MARK: - Properties

    /// If true, upon viewIsAppearing and viewDidDisappear, the viewController will add or remove itself from the presentation manager's global presenter stack
    var eligibleForGlobalPresenter: Bool = false {
        didSet {
            if eligibleForGlobalPresenter == false {
                PresentationManager.removeGlobalPresenterFromStack(self)
            }
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGeneratedViews()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
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
