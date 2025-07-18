//
//  HoundViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HoundViewController: UIViewController, HoundUIProtocol, HoundUIKitProtocol, UIGestureRecognizerDelegate {
    
    // MARK: - HoundUIProtocol
    
    var properties: JSONRequestBody = [:]
    
    // MARK: - HoundUIProtocol
    
    private var didSetupGeneratedViews = false
    internal func setupGeneratedViews() {
        guard !didSetupGeneratedViews else {
            HoundLogger.general.warning("SomeHoundView.setupGeneratedViews: Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didSetupGeneratedViews = true
        addSubViews()
        setupConstraints()
    }
    
    private var didAddSubViews = false
    internal func addSubViews() {
        guard !didAddSubViews else {
            HoundLogger.general.warning("SomeHoundView.addSubViews: Attempting to re-invoke addSubViews for \(String(describing: type(of: self)))")
            return
        }
        didAddSubViews = true
        return
    }
    
    private var didSetupConstraints = false
    internal func setupConstraints() {
        guard !didSetupConstraints else {
            HoundLogger.general.warning("SomeHoundView.setupConstraints: Attempting to re-invoke setupConstraints for \(String(describing: type(of: self)))")
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
    
    /// Toggle if the interactive swipe-to-go-back gesture dismisses the view controller.
    /// Defaults to `false` so most views can't be dismissed via a swipe.
    var enableSwipeBackToDismiss: Bool = false {
        didSet { updateSwipeBackGesture() }
    }
    
    private var customSwipeGesture: UIScreenEdgePanGestureRecognizer?
    
    // MARK: - Main
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.systemBackground
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
    
    // MARK: - Functions
    
    private func updateSwipeBackGesture() {
        guard isViewLoaded else { return }
        
        if let popGesture = navigationController?.interactivePopGestureRecognizer {
            popGesture.isEnabled = enableSwipeBackToDismiss
            customSwipeGesture?.isEnabled = false
        }
        else {
            if customSwipeGesture == nil {
                let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(didSwipeBack(_:)))
                gesture.edges = .left
                gesture.delegate = self
                view.addGestureRecognizer(gesture)
                customSwipeGesture = gesture
            }
            customSwipeGesture?.isEnabled = enableSwipeBackToDismiss
        }
    }
    
    @objc private func didSwipeBack(_ sender: UIScreenEdgePanGestureRecognizer) {
        guard sender.state == .recognized else { return }
        if let navController = navigationController {
            navController.popViewController(animated: true)
        }
        else {
            dismiss(animated: true)
        }
    }
    
}
