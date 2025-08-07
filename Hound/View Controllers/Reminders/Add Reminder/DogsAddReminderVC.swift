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
    func didAddReminder(sender: Sender, dogUUID: UUID?, reminder: Reminder)
    func didUpdateReminder(sender: Sender, dogUUID: UUID?, reminder: Reminder)
    func didRemoveReminder(sender: Sender, dogUUID: UUID?, reminderUUID: UUID)
}

final class DogsAddReminderVC: HoundScrollViewController {
    
    // MARK: - Elements
    
    private lazy var editPageHeaderView: HoundEditPageHeaderView = {
        let view = HoundEditPageHeaderView(huggingPriority: 330, compressionResistancePriority: 330)
        
        view.leadingButton.setImage(UIImage(systemName: "doc.circle"), for: .normal)
        view.leadingButton.addTarget(self, action: #selector(didTouchUpInsideDuplicateReminder), for: .touchUpInside)
        
        view.trailingButton.setImage(UIImage(systemName: "trash.circle"), for: .normal)
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
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        dogsAddReminderManagerView.didTapScreen(sender: sender)
    }
    
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
        delegate: DogsAddReminderVCDelegate,
        reminderToUpdateDogUUID: UUID?,
        reminderToUpdate: Reminder?
    ) {
        self.delegate = delegate
        self.reminderToUpdateDogUUID = reminderToUpdateDogUUID
        self.reminderToUpdate = reminderToUpdate
        
        editPageHeaderView.setTitle(reminderToUpdate == nil ? "Create Reminder" : "Edit Reminder")
        editPageHeaderView.isLeadingButtonEnabled = reminderToUpdate != nil
        editPageHeaderView.isTrailingButtonEnabled = reminderToUpdate != nil
        
        dogsAddReminderManagerView.setup(reminderToUpdate: reminderToUpdate)
    }
    
    // MARK: - Functions
    
    @objc private func didTouchUpInsideSaveReminder(_ sender: Any) {
        guard let reminder = dogsAddReminderManagerView.constructReminder(showErrorIfFailed: true) else { return }
        
        // Persist custom action name locally
        LocalConfiguration.addReminderCustomAction(
            reminderActionType: reminder.reminderActionType,
            reminderCustomActionName: reminder.reminderCustomActionName
        )
        
        // If there's no dogUUID, notify delegate locally and dismiss
        guard let reminderToUpdateDogUUID = reminderToUpdateDogUUID else {
            if reminderToUpdate == nil {
                delegate?.didAddReminder(
                    sender: Sender(source: self, lastLocation: self),
                    dogUUID: nil,
                    reminder: reminder
                )
            }
            else {
                delegate?.didUpdateReminder(
                    sender: Sender(source: self, lastLocation: self),
                    dogUUID: nil,
                    reminder: reminder
                )
            }
            HapticsManager.notification(.success)
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
                    sender: Sender(source: self, lastLocation: self),
                    dogUUID: reminderToUpdateDogUUID,
                    reminder: reminder
                )
            }
            else {
                self.delegate?.didAddReminder(
                    sender: Sender(source: self, lastLocation: self),
                    dogUUID: reminderToUpdateDogUUID,
                    reminder: reminder
                )
            }
            HapticsManager.notification(.success)
            self.dismiss(animated: true)
        }
        
        if reminderToUpdate != nil {
            RemindersRequest.update(
                errorAlert: .automaticallyAlertOnlyForFailure,
                dogUUID: reminderToUpdateDogUUID,
                reminders: [reminder],
                completionHandler: completionHandler
            )
        }
        else {
            RemindersRequest.create(
                errorAlert: .automaticallyAlertOnlyForFailure,
                dogUUID: reminderToUpdateDogUUID,
                reminders: [reminder],
                completionHandler: completionHandler
            )
        }
    }
    
    @objc private func didTouchUpInsideDuplicateReminder(_ sender: Any) {
        guard let duplicateReminder = dogsAddReminderManagerView.constructReminder(showErrorIfFailed: true)?.duplicate() else { return }
        
        // If no dogUUID, notify delegate locally
        guard let reminderToUpdateDogUUID = reminderToUpdateDogUUID else {
            delegate?.didAddReminder(
                sender: Sender(source: self, lastLocation: self),
                dogUUID: nil,
                reminder: duplicateReminder
            )
            HapticsManager.notification(.success)
            self.dismiss(animated: true)
            return
        }
        
        // Otherwise, call API to create/update on server
        view.isUserInteractionEnabled = false
        saveReminderButton.isLoading = true
        
        RemindersRequest.create(
            errorAlert: .automaticallyAlertOnlyForFailure,
            dogUUID: reminderToUpdateDogUUID,
            reminders: [duplicateReminder]
        ) { [weak self] responseStatus, _ in
            guard let self = self else { return }
            view.isUserInteractionEnabled = true
            self.saveReminderButton.isLoading = false
            guard responseStatus != .failureResponse else { return }
            
            self.delegate?.didAddReminder(
                sender: Sender(source: self, lastLocation: self),
                dogUUID: reminderToUpdateDogUUID,
                reminder: duplicateReminder
            )
            HapticsManager.notification(.success)
            self.dismiss(animated: true)
        }
    }
    
    @objc private func didTouchUpInsideRemoveReminder(_ sender: Any) {
        guard let reminderToUpdate = reminderToUpdate else { return }
        guard let reminderToUpdateDogUUID = reminderToUpdateDogUUID else {
            delegate?.didRemoveReminder(
                sender: Sender(source: self, lastLocation: self),
                dogUUID: nil,
                reminderUUID: reminderToUpdate.reminderUUID
            )
            HapticsManager.notification(.warning)
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
                errorAlert: .automaticallyAlertOnlyForFailure,
                dogUUID: reminderToUpdateDogUUID,
                reminderUUIDs: [reminderToUpdate.reminderUUID]
            ) { responseStatus, _ in
                self.view.isUserInteractionEnabled = true
                guard responseStatus != .failureResponse else { return }
                
                self.delegate?.didRemoveReminder(
                    sender: Sender(source: self, lastLocation: self),
                    dogUUID: reminderToUpdateDogUUID,
                    reminderUUID: reminderToUpdate.reminderUUID
                )
                HapticsManager.notification(.warning)
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
        
        presentUnsavedChangesAlert()
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(saveReminderButton)
        view.addSubview(backButton)
        
        containerView.addSubview(editPageHeaderView)
        containerView.addSubview(dogsAddReminderManagerView)
        
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
            saveReminderButton.createHeightMultiplier(Constant.Constraint.Button.largeCircleHeightMultiplier, relativeToWidthOf: view),
            saveReminderButton.createMaxHeight(Constant.Constraint.Button.largeCircleMaxHeight),
            saveReminderButton.createSquareAspectRatio()
        ])
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteCircleHoriInset),
            backButton.createHeightMultiplier(Constant.Constraint.Button.largeCircleHeightMultiplier, relativeToWidthOf: view),
            backButton.createMaxHeight(Constant.Constraint.Button.largeCircleMaxHeight),
            backButton.createSquareAspectRatio()
        ])
    }
    
}
