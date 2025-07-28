//
//  DogsAddTriggerVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddTriggerVCDelegate: AnyObject {
    func didAddTrigger(sender: Sender, forDogUUID: UUID?, forTrigger: Trigger)
    func didUpdateTrigger(sender: Sender, forDogUUID: UUID?, forTrigger: Trigger)
    func didRemoveTrigger(sender: Sender, forDogUUID: UUID?, triggerUUID: UUID)
}

final class DogsAddTriggerVC: HoundScrollViewController {
    
    // MARK: - Elements
    
    private lazy var editPageHeaderView: HoundEditPageHeaderView = {
        let view = HoundEditPageHeaderView(huggingPriority: 330, compressionResistancePriority: 330)
        view.leadingButton.setImage(UIImage(systemName: "doc.circle"), for: .normal)
        view.leadingButton.addTarget(self, action: #selector(didTouchUpInsideDuplicateTrigger), for: .touchUpInside)
        
        view.trailingButton.setImage(UIImage(systemName: "trash.circle"), for: .normal)
        view.trailingButton.addTarget(self, action: #selector(didTouchUpInsideRemoveTrigger), for: .touchUpInside)
        
        return view
    }()
    
    private let managerView: DogsAddTriggerManagerView = {
        let view = DogsAddTriggerManagerView(huggingPriority: 320, compressionResistancePriority: 320)
        return view
    }()
    
    private lazy var saveButton: HoundButton = {
        let button = HoundButton(huggingPriority: 350, compressionResistancePriority: 350)
        button.tintColor = UIColor.systemBlue
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBackground
        button.addTarget(self, action: #selector(didTouchUpInsideSaveTrigger), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: HoundButton = {
        let button = HoundButton(huggingPriority: 340, compressionResistancePriority: 340)
        button.tintColor = UIColor.systemGray2
        button.setImage(UIImage(systemName: "arrow.backward.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBackground
        button.addTarget(self, action: #selector(didTouchUpInsideBack), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddTriggerVCDelegate?
    /// This variable is not solely based upon the existance of self.dog. If it is true, then dog MUST be provided. However, dog can be provided and this can be false (e.g. DogsAddDogVC it editing a dog and opens this menu to add/edit a trigger. It doesn't want server persistence, but it does have a dog set).
    private var shouldPersistChangesToServer: Bool = false
    private var dog: Dog?
    private var triggerToUpdate: Trigger?
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let saveButtonTop = saveButton.convert(saveButton.bounds, to: view).minY
        let backButtonTop = backButton.convert(backButton.bounds, to: view).minY
        let buttonTop = min(saveButtonTop, backButtonTop)
        
        let distanceFromBottom = view.bounds.height - buttonTop
        
        let minInset = distanceFromBottom + Constant.Constraint.Spacing.absoluteVertInset
        
        scrollView.contentInset.bottom = max(scrollView.contentInset.bottom, minInset)
    }
    
    // MARK: - Setup
    
    /// Changes made by this view controller will not be persisted to the server, and will only be used locally. Dog is optional
    func setupWithoutServerPersistence(forDelegate: DogsAddTriggerVCDelegate, forDog: Dog?, forTriggerToUpdate: Trigger?) {
        shouldPersistChangesToServer = false
        commonSetup(forDelegate: forDelegate, forDog: forDog, forTriggerToUpdate: forTriggerToUpdate)
    }
    
    /// Changes made by this view controller will be persisted to the server. Dog is required
    func setupWithServerPersistence(forDelegate: DogsAddTriggerVCDelegate, forDog: Dog, forTriggerToUpdate: Trigger?) {
        shouldPersistChangesToServer = true
        commonSetup(forDelegate: forDelegate, forDog: forDog, forTriggerToUpdate: forTriggerToUpdate)
    }
    
    private func commonSetup(forDelegate: DogsAddTriggerVCDelegate, forDog: Dog?, forTriggerToUpdate: Trigger?) {
        delegate = forDelegate
        dog = forDog
        triggerToUpdate = forTriggerToUpdate
        
        editPageHeaderView.setTitle(forTriggerToUpdate == nil ? "Create Automation" : "Edit Automation")
        editPageHeaderView.isLeadingButtonEnabled = forTriggerToUpdate != nil
        editPageHeaderView.isTrailingButtonEnabled = forTriggerToUpdate != nil
        managerView.setup(forDog: forDog, forTriggerToUpdate: forTriggerToUpdate)
    }
    
    // MARK: - Functions
    
    @objc private func didTouchUpInsideSaveTrigger(_ sender: Any) {
        guard let trigger = managerView.constructTrigger(showErrorIfFailed: true) else { return }
        
        if shouldPersistChangesToServer && dog == nil {
            HoundLogger.general.error("DogsAddTriggerVC.didTouchUpInsideSaveTrigger: Dog must be set when persisting changes to server.")
        }
        
        guard shouldPersistChangesToServer, let dog = dog else {
            if triggerToUpdate == nil {
                delegate?.didAddTrigger(sender: Sender(origin: self, localized: self), forDogUUID: nil, forTrigger: trigger)
            }
            else {
                delegate?.didUpdateTrigger(sender: Sender(origin: self, localized: self), forDogUUID: nil, forTrigger: trigger)
            }
            HapticsManager.notification(.success)
            self.dismiss(animated: true)
            return
        }
        
        // Otherwise, call API to create/update on server
        view.isUserInteractionEnabled = false
        saveButton.isLoading = true
        
        let completion: (ResponseStatus, HoundError?) -> Void = { [weak self] status, _ in
            guard let self = self else { return }
            
            self.view.isUserInteractionEnabled = true
            self.saveButton.isLoading = false
            
            guard status != .failureResponse else { return }
            
            if self.triggerToUpdate != nil {
                self.delegate?.didUpdateTrigger(sender: Sender(origin: self, localized: self), forDogUUID: dog.dogUUID, forTrigger: trigger)
            }
            else {
                self.delegate?.didAddTrigger(sender: Sender(origin: self, localized: self), forDogUUID: dog.dogUUID, forTrigger: trigger)
            }
            
            HapticsManager.notification(.success)
            self.dismiss(animated: true)
        }
        
        if triggerToUpdate != nil {
            TriggersRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forDogTriggers: [trigger], completionHandler: completion)
        }
        else {
            TriggersRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forDogTriggers: [trigger], completionHandler: completion)
        }
    }
    
    @objc private func didTouchUpInsideDuplicateTrigger(_ sender: Any) {
        guard let duplicateTrigger = managerView.constructTrigger(showErrorIfFailed: true)?.copy() as? Trigger else { return }
        
        if shouldPersistChangesToServer && dog == nil {
            HoundLogger.general.error("DogsAddTriggerVC.didTouchUpInsideDuplicateTrigger: Dog must be set when persisting changes to server.")
        }
        
        guard shouldPersistChangesToServer, let dog = dog else {
            delegate?.didAddTrigger(sender: Sender(origin: self, localized: self), forDogUUID: nil, forTrigger: duplicateTrigger)
            HapticsManager.notification(.success)
            self.dismiss(animated: true)
            return
        }
        
        // Otherwise, call API to create/update on server
        view.isUserInteractionEnabled = false
        saveButton.isLoading = true
        
        TriggersRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forDogTriggers: [duplicateTrigger]) { [weak self] status, _ in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            self.saveButton.isLoading = false
            
            guard status != .failureResponse else { return }
            self.delegate?.didAddTrigger(sender: Sender(origin: self, localized: self), forDogUUID: dog.dogUUID, forTrigger: duplicateTrigger)
            HapticsManager.notification(.success)
            self.dismiss(animated: true)
        }
    }
    
    @objc private func didTouchUpInsideRemoveTrigger(_ sender: Any) {
        guard let triggerToUpdate = triggerToUpdate else { return }
        
        if shouldPersistChangesToServer && dog == nil {
            HoundLogger.general.error("DogsAddTriggerVC.didTouchUpInsideRemoveTrigger: Dog must be set when persisting changes to server.")
        }
        
        guard shouldPersistChangesToServer, let dog = dog else {
            delegate?.didRemoveTrigger(sender: Sender(origin: self, localized: self), forDogUUID: nil, triggerUUID: triggerToUpdate.triggerUUID)
            HapticsManager.notification(.warning)
            self.dismiss(animated: true)
            return
        }
        
        let alert = UIAlertController(title: "Are you sure you want to delete this trigger?", message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.view.isUserInteractionEnabled = false
            TriggersRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, triggerUUIDs: [triggerToUpdate.triggerUUID]) { status, _ in
                self.view.isUserInteractionEnabled = true
                guard status != .failureResponse else { return }
                self.delegate?.didRemoveTrigger(sender: Sender(origin: self, localized: self), forDogUUID: dog.dogUUID, triggerUUID: triggerToUpdate.triggerUUID)
                HapticsManager.notification(.warning)
                self.dismiss(animated: true)
            }
        }
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        PresentationManager.enqueueAlert(alert)
    }
    
    @objc private func didTouchUpInsideBack(_ sender: Any) {
        guard managerView.didUpdateInitialValues else {
            self.dismiss(animated: true)
            return
        }
        let alert = UIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
            self.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        PresentationManager.enqueueAlert(alert)
    }
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        managerView.didTapScreen(sender: sender)
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(saveButton)
        view.addSubview(backButton)
        containerView.addSubview(editPageHeaderView)
        containerView.addSubview(managerView)
        
        let didTapScreenGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapScreen(sender:))
        )
        didTapScreenGesture.delegate = self
        didTapScreenGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(didTapScreenGesture)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            editPageHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            editPageHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            editPageHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            managerView.topAnchor.constraint(equalTo: editPageHeaderView.bottomAnchor),
            managerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            managerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            managerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteCircleHoriInset),
            saveButton.createHeightMultiplier(Constant.Constraint.Button.circleHeightMultiplier, relativeToWidthOf: view),
            saveButton.createMaxHeight(Constant.Constraint.Button.circleMaxHeight),
            saveButton.createSquareAspectRatio()
        ])
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteCircleHoriInset),
            backButton.createHeightMultiplier(Constant.Constraint.Button.circleHeightMultiplier, relativeToWidthOf: view),
            backButton.createMaxHeight(Constant.Constraint.Button.circleMaxHeight),
            backButton.createSquareAspectRatio()
        ])
    }
}
