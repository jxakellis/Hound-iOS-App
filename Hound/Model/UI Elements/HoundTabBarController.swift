//
//  HoundTabBarController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HoundTabBarController: UITabBarController, HoundUIProtocol, HoundUIKitProtocol {
    
    // MARK: - HoundUIProtocol
    
    var properties: JSONRequestBody = [:]
    
    // MARK: - HoundUIProtocol
    
    private var didSetupGeneratedViews = false
    internal func setupGeneratedViews() {
        guard !didSetupGeneratedViews else {
            HoundLogger.general.warning("SomeHoundView.setupGeneratedViews:\t Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didSetupGeneratedViews = true
        addSubViews()
        setupConstraints()
    }
    
    private var didAddSubViews = false
    internal func addSubViews() {
        guard !didAddSubViews else {
            HoundLogger.general.warning("SomeHoundView.addSubViews:\t Attempting to re-invoke addSubViews for \(String(describing: type(of: self)))")
            return
        }
        didAddSubViews = true
        return
    }
    
    private var didSetupConstraints = false
    internal func setupConstraints() {
        guard !didSetupConstraints else {
            HoundLogger.general.warning("SomeHoundView.setupConstraints:\t Attempting to re-invoke setupConstraints for \(String(describing: type(of: self)))")
            return
        }
        didSetupConstraints = true
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
    
    override func loadView() {
        super.loadView()
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
