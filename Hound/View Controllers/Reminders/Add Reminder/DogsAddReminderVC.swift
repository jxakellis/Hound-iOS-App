//
//  DogsAddReminderViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderViewControllerDelegate: AnyObject {
    /// If a dogId is provided, then the reminder is added, updated, or deleted on the Hound server, and both a dogId and reminder is returned. If a dogId is not returned, the reminder has only been added, updated, or deleted locally.
    func didAddReminder(sender: Sender, forDogId: Int?, forReminder: Reminder)
    /// If a dogId is provided, then the reminder is added, updated, or deleted on the Hound server, and both a dogId and reminder is returned. If a dogId is not returned, the reminder has only been added, updated, or deleted locally.
    func didUpdateReminder(sender: Sender, forDogId: Int?, forReminder: Reminder)
    /// If a dogId is provided, then the reminder is added, updated, or deleted on the Hound server, and both a dogId and reminder is returned. If a dogId is not returned, the reminder has only been added, updated, or deleted locally.
    func didRemoveReminder(sender: Sender, forDogId: Int?, forReminderId: Int)
}

final class DogsAddReminderViewController: UIViewController {
    // MARK: - IB

    @IBOutlet private weak var pageTitleLabel: GeneralUILabel!

    @IBOutlet private weak var saveReminderButton: GeneralWithBackgroundUIButton!
    /// Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder to DogsViewController
    @IBAction private func didTouchUpInsideSaveReminder(_ sender: Any) {
        guard let reminder = dogsAddReminderManagerViewController?.currentReminder else {
            return
        }

        // If we successfully constructed the reminder, add its reminder custom action name to LocalConfiguration
        if reminder.reminderAction == .custom && reminder.reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            LocalConfiguration.addReminderCustomAction(forName: reminder.reminderCustomActionName)
        }

        guard let parentDogId = parentDogId else {
            // If there is no parentDogId, then we don't contact the hound server
            if reminderToUpdate == nil {
                delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: nil, forReminder: reminder)
                self.dismiss(animated: true)
            }
            else {
                delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogId: nil, forReminder: reminder)
                self.dismiss(animated: true)
            }

            return
        }

        saveReminderButton.beginSpinning()

        if reminderToUpdate != nil {
            RemindersRequest.update(invokeErrorManager: true, forDogId: parentDogId, forReminder: reminder) { requestWasSuccessful, _, _ in
                self.saveReminderButton.endSpinning()
                guard requestWasSuccessful else {
                    return
                }

                self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: parentDogId, forReminder: reminder)
                self.dismiss(animated: true)
            }
        }
        else {
            RemindersRequest.create(invokeErrorManager: true, forDogId: parentDogId, forReminder: reminder) { createdReminder, _, _  in
                self.saveReminderButton.endSpinning()

                guard let createdReminder = createdReminder else {
                    return
                }

                // successful and able to get reminderId, persist locally
                reminder.reminderId = createdReminder.reminderId
                self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: parentDogId, forReminder: reminder)
                self.dismiss(animated: true)
            }
        }

    }

    @IBOutlet private weak var removeReminderButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideRemoveReminder(_ sender: Any) {
        guard let reminderToUpdate = reminderToUpdate else {
            return
        }

        guard let parentDogId = parentDogId else {
            // If there is no parentDogId, then we don't contact the hound server
            delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: nil, forReminderId: reminderToUpdate.reminderId)
            self.dismiss(animated: true)
            return
        }

        let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(dogsAddReminderManagerViewController?.currentReminderAction?.displayActionName(reminderCustomActionName: reminderToUpdate.reminderCustomActionName) ?? reminderToUpdate.reminderAction.displayActionName(reminderCustomActionName: reminderToUpdate.reminderCustomActionName))?", message: nil, preferredStyle: .alert)

        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            RemindersRequest.delete(invokeErrorManager: true, forDogId: parentDogId, forReminder: reminderToUpdate) { requestWasSuccessful, _, _ in
                guard requestWasSuccessful else {
                    return
                }

                // persist data locally
                self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: parentDogId, forReminderId: reminderToUpdate.reminderId)
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
        guard dogsAddReminderManagerViewController?.didUpdateInitialValues == true else {
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

    private var dogsAddReminderManagerViewController: DogsAddReminderManagerViewController?

    private var reminderToUpdate: Reminder?
    private var parentDogId: Int?

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        if reminderToUpdate == nil {
            pageTitleLabel.text = "Create Reminder"
            removeReminderButton.removeFromSuperview()
        }
        else {
            pageTitleLabel.text = "Edit Reminder"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }

    // MARK: - Functions

    func setup(forDelegate: DogsAddReminderViewControllerDelegate, forParentDogId: Int?, forReminderToUpdate: Reminder?) {
        delegate = forDelegate
        parentDogId = forParentDogId
        reminderToUpdate = forReminderToUpdate
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsAddReminderManagerViewController = segue.destination as? DogsAddReminderManagerViewController {
            self.dogsAddReminderManagerViewController = dogsAddReminderManagerViewController
            dogsAddReminderManagerViewController.setup(forReminderToUpdate: self.reminderToUpdate)
        }
    }

}
