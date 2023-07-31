//
//  DogsIndependentReminderViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsIndependentReminderViewControllerDelegate: AnyObject {
    func didAddReminder(sender: Sender, forDogId: Int, forReminder: Reminder)
    func didRemoveReminder(sender: Sender, forDogId: Int, forReminderId: Int)
}

final class DogsIndependentReminderViewController: UIViewController {
    // MARK: - IB
    
    @IBOutlet private weak var pageTitleLabel: GeneralUILabel!
    
    @IBOutlet private weak var saveReminderButton: GeneralWithBackgroundUIButton!
    /// Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder to DogsViewController
    @IBAction private func didTouchUpInsideSaveReminder(_ sender: Any) {
        guard let reminder = dogsReminderManagerViewController?.currentReminder, let dogIdToUpdate = dogIdToUpdate else {
            return
        }
        
        saveReminderButton.beginSpinning()
        
        if reminderToUpdate != nil {
            RemindersRequest.update(invokeErrorManager: true, forDogId: dogIdToUpdate, forReminder: reminder) { requestWasSuccessful, _ in
                self.saveReminderButton.endSpinning()
                guard requestWasSuccessful else {
                    return
                }
                
                // the query was successful so we should now persist the reminderCustomActionName to LocalConfiguration if there was one
                let reminderCustomActionName = reminder.reminderCustomActionName
                if reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    LocalConfiguration.addReminderCustomAction(forName: reminderCustomActionName)
                }
                
                // successful so persist the data locally
                self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: dogIdToUpdate, forReminder: reminder)
                self.dismiss(animated: true)
            }
        }
        else {
            RemindersRequest.create(invokeErrorManager: true, forDogId: dogIdToUpdate, forReminder: reminder) { createdReminder, _ in
                self.saveReminderButton.endSpinning()
                
                guard let createdReminder = createdReminder else {
                    return
                }
                
                let reminderCustomActionName = reminder.reminderCustomActionName
                // the query was successful so we should now persist the reminderCustomActionName to LocalConfiguration if there was one
                if reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    LocalConfiguration.addReminderCustomAction(forName: reminderCustomActionName)
                }
                
                // successful and able to get reminderId, persist locally
                reminder.reminderId = createdReminder.reminderId
                self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: dogIdToUpdate, forReminder: reminder)
                self.dismiss(animated: true)
            }
        }
        
    }
    
    @IBOutlet private weak var removeReminderButton: GeneralUIButton!
    @IBAction private func didTouchUpInsideRemoveReminder(_ sender: Any) {
        guard let reminderToUpdate = reminderToUpdate, let dogIdToUpdate = dogIdToUpdate else {
            return
        }
        
        let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(dogsReminderManagerViewController?.currentReminderAction?.displayActionName(reminderCustomActionName: reminderToUpdate.reminderCustomActionName, isShowingAbreviatedCustomActionName: true) ?? reminderToUpdate.reminderAction.displayActionName(reminderCustomActionName: reminderToUpdate.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
        
        let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            RemindersRequest.delete(invokeErrorManager: true, forDogId: dogIdToUpdate, forReminder: reminderToUpdate) { requestWasSuccessful, _ in
                guard requestWasSuccessful else {
                    return
                }
                
                // persist data locally
                self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: dogIdToUpdate, forReminderId: reminderToUpdate.reminderId)
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
        guard dogsReminderManagerViewController?.didUpdateInitialValues == true else {
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
    
    private weak var delegate: DogsIndependentReminderViewControllerDelegate!
    
    private var dogsReminderManagerViewController: DogsReminderManagerViewController?
    
    private var reminderToUpdate: Reminder?
    private var dogIdToUpdate: Int?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTitleLabel.text = reminderToUpdate != nil ? "Edit Reminder" : "Create Reminder"
        removeReminderButton.isHidden = reminderToUpdate == nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: DogsIndependentReminderViewControllerDelegate, forDogIdToUpdate: Int, forReminderToUpdate: Reminder?) {
        delegate = forDelegate
        dogIdToUpdate = forDogIdToUpdate
        reminderToUpdate = forReminderToUpdate
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsReminderManagerViewController = segue.destination as? DogsReminderManagerViewController {
            self.dogsReminderManagerViewController = dogsReminderManagerViewController
            dogsReminderManagerViewController.setup(forReminderToUpdate: self.reminderToUpdate)
        }
    }
    
}
