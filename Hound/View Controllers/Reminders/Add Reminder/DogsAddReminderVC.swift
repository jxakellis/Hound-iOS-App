//
//  DogsAddReminderVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderVCDelegate: AnyObject {
    /// If a dogUUID is provided, then the reminder is added, updated, or deleted on the Hound server,
    /// and both a dogUUID and reminder is returned. If a dogUUID is not returned, the reminder has only
    /// been added, updated, or deleted locally.
    func didAddReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder)
    func didUpdateReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder)
    func didRemoveReminder(sender: Sender, forDogUUID: UUID?, forReminderUUID: UUID)
}

final class DogsAddReminderVC: HoundScrollViewController {
    
    // MARK: - Elements
    
    private lazy var editPageHeaderView: HoundEditPageHeaderView = {
        let view = HoundEditPageHeaderView(huggingPriority: 330, compressionResistancePriority: 330)
        
        view.leadingButton.setImage(UIImage(systemName: "doc.circle"), for: .normal)
        view.leadingButton.isHidden = false
        view.leadingButton.addTarget(self, action: #selector(didTouchUpInsideDuplicateReminder), for: .touchUpInside)
        
        view.trailingButton.setImage(UIImage(systemName: "trash.circle"), for: .normal)
        view.trailingButton.isHidden = false
        view.trailingButton.addTarget(self, action: #selector(didTouchUpInsideRemoveReminder), for: .touchUpInside)
        
        return view
    }()
    
    private let dogsAddReminderManagerView: DogsAddReminderManagerView = {
        let vc = DogsAddReminderManagerView(huggingPriority: 320, compressionResistancePriority: 320)
        return vc
    }()
    
    private lazy var saveReminderButton: HoundButton = {
        let button = HoundButton(huggingPriority: 350, compressionResistancePriority: 350)
        
        button.tintColor = UIColor.systemBlue
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBackground
        
        button.addTarget(self, action: #selector(didTouchUpInsideSaveReminder), for: .touchUpInside)
        
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
    
    private weak var delegate: DogsAddReminderVCDelegate?
    
    private var reminderToUpdate: Reminder?
    private var reminderToUpdateDogUUID: UUID?
    
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
        
        let saveButtonTop = saveReminderButton.convert(saveReminderButton.bounds, to: view).minY
        let backButtonTop = backButton.convert(backButton.bounds, to: view).minY
        let buttonTop = min(saveButtonTop, backButtonTop)
        
        let distanceFromBottom = view.bounds.height - buttonTop
        
        let minInset = distanceFromBottom + Constant.Constraint.Spacing.absoluteVertInset
        
        scrollView.contentInset.bottom = max(scrollView.contentInset.bottom, minInset)
    }
    
    // MARK: - Setup
    
    func setup(
        forDelegate: DogsAddReminderVCDelegate,
        forReminderToUpdateDogUUID: UUID?,
        forReminderToUpdate: Reminder?
    ) {
        self.delegate = forDelegate
        self.reminderToUpdateDogUUID = forReminderToUpdateDogUUID
        self.reminderToUpdate = forReminderToUpdate
        
        if forReminderToUpdate == nil {
            editPageHeaderView.setTitle("Create Reminder")
        }
        else {
            editPageHeaderView.setTitle("Edit Reminder")
        }
        dogsAddReminderManagerView.setup(forReminderToUpdate: forReminderToUpdate)
    }
    
    // MARK: - Functions
    
    @objc private func didTouchUpInsideSaveReminder(_ sender: Any) {
        guard let reminder = dogsAddReminderManagerView.constructReminder(showErrorIfFailed: true) else { return }
        
        // Persist custom action name locally
        LocalConfiguration.addReminderCustomAction(
            forReminderActionType: reminder.reminderActionType,
            forReminderCustomActionName: reminder.reminderCustomActionName
        )
        
        // If there's no dogUUID, notify delegate locally and dismiss
        guard let reminderToUpdateDogUUID = reminderToUpdateDogUUID else {
            if reminderToUpdate == nil {
                delegate?.didAddReminder(
                    sender: Sender(origin: self, localized: self),
                    forDogUUID: nil,
                    forReminder: reminder
                )
            }
            else {
                delegate?.didUpdateReminder(
                    sender: Sender(origin: self, localized: self),
                    forDogUUID: nil,
                    forReminder: reminder
                )
            }
            self.dismiss(animated: true)
            return
        }
        
        // Otherwise, call API to create/update on server
        view.isUserInteractionEnabled = false
        saveReminderButton.isLoading = true
        
        let completionHandler: (ResponseStatus, HoundError?) -> Void = { [weak self] responseStatus, _ in
            guard let self = self else { return }
            view.isUserInteractionEnabled = true
            self.saveReminderButton.isLoading = false
            guard responseStatus != .failureResponse else { return }
            
            if self.reminderToUpdate != nil {
                self.delegate?.didUpdateReminder(
                    sender: Sender(origin: self, localized: self),
                    forDogUUID: reminderToUpdateDogUUID,
                    forReminder: reminder
                )
            }
            else {
                self.delegate?.didAddReminder(
                    sender: Sender(origin: self, localized: self),
                    forDogUUID: reminderToUpdateDogUUID,
                    forReminder: reminder
                )
            }
            self.dismiss(animated: true)
        }
        
        if reminderToUpdate != nil {
            RemindersRequest.update(
                forErrorAlert: .automaticallyAlertOnlyForFailure,
                forDogUUID: reminderToUpdateDogUUID,
                forReminders: [reminder],
                completionHandler: completionHandler
            )
        }
        else {
            RemindersRequest.create(
                forErrorAlert: .automaticallyAlertOnlyForFailure,
                forDogUUID: reminderToUpdateDogUUID,
                forReminders: [reminder],
                completionHandler: completionHandler
            )
        }
    }
    
    @objc private func didTouchUpInsideDuplicateReminder(_ sender: Any) {
        guard let duplicateReminder = dogsAddReminderManagerView.constructReminder(showErrorIfFailed: true)?.duplicate() else { return }
        
        // If no dogUUID, notify delegate locally
        guard let reminderToUpdateDogUUID = reminderToUpdateDogUUID else {
            delegate?.didAddReminder(
                sender: Sender(origin: self, localized: self),
                forDogUUID: nil,
                forReminder: duplicateReminder
            )
            self.dismiss(animated: true)
            return
        }
        
        // Otherwise, call API to create/update on server
        view.isUserInteractionEnabled = false
        saveReminderButton.isLoading = true
        
        RemindersRequest.create(
            forErrorAlert: .automaticallyAlertOnlyForFailure,
            forDogUUID: reminderToUpdateDogUUID,
            forReminders: [duplicateReminder]
        ) { [weak self] responseStatus, _ in
            guard let self = self else { return }
            view.isUserInteractionEnabled = true
            self.saveReminderButton.isLoading = false
            guard responseStatus != .failureResponse else { return }
            
            self.delegate?.didAddReminder(
                sender: Sender(origin: self, localized: self),
                forDogUUID: reminderToUpdateDogUUID,
                forReminder: duplicateReminder
            )
            self.dismiss(animated: true)
        }
    }
    
    @objc private func didTouchUpInsideRemoveReminder(_ sender: Any) {
        guard let reminderToUpdate = reminderToUpdate else { return }
        guard let reminderToUpdateDogUUID = reminderToUpdateDogUUID else {
            delegate?.didRemoveReminder(
                sender: Sender(origin: self, localized: self),
                forDogUUID: nil,
                forReminderUUID: reminderToUpdate.reminderUUID
            )
            self.dismiss(animated: true)
            return
        }
        
        let actionName = dogsAddReminderManagerView
            .selectedReminderAction?
            .convertToReadableName(customActionName: reminderToUpdate.reminderCustomActionName)
            ?? reminderToUpdate.reminderActionType.convertToReadableName(customActionName: reminderToUpdate.reminderCustomActionName)
        
        let alert = UIAlertController(
            title: "Are you sure you want to delete \(actionName)?",
            message: nil,
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            view.isUserInteractionEnabled = false
            
            RemindersRequest.delete(
                forErrorAlert: .automaticallyAlertOnlyForFailure,
                forDogUUID: reminderToUpdateDogUUID,
                forReminderUUIDs: [reminderToUpdate.reminderUUID]
            ) { responseStatus, _ in
                self.view.isUserInteractionEnabled = true
                guard responseStatus != .failureResponse else { return }
                
                self.delegate?.didRemoveReminder(
                    sender: Sender(origin: self, localized: self),
                    forDogUUID: reminderToUpdateDogUUID,
                    forReminderUUID: reminderToUpdate.reminderUUID
                )
                self.dismiss(animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        PresentationManager.enqueueAlert(alert)
    }
    
    @objc private func didTouchUpInsideBack(_ sender: Any) {
        guard dogsAddReminderManagerView.didUpdateInitialValues else {
            self.dismiss(animated: true)
            return
        }
        
        let alert = UIAlertController(
            title: "Are you sure you want to exit?",
            message: nil,
            preferredStyle: .alert
        )
        let exitAction = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(exitAction)
        alert.addAction(cancelAction)
        PresentationManager.enqueueAlert(alert)
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(saveReminderButton)
        view.addSubview(backButton)
        
        containerView.addSubview(editPageHeaderView)
        containerView.addSubview(dogsAddReminderManagerView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // editPageHeaderView
        NSLayoutConstraint.activate([
            editPageHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            editPageHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            editPageHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // dogsAddReminderManagerView
        NSLayoutConstraint.activate([
            dogsAddReminderManagerView.topAnchor.constraint(equalTo: editPageHeaderView.bottomAnchor),
            dogsAddReminderManagerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dogsAddReminderManagerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dogsAddReminderManagerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // saveLogButton
        NSLayoutConstraint.activate([
            saveReminderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset),
            saveReminderButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteCircleHoriInset),
            saveReminderButton.createHeightMultiplier(Constant.Constraint.Button.circleHeightMultiplier, relativeToWidthOf: view),
            saveReminderButton.createMaxHeight(Constant.Constraint.Button.circleMaxHeight),
            saveReminderButton.createSquareAspectRatio()
        ])
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteCircleHoriInset),
            backButton.createHeightMultiplier(Constant.Constraint.Button.circleHeightMultiplier, relativeToWidthOf: view),
            backButton.createMaxHeight(Constant.Constraint.Button.circleMaxHeight),
            backButton.createSquareAspectRatio()
        ])
    }

}
