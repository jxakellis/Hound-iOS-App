//
//  DogsIndependentReminderViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsIndependentReminderViewControllerDelegate: AnyObject {
    func didAddReminder(sender: Sender, forDogId: Int, forReminder: Reminder)
    func didRemoveReminder(sender: Sender, forDogId: Int, forReminderId: Int)
}

final class DogsIndependentReminderViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var pageNavigationBar: UINavigationItem!
    
    @IBOutlet private weak var saveReminderButton: ScaledUIButton!
    @IBOutlet private weak var saveReminderButtonBackground: ScaledUIButton!
    /// Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder to DogsViewController
    @IBAction private func willSave(_ sender: Any) {
        // Since this is the independent reminders view controller, meaning its not nested in a larger Add Dog VC, we perform the server queries then exit.
        
        let reminder = dogsReminderManagerViewController.reminderWithSettingsApplied()
        
        guard let reminder = reminder else {
            return
        }
        
        saveReminderButton.beginQuerying()
        saveReminderButtonBackground.beginQuerying(isBackgroundButton: true)
        
        // reminder settings were valid
        if isUpdating == true {
            RemindersRequest.update(invokeErrorManager: true, forDogId: forDogId, forReminder: reminder) { requestWasSuccessful, _ in
                self.saveReminderButton.endQuerying()
                self.saveReminderButtonBackground.endQuerying(isBackgroundButton: true)
                guard requestWasSuccessful else {
                    return
                }
                
                // the query was successful so we should now persist the reminderCustomActionName to LocalConfiguration if there was one
                let reminderCustomActionName = reminder.reminderCustomActionName
                if reminderCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    LocalConfiguration.addReminderCustomAction(forName: reminderCustomActionName)
                }
                
                // successful so persist the data locally
                self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: self.forDogId, forReminder: reminder)
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        else {
            RemindersRequest.create(invokeErrorManager: true, forDogId: forDogId, forReminder: reminder) { createdReminder, _ in
                self.saveReminderButton.endQuerying()
                self.saveReminderButtonBackground.endQuerying(isBackgroundButton: true)
                
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
                self.delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: self.forDogId, forReminder: reminder)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    @IBOutlet private weak var reminderRemoveButton: UIBarButtonItem!
    @IBAction private func willRemoveReminder(_ sender: Any) {
        
        // Since this is the independent reminders view controller, meaning its not nested in a larger Add Dog VC, we perform the server queries then exit.
        
        guard let targetReminder = targetReminder else {
            reminderRemoveButton.isEnabled = false
            return
        }
        let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogsReminderManagerViewController.selectedReminderAction?.displayActionName(reminderCustomActionName: targetReminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true) ?? targetReminder.reminderAction.displayActionName(reminderCustomActionName: targetReminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
            RemindersRequest.delete(invokeErrorManager: true, forDogId: self.forDogId, forReminder: targetReminder) { requestWasSuccessful, _ in
                guard requestWasSuccessful else {
                    return
                }
                // persist data locally
                self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: self.forDogId, forReminderId: targetReminder.reminderId)
                self.navigationController?.popViewController(animated: true)
                
            }
            
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeReminderConfirmation.addAction(alertActionRemove)
        removeReminderConfirmation.addAction(alertActionCancel)
        
        AlertManager.enqueueAlertForPresentation(removeReminderConfirmation)
    }
    
    @IBOutlet private weak var cancelUpdateReminderButton: ScaledUIButton!
    @IBOutlet private weak var cancelUpdateReminderButtonBackground: ScaledUIButton!
    /// The cancel / exit button was pressed, dismisses view to complete intended action
    @IBAction private func willCancel(_ sender: Any) {
        
        // "Any changes you have made won't be saved"
        if dogsReminderManagerViewController.initalValuesChanged == true {
            let unsavedInformationConfirmation = GeneralUIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
            
            let alertActionExit = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            unsavedInformationConfirmation.addAction(alertActionExit)
            unsavedInformationConfirmation.addAction(alertActionCancel)
            
            AlertManager.enqueueAlertForPresentation(unsavedInformationConfirmation)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: - Properties
    
    weak var delegate: DogsIndependentReminderViewControllerDelegate! = nil
    
    var dogsReminderManagerViewController: DogsReminderManagerViewController = DogsReminderManagerViewController()
    
    var targetReminder: Reminder?
    var isUpdating: Bool {
        if targetReminder == nil {
            return false
        }
        else {
            return true
        }}
    
    var forDogId: Int! = nil
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isUpdating == true {
            pageNavigationBar.title = "Edit Reminder"
            pageNavigationBar.rightBarButtonItem?.isEnabled = true
        }
        else {
            pageNavigationBar.title = "Create Reminder"
            pageNavigationBar.rightBarButtonItem?.isEnabled = false
        }
        
        self.view.bringSubviewToFront(saveReminderButtonBackground)
        self.view.bringSubviewToFront(saveReminderButton)
        
        self.view.bringSubviewToFront(cancelUpdateReminderButtonBackground)
        self.view.bringSubviewToFront(cancelUpdateReminderButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsReminderManagerViewController = segue.destination as? DogsReminderManagerViewController {
            self.dogsReminderManagerViewController = dogsReminderManagerViewController
            
            dogsReminderManagerViewController.targetReminder = self.targetReminder
        }
    }
    
}
