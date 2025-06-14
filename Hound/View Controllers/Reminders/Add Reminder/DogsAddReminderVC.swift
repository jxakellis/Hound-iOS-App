//
//  DogsAddReminderViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderViewControllerDelegate: AnyObject {
    /// If a dogUUID is provided, then the reminder is added, updated, or deleted on the Hound server,
    /// and both a dogUUID and reminder is returned. If a dogUUID is not returned, the reminder has only
    /// been added, updated, or deleted locally.
    func didAddReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder)
    func didUpdateReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder)
    func didRemoveReminder(sender: Sender, forDogUUID: UUID?, forReminderUUID: UUID)
}

final class DogsAddReminderViewController: GeneralUIViewController {
    
    // MARK: - Elements
    
    private let pageTitleLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.text = "Create Reminder"
        label.font = .systemFont(ofSize: 35)
        label.textColor = .systemBlue
        return label
    }()
    
    private let saveReminderButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 260, compressionResistancePriority: 260)
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        return button
    }()
    
    private let duplicateReminderButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        return button
    }()
    
    private let removeReminderButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 310, compressionResistancePriority: 310)
        
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        return button
    }()
    
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 260, compressionResistancePriority: 260)
        
        button.tintColor = .systemGray2
        button.setImage(UIImage(systemName: "arrow.backward.circle.fill"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        return button
    }()
    
    private let dogsAddDogReminderManagerViewController: DogsAddDogReminderManagerViewController = {
        let vc = DogsAddDogReminderManagerViewController()
        return vc
    }()
    
    /// Container where DogsAddDogReminderManagerViewController will be embedded
    private let containerView: UIView = GeneralUIView()
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderViewControllerDelegate?
    
    private var reminderToUpdate: Reminder?
    private var reminderToUpdateDogUUID: UUID?
    
    /// Use this to track whether initial values changed, so we can confirm before dismissing
    private var didUpdateInitialValues: Bool {
        return dogsAddDogReminderManagerViewController.didUpdateInitialValues
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        // Configure white background, title text, and embedded child VC
        if reminderToUpdate == nil {
            pageTitleLabel.text = "Create Reminder"
            duplicateReminderButton.removeFromSuperview()
            removeReminderButton.removeFromSuperview()
        }
        else {
            pageTitleLabel.text = "Edit Reminder"
        }
        
        dogsAddDogReminderManagerViewController.setup(forReminderToUpdate: self.reminderToUpdate)
    }
    
    // MARK: - Functions
    
    @objc private func didTouchUpInsideSaveReminder(_ sender: Any) {
        guard let reminder = dogsAddDogReminderManagerViewController.currentReminder else {
            return
        }
        
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
        toggleUserInteractionForSaving(isUserInteractionEnabled: false)
        saveReminderButton.beginSpinning()
        
        let completionHandler: (ResponseStatus, HoundError?) -> Void = { [weak self] responseStatus, _ in
            guard let self = self else { return }
            self.toggleUserInteractionForSaving(isUserInteractionEnabled: true)
            self.saveReminderButton.endSpinning()
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
        guard let duplicateReminder = dogsAddDogReminderManagerViewController.currentReminder?.duplicate() else {
            return
        }
        
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
        
        toggleUserInteractionForSaving(isUserInteractionEnabled: false)
        saveReminderButton.beginSpinning()
        
        RemindersRequest.create(
            forErrorAlert: .automaticallyAlertOnlyForFailure,
            forDogUUID: reminderToUpdateDogUUID,
            forReminders: [duplicateReminder]
        ) { [weak self] responseStatus, _ in
            guard let self = self else { return }
            self.toggleUserInteractionForSaving(isUserInteractionEnabled: true)
            self.saveReminderButton.endSpinning()
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
        guard let reminderToUpdate = reminderToUpdate else {
            return
        }
        guard let reminderToUpdateDogUUID = reminderToUpdateDogUUID else {
            delegate?.didRemoveReminder(
                sender: Sender(origin: self, localized: self),
                forDogUUID: nil,
                forReminderUUID: reminderToUpdate.reminderUUID
            )
            self.dismiss(animated: true)
            return
        }
        
        let actionName = dogsAddDogReminderManagerViewController
            .reminderActionTypeSelected?
            .convertToReadableName(customActionName: reminderToUpdate.reminderCustomActionName)
            ?? reminderToUpdate.reminderActionType.convertToReadableName(customActionName: reminderToUpdate.reminderCustomActionName)
        
        let alert = UIAlertController(
            title: "Are you sure you want to delete \(actionName)?",
            message: nil,
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.toggleUserInteractionForSaving(isUserInteractionEnabled: false)
            
            RemindersRequest.delete(
                forErrorAlert: .automaticallyAlertOnlyForFailure,
                forDogUUID: reminderToUpdateDogUUID,
                forReminderUUIDs: [reminderToUpdate.reminderUUID]
            ) { responseStatus, _ in
                self.toggleUserInteractionForSaving(isUserInteractionEnabled: true)
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
        guard didUpdateInitialValues else {
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
    
    /// Enables/disables the bottom buttons during network activity
    private func toggleUserInteractionForSaving(isUserInteractionEnabled: Bool) {
        duplicateReminderButton.isUserInteractionEnabled = isUserInteractionEnabled
        removeReminderButton.isUserInteractionEnabled = isUserInteractionEnabled
        saveReminderButton.isUserInteractionEnabled = isUserInteractionEnabled
        backButton.isUserInteractionEnabled = isUserInteractionEnabled
    }
    
    /// Call this before presenting so that the VC knows which reminder (and dog UUID) to update, if any.
    func setup(
        forDelegate delegate: DogsAddReminderViewControllerDelegate,
        forReminderToUpdateDogUUID dogUUID: UUID?,
        forReminderToUpdate reminder: Reminder?
    ) {
        self.delegate = delegate
        self.reminderToUpdateDogUUID = dogUUID
        self.reminderToUpdate = reminder
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        view.addSubview(containerView)
        view.addSubview(saveReminderButton)
        view.addSubview(backButton)
        view.addSubview(pageTitleLabel)
        view.addSubview(removeReminderButton)
        view.addSubview(duplicateReminderButton)
        
        addChild(dogsAddDogReminderManagerViewController)
        containerView.addSubview(dogsAddDogReminderManagerViewController.view)
        dogsAddDogReminderManagerViewController.didMove(toParent: self)
        
        saveReminderButton.addTarget(self, action: #selector(didTouchUpInsideSaveReminder), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTouchUpInsideBack), for: .touchUpInside)
        removeReminderButton.addTarget(self, action: #selector(didTouchUpInsideRemoveReminder), for: .touchUpInside)
        duplicateReminderButton.addTarget(self, action: #selector(didTouchUpInsideDuplicateReminder), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            // Save button (bottom right)
            saveReminderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveReminderButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            saveReminderButton.widthAnchor.constraint(equalTo: saveReminderButton.heightAnchor, multiplier: 1.0),
            saveReminderButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 100.0 / 414.0),
            saveReminderButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Back button (bottom left)
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1.0),
            backButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 100.0 / 414.0),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Page title (top, centered between duplicate and remove)
            pageTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageTitleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            // Duplicate button (to the left of title)
            duplicateReminderButton.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor),
            duplicateReminderButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            duplicateReminderButton.widthAnchor.constraint(equalTo: duplicateReminderButton.heightAnchor, multiplier: 1.0),
            
            // Remove button (to the right of title)
            removeReminderButton.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor),
            removeReminderButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            removeReminderButton.widthAnchor.constraint(equalTo: removeReminderButton.heightAnchor, multiplier: 1.0),
            
            dogsAddDogReminderManagerViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            dogsAddDogReminderManagerViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dogsAddDogReminderManagerViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dogsAddDogReminderManagerViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Container for embedded manager VC
            containerView.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 15),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
