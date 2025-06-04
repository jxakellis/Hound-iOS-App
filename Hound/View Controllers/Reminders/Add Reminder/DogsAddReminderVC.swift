//
//  DogsAddReminderViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderViewControllerDelegate: AnyObject {
    /// If a dogUUID is provided, then the reminder is added, updated, or deleted on the Hound server, and both a dogUUID and reminder is returned. If a dogUUID is not returned, the reminder has only been added, updated, or deleted locally.
    func didAddReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder)
    /// If a dogUUID is provided, then the reminder is added, updated, or deleted on the Hound server, and both a dogUUID and reminder is returned. If a dogUUID is not returned, the reminder has only been added, updated, or deleted locally.
    func didUpdateReminder(sender: Sender, forDogUUID: UUID?, forReminder: Reminder)
    /// If a dogUUID is provided, then the reminder is added, updated, or deleted on the Hound server, and both a dogUUID and reminder is returned. If a dogUUID is not returned, the reminder has only been added, updated, or deleted locally.
    func didRemoveReminder(sender: Sender, forDogUUID: UUID?, forReminderUUID: UUID)
}

final class DogsAddReminderViewController: GeneralUIViewController {
    // TODO RT make the new trash icon for reminders page universal to the dogs, logs, and triggers pages
    // MARK: - IB

    @IBOutlet private weak var pageTitleLabel: GeneralUILabel!

    @IBOutlet private weak var saveReminderButton: GeneralWithBackgroundUIButton!
    /// Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder to DogsViewController
    @IBAction private func didTouchUpInsideSaveReminder(_ sender: Any) {
        guard let reminder = dogsAddDogReminderManagerViewController?.currentReminder else {
            return
        }

        // If we successfully constructed the reminder, add its reminder custom action name to LocalConfiguration
        LocalConfiguration.addReminderCustomAction(forReminderActionType: reminder.reminderActionType, forReminderCustomActionName: reminder.reminderCustomActionName)

        guard let reminderToUpdateDogUUID = reminderToUpdateDogUUID else {
            // If there is no reminderToUpdateDogUUID, then we don't contact the hound server
            if reminderToUpdate == nil {
                delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: nil, forReminder: reminder)
                self.dismiss(animated: true)
            }
            else {
                delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogUUID: nil, forReminder: reminder)
                self.dismiss(animated: true)
            }

            return
        }

        toggleUserInteractionForSaving(isUserInteractionEnabled: false)
        saveReminderButton.beginSpinning()

        if reminderToUpdate != nil {
            RemindersRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: reminderToUpdateDogUUID, forReminders: [reminder]) { responseStatus, _ in
                
                self.toggleUserInteractionForSaving(isUserInteractionEnabled: true)
                self.saveReminderButton.endSpinning()
                
                guard responseStatus != .failureResponse else {
                    return
                }

                self.delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogUUID: reminderToUpdateDogUUID, forReminder: reminder)
                self.dismiss(animated: true)
            }
        }
        else {
            RemindersRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: reminderToUpdateDogUUID, forReminders: [reminder]) { responseStatus, _  in
                
                self.toggleUserInteractionForSaving(isUserInteractionEnabled: true)
                self.saveReminderButton.endSpinning()
                
                guard responseStatus != .failureResponse else {
                    return
                }

                self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: reminderToUpdateDogUUID, forReminder: reminder)
                self.dismiss(animated: true)
            }
        }

    }
    
    @IBOutlet private weak var duplicateReminderButton: GeneralWithBackgroundUIButton!
    /// Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder to DogsViewController
    @IBAction private func didTouchUpInsideDuplicateReminder(_ sender: Any) {
        guard let duplicateReminder = dogsAddDogReminderManagerViewController?.currentReminder?.duplicate() else {
            return
        }
        
        guard let reminderToUpdateDogUUID = reminderToUpdateDogUUID else {
            // If there is no reminderToUpdateDogUUID, then we don't contact the hound server
            delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: nil, forReminder: duplicateReminder)
            self.dismiss(animated: true)
            return
        }

        toggleUserInteractionForSaving(isUserInteractionEnabled: false)
        saveReminderButton.beginSpinning()

        RemindersRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: reminderToUpdateDogUUID, forReminders: [duplicateReminder]) { responseStatus, _  in
            
            self.toggleUserInteractionForSaving(isUserInteractionEnabled: true)
            self.saveReminderButton.endSpinning()
            
            guard responseStatus != .failureResponse else {
                return
            }

            self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogUUID: reminderToUpdateDogUUID, forReminder: duplicateReminder)
            self.dismiss(animated: true)
        }

    }

    @IBOutlet private weak var removeReminderButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideRemoveReminder(_ sender: Any) {
        guard let reminderToUpdate = reminderToUpdate else {
            return
        }

        guard let reminderToUpdateDogUUID = reminderToUpdateDogUUID else {
            // If there is no reminderToUpdateDogUUID, then we don't contact the hound server
            delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogUUID: nil, forReminderUUID: reminderToUpdate.reminderUUID)
            self.dismiss(animated: true)
            return
        }

        let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(dogsAddDogReminderManagerViewController?.reminderActionTypeSelected?.convertToReadableName(customActionName: reminderToUpdate.reminderCustomActionName) ?? reminderToUpdate.reminderActionType.convertToReadableName(customActionName: reminderToUpdate.reminderCustomActionName))?", message: nil, preferredStyle: .alert)

        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.toggleUserInteractionForSaving(isUserInteractionEnabled: false)
            
            RemindersRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: reminderToUpdateDogUUID, forReminderUUIDs: [reminderToUpdate.reminderUUID]) { responseStatus, _ in
                
                self.toggleUserInteractionForSaving(isUserInteractionEnabled: true)
                
                guard responseStatus != .failureResponse else {
                    return
                }

                // persist data locally
                self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogUUID: reminderToUpdateDogUUID, forReminderUUID: reminderToUpdate.reminderUUID)
                self.dismiss(animated: true)
            }

        }

        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        removeReminderConfirmation.addAction(removeAlertAction)
        removeReminderConfirmation.addAction(cancelAlertAction)

        PresentationManager.enqueueAlert(removeReminderConfirmation)
    }

    @IBOutlet private weak var backButton: GeneralWithBackgroundUIButton!
    /// The cancel / exit button was pressed, dismisses view to complete intended action
    @IBAction private func didTouchUpInsideBack(_ sender: Any) {
        guard dogsAddDogReminderManagerViewController?.didUpdateInitialValues == true else {
            self.dismiss(animated: true)
            return
        }

        let unsavedInformationConfirmation = UIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)

        let exitAlertAction = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
            self.dismiss(animated: true)
        }

        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        unsavedInformationConfirmation.addAction(exitAlertAction)
        unsavedInformationConfirmation.addAction(cancelAlertAction)

        PresentationManager.enqueueAlert(unsavedInformationConfirmation)
    }

    // MARK: - Properties

    private weak var delegate: DogsAddReminderViewControllerDelegate!

    private var dogsAddDogReminderManagerViewController: DogsAddDogReminderManagerViewController?

    private var reminderToUpdate: Reminder?
    private var reminderToUpdateDogUUID: UUID?

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true

        if reminderToUpdate == nil {
            pageTitleLabel.text = "Create Reminder"
            duplicateReminderButton.removeFromSuperview()
            removeReminderButton.removeFromSuperview()
        }
        else {
            pageTitleLabel.text = "Edit Reminder"
        }
    }

    // MARK: - Functions

    func setup(forDelegate: DogsAddReminderViewControllerDelegate, forReminderToUpdateDogUUID: UUID?, forReminderToUpdate: Reminder?) {
        delegate = forDelegate
        reminderToUpdateDogUUID = forReminderToUpdateDogUUID
        reminderToUpdate = forReminderToUpdate
    }
    
    private func toggleUserInteractionForSaving(isUserInteractionEnabled: Bool) {
        duplicateReminderButton.isUserInteractionEnabled = isUserInteractionEnabled
        removeReminderButton.isUserInteractionEnabled = isUserInteractionEnabled
        saveReminderButton.isUserInteractionEnabled = isUserInteractionEnabled
        backButton.isUserInteractionEnabled = isUserInteractionEnabled
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsAddDogReminderManagerViewController = segue.destination as? DogsAddDogReminderManagerViewController {
            self.dogsAddDogReminderManagerViewController = dogsAddDogReminderManagerViewController
            dogsAddDogReminderManagerViewController.setup(forReminderToUpdate: self.reminderToUpdate)
        }
    }

}
